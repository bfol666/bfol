import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../providers/providers.dart';
import '../../widgets/surface_container.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/ai_reply_bubble.dart';

class CreateEntryPage extends ConsumerStatefulWidget {
  const CreateEntryPage({super.key});

  @override
  ConsumerState<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends ConsumerState<CreateEntryPage>
    with TickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _linkTextController = TextEditingController();
  final _audioRecorder = AudioRecorder();
  MoodOption? _selectedMood;
  final List<File> _images = [];
  bool _showLinkInput = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;
  String? _pendingLink;
  String _displayedAIReply = '';
  Timer? _typewriterTimer;
  int _typewriterIndex = 0;
  bool _isAnalyzing = false;
  bool _isAnalyzingMood = false;
  List<String> _aiTags = [];

  @override
  void dispose() {
    _contentController.dispose();
    _linkTextController.dispose();
    _recordingTimer?.cancel();
    _typewriterTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null && _selectedMood == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final emoji = args['emoji'];
        if (emoji != null && mounted) {
          final option =
              MoodSelector.options.where((o) => o.emoji == emoji).toList();
          if (option.isNotEmpty) {
            setState(() => _selectedMood = option.first);
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录心情'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          AnimatedOpacity(
            opacity: _canSubmit ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: _canSubmit ? _submitEntry : null,
              child: const Text('发布',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '今天的心情',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_contentController.text.trim().isNotEmpty)
                  _isAnalyzingMood
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : GestureDetector(
                          onTap: _analyzeMood,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_outlined,
                                  size: 15, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('AI 分析',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
              ],
            ),
            const SizedBox(height: 12),
            MoodSelector(
              selectedEmoji: _selectedMood?.emoji,
              onChanged: (option) => setState(() => _selectedMood = option),
            ),

            const SizedBox(height: 24),

            // Text input — clean surface, no glass
            SurfaceContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
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

            const SizedBox(height: 14),

            // Image previews
            if (_images.isNotEmpty) ...[
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + (_images.length < 9 ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == _images.length) return _addImageButton();
                    return _imageThumbnail(index);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Recording indicator (when recording)
            if (_isRecording) ...[
              _buildRecordingIndicator(),
              const SizedBox(height: 12),
            ],

            // Recording preview (after recording stopped)
            if (!_isRecording && _recordingPath != null) ...[
              _buildRecordingPreview(),
              const SizedBox(height: 12),
            ],

            // Link input
            if (_showLinkInput) ...[
              _buildLinkInput(),
              const SizedBox(height: 12),
            ],

            // Pending link preview
            if (_pendingLink != null) ...[
              _buildPendingLinkPreview(),
              const SizedBox(height: 12),
            ],

            // AI reply
            if (_displayedAIReply.isNotEmpty) ...[
              AIReplyBubble(reply: _displayedAIReply),
              const SizedBox(height: 12),
            ],

            // Loading
            if (_isAnalyzing) ...[
              SurfaceContainer(
                borderRadius: 14,
                padding: const EdgeInsets.all(14),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                    SizedBox(width: 10),
                    Text('AI 正在感受你的心情...',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Toolbar — flat buttons, no glass
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return SurfaceContainer(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      hasShadow: false,
      child: Row(
        children: [
          _toolBtn(
            Icons.image_outlined,
            _images.isNotEmpty ? '照片 ${_images.length}' : '照片',
            AppColors.coral,
            _pickImages,
          ),
          const SizedBox(width: 8),
          _toolBtn(
            _isRecording ? Icons.stop_circle_outlined : Icons.mic_outlined,
            _isRecording
                ? _recordingTimeStr
                : _recordingPath != null
                    ? '语音 ✓'
                    : '语音',
            _isRecording
                ? AppColors.coral
                : _recordingPath != null
                    ? AppColors.coral
                    : AppColors.accentBlue,
            _toggleRecording,
          ),
          const SizedBox(width: 8),
          _toolBtn(Icons.link_outlined,
              _pendingLink != null ? '链接 ✓' : '链接', AppColors.primary, () {
            setState(() => _showLinkInput = !_showLinkInput);
          }),
          const Spacer(),
          _toolBtn(
            Icons.auto_awesome_outlined,
            'AI',
            AppColors.accentBlue,
            _contentController.text.trim().isNotEmpty ? _triggerAI : null,
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(
      IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _addImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text('${_images.length}/9',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _imageThumbnail(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_images[index],
              width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => setState(() => _images.removeAt(index)),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child:
                  const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return SurfaceContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _PulsingDot(color: AppColors.coral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('正在录音...',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(_recordingTimeStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: AppColors.coral,
                      fontFeatures: [FontFeature.tabularFigures()],
                    )),
              ],
            ),
          ),
          ...List.generate(
              6,
              (i) => Container(
                    width: 3,
                    height: 10.0 + (i % 3) * 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.coral
                          .withValues(alpha: 0.35 + (i % 3) * 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildLinkInput() {
    return SurfaceContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.link, size: 20, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _linkTextController,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '粘贴链接地址...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_linkTextController.text.trim().isNotEmpty) {
                setState(() {
                  _pendingLink = _linkTextController.text.trim();
                  _showLinkInput = false;
                  _linkTextController.clear();
                });
              }
            },
            child: const Text('添加',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildRecordingPreview() {
    return SurfaceContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mic,
                size: 22, color: AppColors.coral),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('语音已录制',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                SizedBox(height: 3),
                Text('录音文件已保存',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _recordingPath = null),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close,
                  size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingLinkPreview() {
    final link = _pendingLink!;
    final displayUrl = link.length > 50 ? '${link.substring(0, 50)}...' : link;
    return SurfaceContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link,
                size: 22, color: AppColors.accentBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('链接已添加',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(displayUrl,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.accentBlue)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _pendingLink = null),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close,
                  size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String get _recordingTimeStr {
    final min = _recordingSeconds ~/ 60;
    final sec = _recordingSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImages() async {
    if (_images.length >= 9) return;
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage();
    if (!mounted) return;
    final remaining = 9 - _images.length;
    setState(() {
      _images.addAll(imgs.take(remaining).map((e) => File(e.path)));
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _recordingPath = path;
          _isRecording = false;
          _recordingSeconds = 0;
        });
        if (path != null) {
          final transcript =
              await ref.read(aiProvider.notifier).transcribeVoice(path);
          if (mounted && transcript != null && transcript.isNotEmpty) {
            final current = _contentController.text;
            final newText =
                current.isEmpty ? transcript : '$current\n$transcript';
            _contentController.text = newText;
            setState(() {});
          }
        }
      }
    } else {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要麦克风权限才能录音')),
          );
        }
        return;
      }
      try {
        final dir = Directory.systemTemp;
        final filePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
          _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            setState(() {
              _recordingSeconds++;
              if (_recordingSeconds >= 60) {
                timer.cancel();
                _toggleRecording();
              }
            });
          });
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('录音启动失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _triggerAI() async {
    setState(() {
      _isAnalyzing = true;
      _displayedAIReply = '';
    });

    final content = _contentController.text.trim();
    final moodLabel = _selectedMood?.label ?? '记录';

    final ai = ref.read(aiProvider.notifier);
    if (ai.isConfigured) {
      final reply = await ai.getAIReply(content, moodLabel);
      if (mounted && reply != null) {
        setState(() => _isAnalyzing = false);
        _startTypewriter(reply);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final replies = {
      '开心': '我能感受到你字里行间的快乐！这一刻的美好值得被记住 🌸',
      '平静': '平静是一种很好的状态。享受属于你自己的宁静时分吧 🍃',
      '难过': '每个人都会有低落的时刻。写下这些感受，本身就是一种疗愈 💙',
      '焦虑': '试试深呼吸，关注当下能做的事。你已经做得很好了 ✨',
      '生气': '写下来就是释放的第一步。明天回头看，也许会有不同的感受 🌿',
      '感激': '懂得感恩的人最幸福。这些温暖的瞬间是你最珍贵的宝藏 🌷',
      '期待': '有期待的日子总是闪闪发亮的！这份心情本身就是一种美好的力量 🌟',
    };
    _startTypewriter(
        replies[moodLabel] ?? '谢谢你的分享。每一份心情都值得被温柔对待 💫');
  }

  void _startTypewriter(String text) {
    _typewriterTimer?.cancel();
    _typewriterIndex = 0;
    setState(() => _displayedAIReply = '');

    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 40),
      (timer) {
        if (_typewriterIndex < text.length) {
          setState(() {
            _displayedAIReply = text.substring(0, _typewriterIndex + 1);
            _typewriterIndex++;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  Future<void> _analyzeMood() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isAnalyzingMood = true);

    final ai = ref.read(aiProvider.notifier);
    if (!ai.isConfigured) {
      // Simple local analysis: keyword matching
      if (mounted) {
        setState(() {
          _isAnalyzingMood = false;
          _selectedMood = _localMoodAnalysis(content);
        });
      }
      return;
    }

    final analysis = await ai.analyzeEntry(content);
    if (!mounted) return;

    setState(() => _isAnalyzingMood = false);
    if (analysis != null) {
      final matched = MoodSelector.options.where(
        (o) => o.label == analysis.moodLabel,
      );
      if (matched.isNotEmpty) {
        setState(() => _selectedMood = matched.first);
      }
      if (analysis.tags.isNotEmpty) {
        setState(() => _aiTags = analysis.tags);
      }
    }
  }

  MoodOption _localMoodAnalysis(String text) {
    final keywords = {
      '开心': ['开心', '快乐', '高兴', '美好', '喜欢', '幸福', '笑', '棒', '赞', '好'],
      '难过': ['难过', '伤心', '哭', '失落', '失望', '痛', '孤独', '寂寞'],
      '焦虑': ['焦虑', '担心', '紧张', '压力', '怕', '烦', '慌'],
      '生气': ['生气', '愤怒', '讨厌', '烦人', '气', '恨'],
      '平静': ['平静', '安静', '宁静', '放松', '舒适', '舒服', '平和'],
      '感激': ['感激', '感谢', '感恩', '谢谢', '珍惜', '幸运'],
      '期待': ['期待', '希望', '等待', '盼望', '计划', '即将'],
    };
    for (final entry in keywords.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) {
          return MoodSelector.options.firstWhere((o) => o.label == entry.key);
        }
      }
    }
    return MoodSelector.options[1]; // default: 平静
  }

  bool get _canSubmit {
    return _selectedMood != null ||
        _contentController.text.trim().isNotEmpty ||
        _pendingLink != null;
  }

  void _submitEntry() {
    final mood = _selectedMood;
    if (mood == null && _contentController.text.trim().isEmpty) return;

    final media = <EntryMedia>[];
    for (final img in _images) {
      media.add(EntryMedia(type: EntryMediaType.image, url: img.path));
    }
    if (_recordingPath != null) {
      media.add(EntryMedia(type: EntryMediaType.voice, url: _recordingPath!));
    }
    if (_pendingLink != null) {
      media.add(EntryMedia(type: EntryMediaType.link, url: _pendingLink!));
    }

    ref.read(entryProvider.notifier).createEntry(
      userId: 'local-user',
      content: _contentController.text.trim().isNotEmpty
          ? _contentController.text.trim()
          : null,
      mood: mood != null
          ? Mood(emoji: mood.emoji, score: mood.score, label: mood.label)
          : const Mood(emoji: '📝', score: 3, label: '记录'),
      media: media,
      tags: _extractTags(),
    );

    _aiTags = [];

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (ctx.mounted) {
            Navigator.pop(ctx);
            if (mounted) Navigator.pop(context);
          }
        });
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 4),
              Text('✨', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text('记录成功',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              SizedBox(height: 4),
              Text('你的心情已被温柔收藏',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  List<String> _extractTags() {
    final text = _contentController.text;
    final tags = <String>{..._aiTags};
    final hashRegex = RegExp(r'#([\w一-鿿]+)');
    for (final match in hashRegex.allMatches(text)) {
      tags.add(match.group(1)!);
    }
    return tags.toList();
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10 + (_controller.value * 6),
          height: 10 + (_controller.value * 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(
                alpha: 0.5 + (_controller.value * 0.5)),
          ),
        );
      },
    );
  }
}
