import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'circularIcon_button.dart';

typedef SendMessageFunction = void Function(String message);

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final SendMessageFunction sendMessage;
  final VoidCallback onAddIconPressed;
  final bool isLoading;
  const MessageInput(
      {Key? key,
      required this.messageController,
      required this.sendMessage,
      required this.onAddIconPressed,
      required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    CircularIconButton(
                      icon: Icons.add,
                      backgroundColor: const Color(0xFFAB0505),
                      onPressed: onAddIconPressed,
                      height: 37,
                      width: 37,
                      iconSize: 20,
                      iconColor: Colors.white,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(color: const Color(0xffF0F0F0)),
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
                                      hintText: 'Message',
                                      hintStyle: TextStyle(
                                        color:
                                            Color(0xFFCCD5FF), // Set color here
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 16.0, right: 48.0),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                    onSubmitted: (message) {
                                      sendMessage(message);
                                      print("in input $isLoading");
                                    },
                                    enabled: !isLoading,
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
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              sendMessage(messageController.text);
                            },
                      child: Image.asset(
                        'assets/images/send.png',
                        width: 37.0,
                        height: 37.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/tagline.png',
                    width: 100,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
