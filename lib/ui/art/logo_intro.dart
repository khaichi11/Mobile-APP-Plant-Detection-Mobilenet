import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme.dart';
import 'logo.dart';

/// A calm opening: the mark and name fade in while growing slightly, rest for a
/// moment, then fade out into the app. Tapping the screen skips ahead.
class LogoIntro extends StatefulWidget {
  const LogoIntro({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LogoIntro> createState() => _LogoIntroState();
}

class _LogoIntroState extends State<LogoIntro>
    with SingleTickerProviderStateMixin {
  static const _inSec = .9, _holdSec = 1.1, _outSec = .5;

  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _t = 0; // seconds since start
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ticker.start());
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    // Frame gaps are capped so a stall on a slow phone pauses the motion
    // instead of skipping it.
    final dt = math.min((elapsed - _last).inMicroseconds / 1e6, 1 / 30);
    _last = elapsed;
    _t += dt;
    if (_t >= _inSec + _holdSec + _outSec && !_done) {
      _done = true;
      _ticker.stop();
      widget.onDone();
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final show = Curves.easeOutCubic.transform((_t / _inSec).clamp(0.0, 1.0));
    final hide = Curves.easeInCubic.transform(
      ((_t - _inSec - _holdSec) / _outSec).clamp(0.0, 1.0),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_t < _inSec + _holdSec) setState(() => _t = _inSec + _holdSec);
        },
        child: Center(
          child: Opacity(
            opacity: show * (1 - hide),
            child: Transform.scale(
              scale: .92 + .08 * show + .04 * hide,
              child: const PandaiWordmark(markSize: 120),
            ),
          ),
        ),
      ),
    );
  }
}
