import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

/// Bottom sheet for selecting a profile photo source (Camera / Gallery / Remove).
///
/// NOTE: Full image upload requires the `image_picker` package (not yet in
/// pubspec.yaml). This widget currently shows the selection UI and a placeholder
/// snackbar. Once the backend owner exposes `PUT /customer/profile/photo`
/// and the team agrees to add `image_picker`, replace the TODO bodies with
/// real pick + upload logic.
///
/// Required endpoint (flag to backend owner):
///   PUT /api/customer/profile/photo
///   Auth: Bearer
///   Body: multipart/form-data  `{ photo: file }`
///   Response: { photoUrl: string }
class ProfilePhotoSheet extends StatelessWidget {
  final VoidCallback? onRemovePhoto;

  const ProfilePhotoSheet({super.key, this.onRemovePhoto});

  static Future<void> show(BuildContext context, {VoidCallback? onRemovePhoto}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfilePhotoSheet(onRemovePhoto: onRemovePhoto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Change Profile Photo',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OleenaTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you would like to update your photo',
            style: GoogleFonts.poppins(fontSize: 12, color: OleenaTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // Camera option
          _PhotoOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            subtitle: 'Open camera',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Add image_picker (camera) once team approves the package.
              // ImagePicker().pickImage(source: ImageSource.camera)
              //   .then((file) => _uploadPhoto(context, file));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Camera upload coming soon — awaiting image_picker approval.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: OleenaTheme.textDark,
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Gallery option
          _PhotoOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            subtitle: 'Browse your photos',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Add image_picker (gallery) once team approves the package.
              // ImagePicker().pickImage(source: ImageSource.gallery)
              //   .then((file) => _uploadPhoto(context, file));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gallery upload coming soon — awaiting image_picker approval.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: OleenaTheme.textDark,
                ),
              );
            },
          ),

          if (onRemovePhoto != null) ...[
            const SizedBox(height: 10),
            _PhotoOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Photo',
              subtitle: 'Revert to initials avatar',
              iconColor: Colors.red.shade400,
              labelColor: Colors.red.shade700,
              onTap: () {
                Navigator.of(context).pop();
                onRemovePhoto!();
              },
            ),
          ],

          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: OleenaTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: OleenaTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OleenaTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? OleenaTheme.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? OleenaTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? OleenaTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: OleenaTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
