import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The only glassmorphic surface in the app.
/// Purpose: AI response feels ephemeral, like a thought, not a permanent card.
/// Glass blurs it into the background — light, floating, non-intrusive.
class AIReplyBubble extends StatelessWidget {
  final String reply;
  final bool isLoading;

  const AIReplyBubble({
    super.key,
    required this.reply,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isLoading
                ? _buildLoading()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI 共鸣',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reply,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 正在感受你的心情...',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 20,
          height: 20,
          child:
              CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ],
    );
  }
}
