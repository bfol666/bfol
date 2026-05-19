import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/ai_reply_bubble.dart';

class CreateEntryPage extends ConsumerStatefulWidget {
  const CreateEntryPage({super.key});

  @override
  ConsumerState<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends ConsumerState<CreateEntryPage> {
  final _contentController = TextEditingController();
  final _linkController = TextEditingController();
  MoodOption? _selectedMood;
  final List<File> _images = [];
  bool _showLinkInput = false;
  bool _isRecording = false;
  String? _aiReply;

  @override
  void dispose() {
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录心情'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submitEntry : null,
            child: const Text(
              '发布',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood selector
            const Text(
              '今天的心情',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            MoodSelector(
              selectedEmoji: _selectedMood?.emoji ?? args?['emoji'],
              onChanged: (option) {
                setState(() => _selectedMood = option);
              },
            ),

            const SizedBox(height: 24),

            // Text input
            GlassContainer(
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: '今天发生了什么？让文字记录你的心情...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 16),

            // Image previews
            if (_images.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      return _addImageButton(size: 80);
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _images[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _images.removeAt(index));
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // AI reply preview
            if (_aiReply != null) ...[
              AIReplyBubble(reply: _aiReply!),
              const SizedBox(height: 12),
            ],

            // Toolbar
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _toolButton(Icons.image_outlined, '照片', () => _pickImages()),
                  const SizedBox(width: 16),
                  _toolButton(Icons.mic_outlined, _isRecording ? '录音中...' : '语音',
                      () => _toggleRecording()),
                  const SizedBox(width: 16),
                  _toolButton(Icons.link_outlined, '链接', () {
                    setState(() => _showLinkInput = !_showLinkInput);
                  }),
                  const Spacer(),
                  _toolButton(Icons.auto_awesome_outlined, 'AI分析', () => _triggerAI()),
                ],
              ),
            ),

            // Link input
            if (_showLinkInput) ...[
              const SizedBox(height: 12),
              GlassContainer(
                child: TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    hintText: '粘贴链接地址...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Icon(Icons.link, size: 20, color: AppColors.accent1),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _addImageButton({double size = 80}) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder, style: BorderStyle.solid),
        ),
        child: const Icon(Icons.add_photo_alternate_outlined,
            color: AppColors.textSecondary, size: 28),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      _images.addAll(images.map((e) => File(e.path)));
    });
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    // TODO: Implement voice recording with `record` package
  }

  Future<void> _triggerAI() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {}); // trigger loading state
    // TODO: Call AI service to analyze and generate reply
    // Simulated AI reply for skeleton
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _aiReply = '我能感受到你此刻的心情。每一个情绪都值得被看见和接纳，谢谢你的分享 🌸';
    });
  }

  bool get _canSubmit {
    return _selectedMood != null || _contentController.text.trim().isNotEmpty;
  }

  void _submitEntry() {
    // TODO: Call entry provider to create entry
    Navigator.pop(context);
  }
}
