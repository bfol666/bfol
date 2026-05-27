import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/entry.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;
  final bool compact;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.compact = false,
  });

  Color get _moodTint {
    switch (entry.mood.label) {
      case '开心':
        return AppColors.moodHappy.withValues(alpha: 0.18);
      case '平静':
        return AppColors.moodCalm.withValues(alpha: 0.18);
      case '难过':
        return AppColors.moodSad.withValues(alpha: 0.18);
      case '焦虑':
        return AppColors.moodAnxious.withValues(alpha: 0.18);
      case '生气':
        return AppColors.moodAngry.withValues(alpha: 0.18);
      case '感激':
        return AppColors.moodGrateful.withValues(alpha: 0.18);
      case '期待':
        return AppColors.moodExcited.withValues(alpha: 0.18);
      default:
        return AppColors.surfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 16,
          vertical: compact ? 4 : 7,
        ),
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: _moodTint,
          borderRadius: BorderRadius.circular(compact ? 14 : 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.mood.emoji,
                    style: TextStyle(fontSize: compact ? 22 : 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.mood.label,
                        style: TextStyle(
                          fontSize: compact ? 13 : 15,
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
                ),
                if (entry.isPrivate)
                  const Icon(Icons.lock_outline,
                      size: 15, color: AppColors.textSecondary),
              ],
            ),
            if (entry.content != null && entry.content!.isNotEmpty) ...[
              SizedBox(height: compact ? 8 : 12),
              Text(
                entry.content!,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 14,
                  height: 1.65,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            if (entry.media.isNotEmpty) ...[
              SizedBox(height: compact ? 8 : 10),
              _buildMediaPreview(),
            ],
            if (entry.tags.isNotEmpty) ...[
              SizedBox(height: compact ? 6 : 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: compact ? 10 : 11,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageMedia.isNotEmpty)
          SizedBox(
            height: compact ? 80 : 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageMedia.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = imageMedia[index].url;
                final file = File(url);
                final showImage = url.isNotEmpty && file.existsSync();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: compact ? 80 : 100,
                    height: compact ? 80 : 100,
                    color: AppColors.surfaceMuted,
                    child: showImage
                        ? Image.file(file, fit: BoxFit.cover)
                        : const Icon(Icons.image_outlined,
                            color: AppColors.textSecondary, size: 28),
                  ),
                );
              },
            ),
          ),
        if (voiceMedia.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: imageMedia.isNotEmpty ? 6 : 2),
            child: Row(
              children: [
                const Icon(Icons.mic, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                const Text('语音记录',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        if (linkMedia.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
                top: (imageMedia.isNotEmpty || voiceMedia.isNotEmpty) ? 6 : 2),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16, color: AppColors.accentBlue),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    linkMedia.first.metadata?['title'] ?? linkMedia.first.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.accentBlue),
                  ),
                ),
              ],
            ),
          ),
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
