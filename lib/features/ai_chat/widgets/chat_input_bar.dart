import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../providers/chat_provider.dart';

/// Pinned input bar at the bottom of the chat screen.
///
/// A pill-shaped container with a multiline [TextField] (1–4 lines) and a
/// circular send button that is enabled only when the field contains
/// non-whitespace text.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    // Restore focus so the keyboard stays open.
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: OleenaTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: OleenaTheme.borderSubtle, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Multiline text field.
              Expanded(
                child: TextField(
                  key: const Key('chat_input_field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: OleenaTheme.textDark,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask anything from our AI',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: OleenaTheme.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              // Send button.
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: Material(
                  color: _hasText ? OleenaTheme.primary : OleenaTheme.primaryTint,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const Key('send_button'),
                    customBorder: const CircleBorder(),
                    onTap: _hasText ? _send : null,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 20,
                        color: _hasText ? Colors.white : OleenaTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
