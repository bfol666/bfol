import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Polaroid-style image display widget
class PolaroidImage extends StatelessWidget {
  final String? imageUrl;
  final String caption;
  final double width;
  final VoidCallback? onTap;

  const PolaroidImage({
    super.key,
    this.imageUrl,
    this.caption = '',
    this.width = 160,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: width - 16,
                      height: width - 16,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: width - 16,
                      height: width - 16,
                      color: AppColors.cardBackground,
                      child: const Icon(Icons.add_a_photo_outlined,
                          color: AppColors.textSecondary, size: 32),
                    ),
            ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
