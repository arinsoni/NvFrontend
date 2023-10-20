import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nvsirai/schema/message.dart';

import 'CircularIcon_Button.dart';
import 'audio _ player.dart';

class MessageContainer extends StatelessWidget {
  // final Map<String, dynamic> message;
  final Function(String) onEdit;
  final bool isLoading;
  final Function(int) onRefresh;
  final Message message;
  final int index;
  final bool isRefresh;
  final bool isEditable;

  const MessageContainer(
      {Key? key,
      required this.message,
      required this.onEdit,
      required this.isLoading,
      required this.index,
      required this.onRefresh,
      required this.isRefresh,
      required this.isEditable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && message.sender == 'user') {
      print("Showing loading indicator...");
      return _buildLoadingIndicator();
    } else {
      // print("check : $isLoading");
      final isUserMessage = message.sender == 'user';
      double screenWidth = MediaQuery.of(context).size.width;
      double maxWidth = isUserMessage ? screenWidth * 0.8 : screenWidth * 0.8;

      return Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: isUserMessage && isEditable
                ? Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (isUserMessage) {
                            onEdit(message.text);
                          }
                        },
                        child: Image.asset(
                          'assets/images/edit.png',
                          width: 20.0,
                          height: 20.0,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
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
                    ? const Color(0xFF6983FF)
                    : const Color(0xFFFFFFFF),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.25),
                    offset: isUserMessage ? Offset(0, 4) : Offset(5, 5),
                    blurRadius: isUserMessage ? 4.0 : 10,
                    spreadRadius: 0.0,
                  ),
                ],
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
                  if (message.audioUrl != null && message.audioUrl!.isNotEmpty)
                    AudioPlayerWidget(key: UniqueKey(), url: message.audioUrl!),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(16, isUserMessage ? 8 : 2, 8, 8),
                    child: isUserMessage
                        ? Text(
                            message.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                        : DefaultTextStyle(
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(message.text),
                              ],
                              pause: Duration(microseconds: 2000),
                              isRepeatingAnimation: false,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8.0),
            child: !isUserMessage && isRefresh
                ? CircularIconButton(
                    icon: Icons.refresh,
                    backgroundColor: const Color(0xFF4968FF),
                    onPressed: () {
                      onRefresh(index);
                    },
                    height: 30,
                    width: 30,
                    iconSize: 20,
                    iconColor: Colors.white,
                    isEnabled: true,
                  )
                : const SizedBox(),
          ),
        ],
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SpinKitWave(
            color: Color(0xFF7356E8),
            size: 20.0,
          ),
          SizedBox(width: 10),
          Text(
            'Typing...',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 20,
                color: Color(0xFF9999999E)),
          ),
        ],
      ),
    );
  }
}
