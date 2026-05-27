import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<MoodOption> onChanged;

  static const List<MoodOption> options = [
    MoodOption(emoji: '😊', label: '开心', score: 5, color: AppColors.moodHappy),
    MoodOption(emoji: '😌', label: '平静', score: 4, color: AppColors.moodCalm),
    MoodOption(emoji: '😢', label: '难过', score: 2, color: AppColors.moodSad),
    MoodOption(emoji: '😰', label: '焦虑', score: 2, color: AppColors.moodAnxious),
    MoodOption(emoji: '😤', label: '生气', score: 1, color: AppColors.moodAngry),
    MoodOption(emoji: '🥰', label: '感激', score: 5, color: AppColors.moodGrateful),
    MoodOption(emoji: '🌟', label: '期待', score: 4, color: AppColors.moodExcited),
  ];

  const MoodSelector({
    super.key,
    this.selectedEmoji,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = option.emoji == selectedEmoji;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected ? option.color.withValues(alpha: 0.4) : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: option.color, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final int score;
  final Color color;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.score,
    required this.color,
  });
}
