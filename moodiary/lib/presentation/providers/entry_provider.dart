import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/entry.dart';
import '../../data/services/local_storage_service.dart';

class EntryState {
  final List<Entry> entries;
  final bool isLoading;
  final String? error;

  const EntryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  EntryState copyWith({
    List<Entry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return EntryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EntryNotifier extends StateNotifier<EntryState> {
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  EntryNotifier(this._storage) : super(const EntryState());

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    try {
      final cached = _storage.getCachedEntries();
      if (cached.isEmpty) {
        await _seedMockData();
        return;
      }
      cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = EntryState(entries: cached);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Entry?> createEntry({
    required String userId,
    String? content,
    required Mood mood,
    List<EntryMedia> media = const [],
    List<String> tags = const [],
  }) async {
    try {
      final entry = Entry(
        id: _uuid.v4(),
        userId: userId,
        content: content,
        mood: mood,
        media: media,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _storage.addEntry(entry);
      state = state.copyWith(entries: [entry, ...state.entries]);
      return entry;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      _storage.deleteEntry(id);
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<Entry> getEntriesByDate(DateTime date) {
    return state.entries.where((e) {
      return e.createdAt.year == date.year &&
          e.createdAt.month == date.month &&
          e.createdAt.day == date.day;
    }).toList();
  }

  Map<DateTime, List<Entry>> get entriesByDate {
    final map = <DateTime, List<Entry>>{};
    for (final entry in state.entries) {
      final date = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      map.putIfAbsent(date, () => []).add(entry);
    }
    return map;
  }

  Future<void> _seedMockData() async {
    final now = DateTime.now();
    final mocks = [
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '傍晚去了江边散步，落日好美，染红了整片天空。回家路上买了杯热咖啡，暖烘烘的。',
        mood: const Mood(emoji: '😊', score: 5, label: '开心'),
        media: [const EntryMedia(type: EntryMediaType.image, url: '')],
        tags: ['落日', '散步', '咖啡'],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '完成了一个重要的项目里程碑。虽然身体疲惫，但心里很满足。',
        mood: const Mood(emoji: '😌', score: 4, label: '平静'),
        tags: ['工作', '里程碑'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '和朋友约了下午茶。她说我最近状态看起来不错，我也觉得生活在慢慢变好 🌸',
        mood: const Mood(emoji: '🥰', score: 5, label: '感激'),
        media: [
          const EntryMedia(type: EntryMediaType.image, url: ''),
          const EntryMedia(type: EntryMediaType.image, url: ''),
        ],
        tags: ['朋友', '下午茶'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '工作上遇到了一些挫折。晚上听了喜欢的播客，感觉好多了。允许自己不开心，也是一种力量。',
        mood: const Mood(emoji: '😢', score: 2, label: '难过'),
        tags: ['播客', '自我疗愈'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '周末逛集市，买了一盆小植物回家。绿绿的叶子摆在书桌旁边，心情一下子亮了起来。',
        mood: const Mood(emoji: '🌟', score: 4, label: '期待'),
        media: [const EntryMedia(type: EntryMediaType.image, url: '')],
        tags: ['周末', '植物', '集市'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Entry(
        id: _uuid.v4(),
        userId: 'local-user',
        content: '尝试了新的咖啡店，抹茶拿铁好好喝。坐在窗边看了会儿书，这样的午后值得被记住。',
        mood: const Mood(emoji: '😌', score: 4, label: '平静'),
        media: [
          const EntryMedia(
              type: EntryMediaType.link,
              url: '',
              metadata: {'title': '有田咖啡 · 建国西路店'})
        ],
        tags: ['咖啡店', '阅读'],
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
    ];
    for (final entry in mocks) {
      await _storage.addEntry(entry);
    }
    state = state.copyWith(entries: mocks..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}
