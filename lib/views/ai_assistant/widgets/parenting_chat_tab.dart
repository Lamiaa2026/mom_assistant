import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/ai_message_model.dart';
import '../../../state/app_state.dart';

class ParentingChatTab extends StatefulWidget {
  const ParentingChatTab({super.key});

  @override
  State<ParentingChatTab> createState() => _ParentingChatTabState();
}

class _ParentingChatTabState extends State<ParentingChatTab> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(AppState state, [String? customQuery]) {
    final text = (customQuery ?? _inputController.text).trim();
    if (text.isEmpty || state.isAiThinking) return;

    _inputController.clear();
    state.sendUserChatMessage(text);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = state.aiMessages.where((m) => m.type == AIMessageType.parentingAdvice || m.type == AIMessageType.generalChat).toList();

    return Column(
      children: [
        // Quick suggestion chips
        Container(
          height: 48,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.parentingQuickPrompts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final prompt = AppConstants.parentingQuickPrompts[index];
              return ActionChip(
                label: Text(prompt, style: AppTypography.labelSmall),
                backgroundColor: isDark ? AppColors.cardDark : AppColors.primarySoft,
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.primary.withOpacity(0.3)),
                onPressed: () => _sendMessage(state, prompt),
              );
            },
          ),
        ),

        // Chat message list
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'اطرحي أي تساؤل تربوي أو صحي وستجيبكِ خبيرة الأمومة فوراً 🌸',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(context, msg, isDark);
                  },
                ),
        ),

        // AI Thinking indicator
        if (state.isAiThinking)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                ),
                const SizedBox(width: 10),
                Text(
                  'المستشار الذكي يفكّر ويكتب لكِ الإجابة الآن...',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Input Area
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _sendMessage(state),
                  decoration: const InputDecoration(
                    hintText: 'اسألي عن سلوك طفلكِ، التغذية، روتين النوم...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () => _sendMessage(state),
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, AIMessageModel msg, bool isDark) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: !isUser
                    ? Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser
                          ? Colors.white
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('hh:mm a', 'ar').format(msg.timestamp),
                    style: AppTypography.labelSmall.copyWith(
                      color: isUser ? Colors.white.withOpacity(0.7) : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Text('👩', style: TextStyle(fontSize: 16)),
            ),
          ],
        ],
      ),
    );
  }
}
