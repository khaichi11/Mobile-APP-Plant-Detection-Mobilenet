import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/plant_catalog.dart';
import '../../models/user_profile.dart';

/// Decodes images at the size they are shown, which keeps memory use low in
/// grids of photos.
int? _cacheWidth(BuildContext context, BoxConstraints constraints) {
  if (!constraints.hasBoundedWidth) return null;
  final ratio = MediaQuery.devicePixelRatioOf(context);
  return (constraints.maxWidth * ratio).round().clamp(64, 1440);
}

Widget _brokenImage() => Container(
  color: AppColors.mint,
  alignment: Alignment.center,
  child: const Icon(Icons.local_florist_rounded, color: AppColors.forest),
);

class PlantPhoto extends StatelessWidget {
  const PlantPhoto(
    this.plantId, {
    super.key,
    this.radius = Radii.md,
    this.fit = BoxFit.cover,
  });

  final String plantId;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LayoutBuilder(
        builder:
            (context, constraints) => Image.asset(
              plantById(plantId).photoAsset,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: _cacheWidth(context, constraints),
              errorBuilder: (_, _, _) => _brokenImage(),
            ),
      ),
    );
  }
}

class FilePhoto extends StatelessWidget {
  const FilePhoto(this.path, {super.key, this.radius = Radii.md});

  final String path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LayoutBuilder(
        builder:
            (context, constraints) => Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: _cacheWidth(context, constraints),
              errorBuilder: (_, _, _) => _brokenImage(),
            ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 24});

  final UserProfile? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final path = user?.avatarPath;
    final name = user?.name.trim() ?? '';
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.mint,
      foregroundImage:
          path == null
              ? null
              : ResizeImage(
                FileImage(File(path)),
                width: (radius * 2 * ratio).round(),
              ),
      onForegroundImageError: path == null ? null : (_, _) {},
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.8,
          color: AppColors.forestDark,
        ),
      ),
    );
  }
}
