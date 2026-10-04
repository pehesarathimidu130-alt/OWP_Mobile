import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

import 'package:image_picker/image_picker.dart';

/// Bottom sheet for selecting a profile photo source (Camera / Gallery).
class ProfilePhotoSheet extends StatelessWidget {
  final ValueChanged<XFile>? onPhotoSelected;

  const ProfilePhotoSheet({super.key, this.onPhotoSelected});

  static Future<void> show(BuildContext context, {ValueChanged<XFile>? onPhotoSelected}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfilePhotoSheet(onPhotoSelected: onPhotoSelected),
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
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final picker = ImagePicker();
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (file != null && onPhotoSelected != null) {
                  onPhotoSelected!(file);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open camera: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 10),

          // Gallery option
          _PhotoOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            subtitle: 'Browse your photos',
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final picker = ImagePicker();
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (file != null && onPhotoSelected != null) {
                  onPhotoSelected!(file);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open gallery: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),

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
