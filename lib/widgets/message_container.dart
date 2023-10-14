import 'package:flutter/material.dart';

import 'CircularIcon_Button.dart';
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
          child: isUserMessage
              ? Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEBEBEB),
                  ),
                  child: Center(
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
                )
              : Container(
                  height: 0,
                  width: 0,
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? const Color(0xFF7356E8)
                  : const Color(0xFFDFDFF4),
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(25),
                topLeft: isUserMessage
                    ? const Radius.circular(25)
                    : const Radius.circular(0),
                bottomLeft: const Radius.circular(25),
                bottomRight: isUserMessage
                    ? const Radius.circular(0)
                    : const Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                if (message['audio'] != null && message['audio'].isNotEmpty)
                  AudioPlayerWidget(key: UniqueKey(), url: message['audio']),
                Padding(
                  padding:  EdgeInsets.fromLTRB(16, isUserMessage ? 8 : 2, 8, 8),
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8.0),
          child: !isUserMessage
              ? CircularIconButton(
                  icon: Icons.refresh,
                  backgroundColor: const Color(0xFFEBEBEB),
                  onPressed: () {},
                  height: 30,
                  width: 30,
                  iconSize: 20,
                  iconColor: const Color(0xFF9B9B9B),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
        ),
      ],
    );
  }
}
