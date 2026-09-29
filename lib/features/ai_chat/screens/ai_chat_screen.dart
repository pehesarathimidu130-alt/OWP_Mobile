import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_greeting.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/typing_indicator.dart';

/// Full-screen AI Wedding Planner chat experience.
///
/// Opened via context.push('/ai-chat') from [MainNavigation]; the bottom
/// navigation bar is hidden because this route lives outside the tab shell.
///
/// State is scoped to this screen: a [ChangeNotifierProvider] wraps the
/// navigator-scoped [ChatProvider], so chat history clears when the screen
/// is closed (back navigation).
///
/// An optional [chatProvider] may be injected for testing purposes.
class AiChatScreen extends StatelessWidget {
  final ChatProvider? chatProvider;

  const AiChatScreen({super.key, this.chatProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (_) => chatProvider ?? ChatProvider(),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls the message list to the very bottom.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  Widget build(BuildContext context) {
    // Listen to changes so we can auto-scroll.
    final chat = context.watch<ChatProvider>();

    // Auto-scroll whenever messages change or typing state toggles.
    _scrollToBottom();

    return GestureDetector(
      // Dismiss keyboard when tapping outside the input.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: OleenaTheme.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: OleenaTheme.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: BackButton(
            color: OleenaTheme.textDark,
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Oleena AI',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: OleenaTheme.textDark,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'New chat',
              icon: const Icon(
                Icons.add_comment_outlined,
                color: OleenaTheme.textDark,
              ),
              onPressed: () => context.read<ChatProvider>().clearChat(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: OleenaTheme.borderSubtle,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: chat.isEmpty
                  // ── EMPTY STATE ──────────────────────────────────────────
                  ? const ChatGreeting()
                  // ── CONVERSATION STATE ───────────────────────────────────
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount:
                          chat.messages.length + (chat.isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chat.messages.length) {
                          return ChatMessageBubble(
                            message: chat.messages[index],
                          );
                        }
                        // Last item is the typing indicator.
                        return const TypingIndicator();
                      },
                    ),
            ),
            // ── INPUT BAR (always pinned at bottom) ──────────────────────
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
