import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../providers/providers.dart';
import '../../widgets/entry_card.dart';
import '../../widgets/surface_container.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(entryProvider.notifier).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(entryProvider);
    final entries = entryState.entries;

    ref.listen(entryProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(entryProvider.notifier).loadEntries();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildQuickMoodBar()),
              if (entries.isNotEmpty)
                SliverToBoxAdapter(child: _buildWeeklyPreview()),
              if (entryState.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                )
              else if (entryState.error != null)
                SliverToBoxAdapter(child: _buildErrorState(entryState.error!))
              else if (entries.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final isFirst = index == 0;
                        final isPhotoHeavy = entry.media
                                .where((m) => m.type == EntryMediaType.image)
                                .length >=
                            2;
                        final useFull = isFirst ||
                            isPhotoHeavy ||
                            (entry.content != null &&
                                entry.content!.length > 60);
                        return EntryCard(
                          entry: entry,
                          compact: !useFull,
                          onTap: () {
                            Navigator.pushNamed(context, '/detail',
                                arguments: entry);
                          },
                        );
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child:
            const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingText(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('yyyy年M月d日 EEEE', 'zh_CN')
                    .format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryMuted,
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SurfaceContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        hasShadow: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _moodChip('😊', '开心'),
            _moodChip('😌', '平静'),
            _moodChip('😢', '难过'),
            _moodChip('😰', '焦虑'),
            _moodChip('😤', '生气'),
            _moodChip('🥰', '感激'),
            _moodChip('🌟', '期待'),
          ],
        ),
      ),
    );
  }

  Widget _moodChip(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/create',
            arguments: {'emoji': emoji, 'label': label});
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildWeeklyPreview() {
    final entryCount = ref.watch(entryProvider).entries.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/report'),
        child: SurfaceContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('📊', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '查看本周周报',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '本周记录了 $entryCount 条心情',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 15, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📝', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('还没有记录',
                style:
                    TextStyle(fontSize: 17, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('点击下方按钮，记录今天的心情吧',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😥', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('加载失败',
                  style: TextStyle(
                      fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(entryProvider.notifier).loadEntries(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早安';
    if (hour < 18) return '下午好';
    return '晚安';
  }
}
