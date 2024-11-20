import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movemate_staff/features/call_page/call_page.dart';

import 'package:movemate_staff/services/chat_services/data/chat_services.dart';
import 'package:movemate_staff/services/chat_services/models/chat_model.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

@RoutePage()
class ChatWithPorterScreen extends HookConsumerWidget {
  final String porterId;
  final String porterName;
  final String? porterAvatar;

  const ChatWithPorterScreen({
    super.key,
    required this.porterId,
    required this.porterName,
    this.porterAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final staffChatManager = StaffChatManager(
      currentUserId: ref.read(authProvider)!.id.toString(),
      currentUserRole: 'reviewer',
    );

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.mainColor,
        backButtonColor: AssetsConstants.whiteColor,
        title: "Chat với $porterName",
        iconFirst: Icons.call,
        onCallBackFirst: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CallPage(callID: '123456'),
            ),
          );
        },
      ),
      body: StreamBuilder<String>(
        stream: _getConversationStream(staffChatManager),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final conversationId = snapshot.data!;
          return StaffChatContent(
            conversationId: conversationId,
            staffChatManager: staffChatManager,
            porterName: porterName,
            porterAvatar: porterAvatar ?? '',
          );
        },
      ),
    );
  }

  // Stream for conversation creation or existing conversation
  Stream<String> _getConversationStream(StaffChatManager staffChatManager) {
    return Stream.fromFuture(
      staffChatManager.getOrCreateStaffConversation(porterId, 'porter'),
    );
  }
}

class StaffChatContent extends HookConsumerWidget {
  final String conversationId;
  final StaffChatManager staffChatManager;
  final String porterName;
  final String porterAvatar;

  const StaffChatContent({
    super.key,
    required this.conversationId,
    required this.staffChatManager,
    required this.porterName,
    required this.porterAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    return StreamBuilder<List<Message>>(
      stream: staffChatManager.getStaffMessages(conversationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSent =
                      message.senderId == staffChatManager.currentUserId;

                  return ChatMessage(
                    text: message.content,
                    time: _formatTimestamp(message.timestamp),
                    isSent: isSent,
                    senderName: !isSent ? porterName : 'Bạn',
                    avatarUrl: !isSent ? porterAvatar : null,
                  );
                },
              ),
            ),
            ChatInputBox(
              onSendMessage: (content) async {
                if (content.trim().isNotEmpty) {
                  messageController.clear();
                  await staffChatManager.sendStaffMessage(
                      conversationId, content);
                }
              },
              controller: messageController,
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String time;
  final bool isSent;
  final String senderName;
  final String? avatarUrl;

  const ChatMessage({
    super.key,
    required this.text,
    required this.time,
    required this.isSent,
    required this.senderName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: isSent
              ? _buildSentMessageLayout()
              : _buildReceivedMessageLayout(),
        ),
      ),
    );
  }

  List<Widget> _buildSentMessageLayout() {
    return [
      Flexible(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AssetsConstants.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildReceivedMessageLayout() {
    return [
      if (avatarUrl != null && avatarUrl!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl!),
            radius: 20,
          ),
        ),
      Flexible(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(text),
              const SizedBox(height: 5),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class ChatInputBox extends StatelessWidget {
  final Function(String) onSendMessage;
  final TextEditingController controller;

  const ChatInputBox({
    super.key,
    required this.onSendMessage,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: InputBorder.none,
              ),
              onSubmitted: (value) => onSendMessage(value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AssetsConstants.primaryLight),
            onPressed: () => onSendMessage(controller.text),
          ),
        ],
      ),
    );
  }
}
