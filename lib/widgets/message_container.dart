import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nvsirai/constants/constants.dart';
import 'package:nvsirai/schema/message.dart';
import 'audio _ player.dart';
import 'package:http/http.dart' as http;

class MessageContainer extends StatefulWidget {
  // final Map<String, dynamic> message;
  final Function(String) onEdit;
  final bool isLoading;
  final Function(int) onRefresh;
  final Message message;
  final int index;
  final bool isRefresh;
  final bool isEditable;
  final bool isLastMessage;
  final String threadId;
  final String lastOutputMsgId;
  final String host;

  const MessageContainer(
      {Key? key,
      required this.message,
      required this.onEdit,
      required this.isLoading,
      required this.index,
      required this.onRefresh,
      required this.isRefresh,
      required this.isEditable,
      required this.isLastMessage,
      required this.threadId,
      required this.lastOutputMsgId, required this.host})
      : super(key: key);

  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  bool _thumbsUpSelected = false;
  bool _thumbsDownSelected = false;
  
  

  @override
  void initState() {
    super.initState();
     print("reaction dbug before : ${_thumbsUpSelected}");
    _thumbsUpSelected = widget.message.thumbsUp;
    _thumbsDownSelected = widget.message.thumbsDown;
       print("InitState - Thumbs Up: $_thumbsUpSelected, Thumbs Down: $_thumbsDownSelected");

  }

 

  void _toggleThumbsUp() {
    print("jo");
    print("message up id:   ${widget.message.msgId}");

    

    updateMessageReaction(widget.message.userId, widget.threadId,
            widget.message.msgId!, 'thumbsUp')
        .then((_) {
      setState(() {
        _thumbsUpSelected = !_thumbsUpSelected;
        _thumbsDownSelected = _thumbsUpSelected ? false : _thumbsDownSelected;
      });
    }).catchError((error) {
      print('Failed to update thumbs up: $error');
    });
  }

  void _toggleThumbsDown() {
    print("message down id:   ${widget.message.msgId!}");

    updateMessageReaction(widget.message.userId, widget.threadId,
            widget.message.msgId!, 'thumbsDown')
        .then((_) {
      setState(() {
        _thumbsDownSelected = !_thumbsDownSelected;
        _thumbsUpSelected = _thumbsDownSelected ? false : _thumbsUpSelected;
      });
    }).catchError((error) {
      print('Failed to update thumbs down: $error');
    });
  }

  Future<void> updateMessageReaction(String userId, String threadId,
      String messageId, String reactionType) async {
    String url =
        '${widget.host}/$userId/$threadId/messages/$messageId/react';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'reaction_type': reactionType,
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print('Reaction updated successfully');
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print('Failed to update reaction. Status code: ${response.statusCode}');
      }
    } catch (exception) {
      // If something went wrong with the POST request,
      // handle the exception.
      print('Failed to update reaction. Exception: $exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.message.sender == 'user') {
      print("Showing loading indicator...");
      return _buildLoadingIndicator();
    } else {
      // print("check : $isLoading");
      final isUserMessage = widget.message.sender == 'user';
      double screenWidth = MediaQuery.of(context).size.width;
      double maxWidth = isUserMessage ? screenWidth * 0.8 : screenWidth * 0.77;

      return Padding(
        padding:  EdgeInsets.only(right: isUserMessage ? 3 : 0),
        child: Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            
            Padding(
              padding:  EdgeInsets.only(bottom: 8.0, ),
              child: isUserMessage && widget.isEditable
                  ? Center(
                      child: GestureDetector(
                        onTap: () {
                          if (isUserMessage) {
                            widget.onEdit(widget.message.text);
                          }
                        },
                        child: Image.asset(
                          'assets/images/edit_refresh.png',
                          width: 80.0,
                          height: 80.0,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? AppColors.primaryColor
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
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Column(
                  children: [
                    if (widget.message.audioUrl != null &&
                        widget.message.audioUrl!.isNotEmpty)
                      AudioPlayerWidget(
                          key: UniqueKey(), url: widget.message.audioUrl!),
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(16, isUserMessage ? 8 : 2, 8, 8),
                      child: Text(
                        widget.message.text,
                        style: TextStyle(
                            color: isUserMessage ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontFamily: "SourceSansPro",
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                if (!isUserMessage && widget.isRefresh)
                  GestureDetector(
                    onTap: () {
                      widget.onRefresh(widget.index);
                    },
                    child: Image.asset(
                      'assets/images/bot_refresh.png',
                      width: 30.0,
                      height: 30.0,
                    ),
                  ),
                if (!isUserMessage)
                  Row(
            
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: _thumbsUpSelected ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _toggleThumbsUp,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          size: 15,
                          color: _thumbsDownSelected ? Colors.red : Colors.grey,
                        ),
                        
                        onPressed: _toggleThumbsDown,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
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
          SizedBox(width: 1),
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
