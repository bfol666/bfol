import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/entry.dart';
import '../../data/services/supabase_service.dart';

class EntryState {
  final List<Entry> entries;
  final bool isLoading;
  final String? error;

  const EntryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  EntryState copyWith({List<Entry>? entries, bool? isLoading, String? error}) {
    return EntryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EntryNotifier extends StateNotifier<EntryState> {
  final SupabaseService _supabaseService;

  EntryNotifier(this._supabaseService) : super(const EntryState());

  Future<void> loadEntries(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabaseService.getEntries(userId);
      final entries = data.map((e) => Entry.fromJson(e)).toList();
      state = EntryState(entries: entries);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
        id: '',
        userId: userId,
        content: content,
        mood: mood,
        media: media,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = await _supabaseService.createEntry(entry.toJson()..remove('id'));
      final created = Entry.fromJson(data);
      state = state.copyWith(entries: [created, ...state.entries]);
      return created;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
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
      final date = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      map.putIfAbsent(date, () => []).add(entry);
    }
    return map;
  }
}
