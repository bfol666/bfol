import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/entry.dart';
import 'glass_container.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: mood + date
            Row(
              children: [
                Text(entry.mood.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mood.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(entry.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (entry.isPrivate)
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textSecondary),
              ],
            ),

            // Content
            if (entry.content != null && entry.content!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                entry.content!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ],

            // Media preview
            if (entry.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMediaPreview(),
            ],

            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    final imageMedia =
        entry.media.where((m) => m.type == EntryMediaType.image).toList();
    final voiceMedia =
        entry.media.where((m) => m.type == EntryMediaType.voice).toList();
    final linkMedia =
        entry.media.where((m) => m.type == EntryMediaType.link).toList();

    return Column(
      children: [
        if (imageMedia.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageMedia.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                    ),
                    // TODO: Use CachedNetworkImage when URL is available
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        if (voiceMedia.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.mic, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('语音记录',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
        if (linkMedia.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 18, color: AppColors.accent1),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  linkMedia.first.metadata?['title'] ?? linkMedia.first.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.accent1),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}月${date.day}日';
  }
}
