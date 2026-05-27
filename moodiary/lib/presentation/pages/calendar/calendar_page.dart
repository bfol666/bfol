import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../providers/providers.dart';
import '../../providers/entry_provider.dart';
import '../../widgets/surface_container.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(entryProvider);
    final entries = entryState.entries;

    final entryDates = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet();

    final selectedEntries = _selectedDate != null
        ? entries.where((e) {
            return e.createdAt.year == _selectedDate!.year &&
                e.createdAt.month == _selectedDate!.month &&
                e.createdAt.day == _selectedDate!.day;
          }).toList()
        : <Entry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: entryState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildMonthHeader(),
                  _buildWeekdayLabels(),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(entryDates),
                  const SizedBox(height: 12),
                  if (_selectedDate != null)
                    _buildDayEntries(selectedEntries, entryState),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('yyyy年 M月').format(_currentMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              _navButton(Icons.chevron_left, () {
                setState(() {
                  _currentMonth =
                      DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              }),
              const SizedBox(width: 12),
              _navButton(Icons.chevron_right, () {
                setState(() {
                  _currentMonth =
                      DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const ['一', '二', '三', '四', '五', '六', '日']
            .map((d) => SizedBox(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(Set<DateTime> entryDates) {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final today = DateTime.now();
    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.85,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final day = index - (firstWeekday - 1) + 1;
          if (day < 1 || day > daysInMonth) {
            return const SizedBox.shrink();
          }

          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected = _selectedDate != null &&
              date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
          final hasEntry = entryDates.any((d) =>
              d.year == date.year &&
              d.month == date.month &&
              d.day == date.day);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : isToday
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary
                              : date.weekday == 6 || date.weekday == 7
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                    ),
                  ),
                  if (hasEntry)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.coral.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayEntries(List<Entry> entries, EntryState entryState) {
    final formattedDate =
        DateFormat('M月d日 EEEE', 'zh_CN').format(_selectedDate!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SurfaceContainer(
        borderRadius: 18,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (entryState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  entryState.error!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.coral),
                  textAlign: TextAlign.center,
                ),
              )
            else if (entries.isNotEmpty)
              ...entries.map<Widget>((entry) => _dayEntryItem(entry))
            else
              const SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    '这一天还没有记录',
                    style: TextStyle(fontSize: 14, color: AppColors.textHint),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayEntryItem(Entry entry) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/detail', arguments: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(entry.mood.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.content ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(entry.mood.label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
