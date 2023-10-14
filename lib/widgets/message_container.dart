import 'package:flutter/material.dart';

import 'audio _ player.dart';

class MessageContainer extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String) onEdit;

  const MessageContainer(
      {Key? key, required this.message, required this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message['sender'] == 'user';
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = isUserMessage ? screenWidth * 0.8 : screenWidth * 0.8;

    return Row(
      mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            icon: Image.asset(
              'assets/images/edit.png',
              height: 20,
              width: 20,
            ),
            onPressed: () {
              if (isUserMessage) {
                if (isUserMessage) {
                  onEdit(message['text']);
                }
              }
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 0, bottom: 8),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          decoration: BoxDecoration(
            color: isUserMessage ? const Color(0xFF7356E8) : const Color(0xFFDFDFF4),
            borderRadius: BorderRadius.only(
              topRight: const Radius.circular(16),
              topLeft: isUserMessage ? const Radius.circular(16) : const Radius.circular(0),
              bottomLeft: const Radius.circular(16),
              bottomRight:
                  isUserMessage ? const Radius.circular(0) : const Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              if (message['audio'] != null && message['audio'].isNotEmpty)
                AudioPlayerWidget(key: UniqueKey(), url: message['audio']),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Text(
                  message['text'],
                  style: TextStyle(
                    color: isUserMessage ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
