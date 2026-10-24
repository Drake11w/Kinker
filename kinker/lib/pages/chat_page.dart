import 'package:flutter/material.dart';

import '../common_widgets/platform_alert_dialog.dart';
import '../models/chat_message.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import '../services/services.dart';
import '../widgets/profile_photo.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.match,
    required this.me,
    required this.other,
  });

  final Match match;
  final UserProfile me;
  final UserProfile other;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  Stream<List<ChatMessage>>? _messages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messages ??=
        Services.of(context).repository.watchMessages(widget.match.id);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    try {
      await Services.of(context)
          .repository
          .sendMessage(widget.match.id, widget.me.uid, text);
    } catch (e) {
      if (mounted) {
        _input.text = text;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Message not sent: $e')));
      }
    }
  }

  Future<void> _unmatch() async {
    final repository = Services.of(context).repository;
    final navigator = Navigator.of(context);
    final confirmed = await PlatformAlertDialog(
      title: 'Unmatch ${widget.other.name}?',
      content: 'You won\'t be able to message each other any more.',
      cancelText: 'Cancel',
      confirmText: 'Unmatch',
    ).show(context);
    if (!confirmed) return;
    await repository.unmatch(widget.match.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ProfileAvatar(profile: widget.other, radius: 18),
            const SizedBox(width: 12),
            Text(widget.other.name),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => _unmatch(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'unmatch', child: Text('Unmatch')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _messages,
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? const [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'You matched with ${widget.other.name}.\nSay hello!',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final message = messages[messages.length - 1 - i];
                      return _Bubble(
                        message: message,
                        mine: message.senderId == widget.me.uid,
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('messageInput'),
                      controller: _input,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000, // matches firestore.rules
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('sendMessage'),
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: mine ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}
