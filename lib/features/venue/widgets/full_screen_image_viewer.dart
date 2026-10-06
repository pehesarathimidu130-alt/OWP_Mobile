import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../core/theme.dart';

/// Full-screen swipeable image gallery viewer with pinch-to-zoom support.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.title,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int _currentIndex;
  late final PageController _pageController;

  // Swipe-down-to-dismiss tracking
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;

    return GestureDetector(
      onVerticalDragStart: (_) {
        _isDragging = true;
        _dragOffset = 0.0;
      },
      onVerticalDragUpdate: (details) {
        if (!_isDragging) return;
        setState(() {
          _dragOffset += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        _isDragging = false;
        final velocity = details.primaryVelocity ?? 0;
        if (_dragOffset > 80 || velocity > 600) {
          Navigator.of(context).pop();
        } else {
          setState(() => _dragOffset = 0.0);
        }
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset.clamp(0.0, double.infinity)),
        child: Opacity(
          opacity: (1.0 - (_dragOffset.clamp(0.0, 200.0) / 300.0)).clamp(0.0, 1.0),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // ── Gallery View ────────────────────────────────────────────
                if (widget.imageUrls.isEmpty)
                  _buildEmptyPlaceholder()
                else
                  PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    pageController: _pageController,
                    itemCount: total,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    builder: (context, index) {
                      final url = widget.imageUrls[index];
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(url),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 2.5,
                        heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_hero_${url}_$index'),
                        errorBuilder: (context, error, stackTrace) {
                          return _buildErrorPlaceholder();
                        },
                      );
                    },
                    loadingBuilder: (context, event) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: OleenaTheme.primary,
                      ),
                    ),
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                  ),

                // ── Top Navigation Bar ──────────────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      // Close button
                      Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.title != null && widget.title!.isNotEmpty)
                        Expanded(
                          child: Text(
                            widget.title!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      if (total > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / $total',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No images available',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 44,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Image could not be loaded',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
