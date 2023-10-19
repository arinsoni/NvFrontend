import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'circularIcon_button.dart';

typedef SendMessageFunction = void Function(String message);

class MessageInput extends StatefulWidget {
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
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
    late TokenLimitController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TokenLimitController(maxTokens: 8000, context: context);
  }

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
                      icon: Icons.mic,
                      backgroundColor: const Color(0xFFAB0505),
                      // onPressed: widget.onAddIconPressed,
                      height: 37,
                      width: 37,
                      iconSize: 20,
                      iconColor: Colors.white, 
                      isEnabled: !widget.isLoading,
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
                                    controller: widget.messageController,
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
                                      widget.sendMessage(message);
                                      print("in input ${widget.isLoading}");
                                    },
                                    enabled: !widget.isLoading,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.isLoading
                          ? null
                          : () {
                              widget.sendMessage(widget.messageController.text);
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




class TokenLimitController extends TextEditingController {
  final int maxTokens;
  final BuildContext context;

  TokenLimitController({required this.maxTokens, required this.context});

  @override
  set text(String newText) {
    if (newText.split(' ').length <= maxTokens) {
      super.text = newText;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Token Limit Reached'),
            content: Text('You cannot enter more than $maxTokens tokens.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}