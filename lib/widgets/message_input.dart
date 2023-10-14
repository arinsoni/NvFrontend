import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'circularIcon_button.dart';

typedef SendMessageFunction = void Function(String message);


class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final SendMessageFunction sendMessage;
  final VoidCallback onAddIconPressed;
  const MessageInput(
      {Key? key,
      required this.messageController,
      required this.sendMessage,
      required this.onAddIconPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: Colors.white, 
      ),
      Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Column(children: [
            Row(
              children: <Widget>[
                CircularIconButton(
                  icon: Icons.add,
                  backgroundColor: const Color(0xFF7356E8),
                  onPressed: () {}, height: 37, width: 37, iconSize: 20, iconColor: Colors.white, 
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0x62000000)),
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 100.0, 
                      ),
                      child: Stack(
                        children: <Widget>[
                          ListView(
                            shrinkWrap: true,
                            children: [
                              TextField(
                                controller: messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Ask a question',
                                  contentPadding:
                                      EdgeInsets.only(left: 16.0, right: 48.0),
                                  border: InputBorder.none,
                                ),
                                maxLines:
                                    null, 
                                onSubmitted: (message) {
                                  sendMessage(message);
                                },
                              ),
                            ],
                          ),
                          Positioned(
                            right: 8.0,
                            top: 8.0,
                            bottom: 8.0,
                            child: IconButton(
                              icon: const Icon(Icons.mic),
                              color: Colors.grey,
                              onPressed: () {
                                sendMessage(messageController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svg/send.svg',
                    width: 20.0,
                    height: 20.0,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF7356E8),
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'A red up arrow',
                  ),
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                ),
              ],
            )
          ]))
    ]);
  }
}
