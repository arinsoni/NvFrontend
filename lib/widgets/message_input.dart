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
      decoration: BoxDecoration(
    border: Border.all(
      color: Color(0xffF2F2F2), 
      width: 2.0,
    ),
  ),
      child: Stack(
        children: [
          Container(
             decoration: BoxDecoration(color: Color(0xffF2F2F2)), 
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: Colors
                                .red // Replace 'borderColor' with your desired color// Replace 'borderWidth' with your desired width. e.g. 2.0
                            ),
                      ),
                      child: Center(
                        child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.red,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: widget.isLoading ? null : widget.onAddIconPressed),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(color: const Color(0xffA4A4A4)),
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
                                    maxLength: 500,
                                    controller: widget.messageController,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: 'Send a message...',
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(255, 124, 124,
                                            124), // Set color here
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
                    IconButton(
                      icon: Image.asset(
                        'assets/images/send.png',
                        width: 25.0,
                        height: 25.0,
                      ),
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              widget.sendMessage(widget.messageController.text);
                            },
                    )
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
