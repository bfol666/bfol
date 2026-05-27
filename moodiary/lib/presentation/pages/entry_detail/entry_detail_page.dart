import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../providers/providers.dart';
import '../../widgets/surface_container.dart';
import '../../widgets/ai_reply_bubble.dart';

class EntryDetailPage extends ConsumerWidget {
  final Entry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.mood.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('删除这条记录？',
                      style: TextStyle(fontSize: 17, color: AppColors.textPrimary)),
                  content: const Text('删除后无法恢复',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(entryProvider.notifier).deleteEntry(entry.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('删除',
                          style: TextStyle(color: AppColors.coral)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final images =
              entry.media.where((m) => m.type == EntryMediaType.image).toList();
          final links =
              entry.media.where((m) => m.type == EntryMediaType.link).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood + date header
                SurfaceContainer(
                  child: Row(
                    children: [
                      Text(entry.mood.emoji,
                          style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.mood.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('yyyy年M月d日 HH:mm')
                                .format(entry.createdAt),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                if (entry.content != null &&
                    entry.content!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SurfaceContainer(
                    child: Text(
                      entry.content!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],

                // Images
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final url = images[index].url;
                        final file = File(url);
                        final showImage = url.isNotEmpty && file.existsSync();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: showImage
                                ? Image.file(file, fit: BoxFit.cover)
                                : const Center(
                                    child: Icon(Icons.image_outlined,
                                        size: 48, color: AppColors.textHint),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Links
                if (links.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...links.map((link) => GestureDetector(
                        onTap: () {
                          final uri = Uri.tryParse(link.url);
                          if (uri != null) launchUrl(uri);
                        },
                        child: SurfaceContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.link,
                                  size: 20,
                                  color: AppColors.accentBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    link.metadata?['title'] ??
                                        '链接',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    link.url,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color:
                                          AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                ],

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted
                              .withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(14),
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

                // AI reply
                const SizedBox(height: 20),
                AIReplyBubble(
                  reply: _aiReplyForMood(entry.mood.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _aiReplyForMood(String moodLabel) {
    switch (moodLabel) {
      case '开心':
        return '看到你开心的样子真好！生活中的美好时刻值得被记录下来，以后翻看的时候一定会再次微笑 🌸';
      case '难过':
        return '我能感受到你此刻的心情。每一个情绪都值得被看见和接纳，谢谢你愿意分享。记得给自己一点时间和空间，一切都会慢慢好起来的 💙';
      case '平静':
        return '平静也是一种很好的状态呢。在忙碌的生活中找到属于自己的节奏，享受这份宁静的美好 🍃';
      case '焦虑':
        return '焦虑的时候试试深呼吸，给自己3分钟闭眼休息。你已经做得很好了，不用对自己太苛刻。明天又是新的一天 ✨';
      case '感激':
        return '懂得感恩的人最幸福。珍惜这些微小的美好时刻，它们构成了我们生命中最温暖的底色 🌷';
      case '生气':
        return '有时候生气也是正常的。写下来就是释放的第一步，明天回头看，也许会有不同的感受 🌿';
      case '期待':
        return '有期待的日子总是闪闪发亮的！无论是对未来的憧憬还是对明天的盼望，这份心情本身就是一种幸福 🌟';
      default:
        return '谢谢你的分享。每一份心情都值得被温柔对待，我会一直在这里陪伴你 💫';
    }
  }
}
