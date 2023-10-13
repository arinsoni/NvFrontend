import 'package:flutter/material.dart';
import 'package:nvsirai/widgets/circularIconButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Import the HTTP package for making API requests
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  String originalMessage = "";
  String audio_url = "";

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.setUrl(audio_url);
    _audioPlayer.play();
  }

  // fetch api response from server
  Future<Map<String, dynamic>> fetchResponseFromAPI(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/process_query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_input': userInput}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to load response: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to make the API request: $e');
    }
  }

  // send user inout to server
  void _sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      setState(() {
        audio_url = ''; // Clear the audio URL when a new message is sent
        if (originalMessage.isNotEmpty) {
          // Replace the original message with the edited one
          print("All messages $messages");
         
         if (originalMessage.isNotEmpty) {
          // Find the index of the original user message
          int index = messages.indexWhere((m) => m['text'] == originalMessage && m['sender'] == 'user');
          
          if (index != -1 && index - 1 >= 0 && messages[index - 1]['sender'] == 'server') {
            // Remove the server’s response associated with the original user message
            messages.removeAt(index - 1);
          }
         }

          for (var i = 0; i < messages.length; i++) {
            if (messages[i]['text'] == originalMessage) {
              messages[i]['text'] = message;
              break;
            }
          }
          originalMessage = ""; // Clear the original message
        } else {
          messages.insert(0, {'text': message, 'sender': 'user'});
        }
        _messageController.clear();
      });

      Map<String, dynamic> apiResponse = await fetchResponseFromAPI(message);
      print(apiResponse);
      setState(() {
        messages.insert(0, {
          'text': apiResponse['text_response'],
          'sender': 'server',
          'audio': apiResponse['audio_response'] ?? null
        });
        if (apiResponse['audio_response'] != null) {
          print("Old Audio URL: $audio_url"); // Add this line
          audio_url = apiResponse['audio_response'];
          print("New Audio URL: $audio_url"); // Add this line
          // _playAudio();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey,
            size: 40,
          ),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/logo.svg',
              width: 40.0,
              height: 40.0,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NV.AI',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Goldman',
                    color: Color(0xFF7356E8),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Container(
                          width: 8.0, // Adjust the width as needed
                          height: 8.0, // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Create a circular shape
                            color: Colors
                                .green, // Set the background color to green
                          )),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              'assets/svg/history.svg',
              width: 20.0,
              height: 20.0,
              colorFilter: ColorFilter.mode(Color(0xFF4E4E4E), BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: ListView.builder(
                  itemCount: messages.length,
                  controller: _scrollController,
                  reverse: true, // Add this to reverse the order of messages
                  itemBuilder: (context, index) {
                    return _buildMessageContainer(messages[index]);
                  },
                ),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Stack(children: [
      Container(
        color: Colors.white, // Your overlay color
      ),
      Container(
          padding: EdgeInsets.only(left: 8.0, right: 8, top: 8),
          decoration: BoxDecoration(
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
                  backgroundColor: Color(0xFF7356E8),
                  onPressed: () {},
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.transparent,
                        border: Border.all(color: Color(0x62000000)),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 100.0, // Set the maximum height you want
                      ),
                      child: Stack(
                        children: <Widget>[
                          ListView(
                            shrinkWrap: true,
                            children: [
                              TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  contentPadding:
                                      EdgeInsets.only(left: 16.0, right: 48.0),
                                  border: InputBorder.none,
                                ),
                                maxLines:
                                    null, // Allow the TextField to grow in height
                                onSubmitted: (message) {
                                  _sendMessage();
                                },
                              ),
                            ],
                          ),
                          Positioned(
                            right: 8.0,
                            top: 8.0,
                            bottom: 8.0,
                            child: IconButton(
                              icon: Icon(Icons.mic),
                              color: Colors.grey,
                              onPressed: () {
                                _sendMessage();
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
                    colorFilter: ColorFilter.mode(
                      Color(0xFF7356E8),
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'A red up arrow',
                  ),
                  onPressed: () {
                    _sendMessage(); // Call _sendMessage with the message
                  },
                ),
              ],
            )
          ]))
    ]);
  }

  Widget _buildMessageContainer(Map<String, dynamic> message) {
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
                // Edit the user's message
                setState(() {
                  originalMessage = message['text'];
                  _messageController.text = originalMessage;
                });
              }
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 0, bottom: 8),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          decoration: BoxDecoration(
            color: isUserMessage ? Color(0xFF7356E8) : Color(0xFFDFDFF4),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: isUserMessage ? Radius.circular(16) : Radius.circular(0),
              bottomLeft: Radius.circular(16),
              bottomRight:
                  isUserMessage ? Radius.circular(0) : Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              if (message['audio'] != null && message['audio'].isNotEmpty)
                AudioPlayerWidget(key: UniqueKey(), url: message['audio']),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
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

class CustomCupertinoIcons {
  static const IconData paperplane = IconData(0xf733,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);
}

class ChatMessage {
  final String id; // Unique identifier for each message
  final String text;
  final bool isUserMessage;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUserMessage,
  });
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  _initAudioPlayer() async {
    await _audioPlayer.setUrl(widget.url);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateAudioPlayer(String newUrl) async {
    await _audioPlayer.dispose();
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(newUrl);
    _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _audioPlayer.durationStream
                  .where((duration) => duration != null)
                  .cast<Duration>(),
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return ProgressBar(
                  progress: position,
                  total: duration,
                  onSeek: (duration) {
                    _audioPlayer.seek(duration);
                  },
                );
              },
            );
          },
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
          },
        ),
      ],
    );
  }
}
