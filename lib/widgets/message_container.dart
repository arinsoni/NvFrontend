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
  final bool isLastMessage;

  const MessageContainer(
      {Key? key,
      required this.message,
      required this.onEdit,
      required this.isLoading,
      required this.index,
      required this.onRefresh,
      required this.isRefresh,
      required this.isEditable, required this.isLastMessage})
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
                      color: Color(0xffE3EAEB),
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
                          width: 15.0,
                          height: 15.0,
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
                    ?  Color(0xffEDEDED)
                    : const Color(0xFFFFECEC),
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
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isUserMessage ? Colors.black : Colors.black,
                        fontSize: 16,
                        fontFamily: "SourceSansPro",
                        fontWeight: FontWeight.w400
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
                ? Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffE3EAEB),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          onRefresh(index);
                        },
                        child: Image.asset(
                          'assets/images/refresh.png',
                          width: 15.0,
                          height: 15.0,
                        ),
                      ),
                    ),
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
            color: Color(0xFFB50503),
            size: 20.0,
          ),
          SizedBox(width: 10),
          Text(
            'Typing...',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 20,
                color: Color(0xFF9C9C9C)),
          ),
        ],
      ),
    );
  }
}
