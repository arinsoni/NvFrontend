import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'circularIcon_button.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
                    
                    Expanded(
                      child: Padding(
                        
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: const Color(0xFFFFFFFF),
                            
                          ),
                          constraints: const BoxConstraints(
                            maxHeight: 100.0,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                // Added this to ensure the text field only takes up available space
                                child: SingleChildScrollView(
                                  child: TextField(
                                    maxLength: 500,
                                    controller: widget.messageController,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: 'Send a message...',
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 124, 124, 124),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 16.0, right: 12.0),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                    onSubmitted: (message) {
                                      widget.sendMessage(message);
                                      print("in input ${widget.isLoading}");
                                    },
                                    enabled: !widget.isLoading,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.mic,
                                  color:
                                      _isListening ? Colors.blue : Colors.red,
                                ),
                                onPressed: _toggleListening,
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

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _toggleListening() async {
    if (_isListening) {
      print("its listening");
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      print("sun raha hai na tu");
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("status: ${status}");
          if (status == "notListening") {
            setState(() => _isListening = false);
            print("stt: ${_speech.lastRecognizedWords}");
            widget.messageController.text = _speech.lastRecognizedWords;
          }
        },
      );

      print("available: $available");
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (result) {
              print("result : ${result.recognizedWords}");
              widget.messageController.text = result.recognizedWords;
            },
            localeId: 'en_IN');
      }
    }
  }
}
