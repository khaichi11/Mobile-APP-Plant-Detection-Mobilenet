import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/app_services.dart';
import 'scan_result_page.dart';

Future<void> openScanner(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ScannerPage()));
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  FlashMode _flash = FlashMode.off;
  String? _error;
  bool _busy = false;

  /// True while another screen is on top, so the camera stays off.
  bool _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameras.isEmpty) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _closeCamera();
    } else if (state == AppLifecycleState.resumed && !_away) {
      _startCamera();
    }
  }

  Future<void> _loadCameras() async {
    try {
      final cameras = await context.read<AppServices>().cameras();
      if (!mounted) return;
      final back = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      setState(() {
        _cameras = cameras;
        _cameraIndex = back == -1 ? 0 : back;
        if (cameras.isEmpty) _error = 'No camera was found on this device.';
      });
      await _startCamera();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The camera is not available on this device.');
      }
    }
  }

  Future<void>? _initializing;

  Future<void> _startCamera() async {
    if (_away || _cameras.isEmpty || _controller != null) return;
    final controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      final init = controller.initialize();
      _initializing = init;
      await init;
      // The camera was closed while it was starting.
      if (!identical(_controller, controller)) return;
      await _applyFlash(controller, _flash);
      if (mounted) setState(() => _error = null);
    } on CameraException catch (e) {
      if (!identical(_controller, controller)) return;
      _controller = null;
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _error = switch (e.code) {
          'CameraAccessDenied' ||
          'CameraAccessDeniedWithoutPrompt' ||
          'CameraAccessRestricted' =>
            'Pandai needs camera permission to scan plants. You can allow it '
                'in your phone settings, or pick a photo instead.',
          _ => 'The camera could not start. You can pick a photo instead.',
        };
      });
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    if (mounted) setState(() {});
    try {
      await _initializing;
    } catch (_) {
      // Start-up errors are handled in _startCamera.
    }
    await controller.dispose();
  }

  Future<void> _applyFlash(CameraController controller, FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException {
      // Some cameras, like most front cameras, have no flash.
    }
  }

  Future<void> _toggleFlash() async {
    final next = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      _ => FlashMode.off,
    };
    setState(() => _flash = next);
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await _applyFlash(controller, next);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _closeCamera();
    await _startCamera();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      HapticFeedback.mediumImpact();
      final file = await controller.takePicture();
      await _showResult(file.path);
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not take a photo. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    // The photo picker covers the app; keep the camera off meanwhile.
    _away = true;
    await _closeCamera();
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked != null) {
        await _showResult(picked.path);
      } else {
        _away = false;
        if (mounted) await _startCamera();
      }
    } on PlatformException {
      _away = false;
      if (mounted) await _startCamera();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open your photos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showResult(String path) async {
    _away = true;
    await _closeCamera();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanResultPage(imagePath: path)),
    );
    _away = false;
    if (mounted) await _startCamera();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              _Preview(controller: controller)
            else if (_error != null)
              _CameraUnavailable(message: _error!, onPick: _pickFromGallery)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (ready) const _Viewfinder(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Gap.sm),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (ready)
                      _RoundButton(
                        icon: switch (_flash) {
                          FlashMode.off => Icons.flash_off_rounded,
                          FlashMode.auto => Icons.flash_auto_rounded,
                          _ => Icons.flash_on_rounded,
                        },
                        tooltip: 'Flash',
                        onPressed: _toggleFlash,
                      ),
                  ],
                ),
              ),
            ),
            if (ready)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.xl,
                      Gap.lg,
                      Gap.xl,
                      Gap.xl,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundButton(
                          icon: Icons.photo_library_outlined,
                          tooltip: 'Pick from photos',
                          onPressed: _pickFromGallery,
                        ),
                        _ShutterButton(busy: _busy, onPressed: _capture),
                        _RoundButton(
                          icon: Icons.cameraswitch_rounded,
                          tooltip: 'Switch camera',
                          onPressed: _cameras.length > 1 ? _switchCamera : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // The camera aspect ratio is reported for landscape; fill the portrait
    // screen without stretching.
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth * 0.74;
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _ViewfinderPainter(side),
              ),
              Positioned(
                top: constraints.maxHeight / 2 + side / 2 + Gap.lg,
                left: Gap.xl,
                right: Gap.xl,
                child: Text(
                  'Fill the frame with one leaf, flower or fruit',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    shadows: const [Shadow(blurRadius: 6)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter(this.side);

  final double side;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    final frame = RRect.fromRectAndRadius(rect, const Radius.circular(28));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(frame),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    final corner =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    const arm = 34.0;
    for (final (dx, dy) in [
      (-1.0, -1.0),
      (1.0, -1.0),
      (-1.0, 1.0),
      (1.0, 1.0),
    ]) {
      final x = dx < 0 ? rect.left : rect.right;
      final y = dy < 0 ? rect.top : rect.bottom;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - dy * arm)
          ..lineTo(x, y - dy * 14)
          ..quadraticBezierTo(x, y, x - dx * 14, y)
          ..lineTo(x - dx * arm, y),
        corner,
      );
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) =>
      oldDelegate.side != side;
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white38,
        minimumSize: const Size(52, 52),
      ),
      icon: Icon(icon),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Take photo',
      child: GestureDetector(
        onTap: busy ? null : onPressed,
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: busy ? Colors.white54 : Colors.white,
            ),
            child:
                busy
                    ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.forest,
                      ),
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.message, required this.onPick});

  final String message;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: Gap.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: Gap.xl),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Pick a photo'),
            ),
          ],
        ),
      ),
    );
  }
}
