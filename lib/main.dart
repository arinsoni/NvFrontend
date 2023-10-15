import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nvsirai/widgets/message_container.dart';
import 'package:nvsirai/widgets/message_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NVSirAI());
}

class NVSirAI extends StatelessWidget {
  const NVSirAI({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  String originalMessage = "";
  String audioUrl = "";
  bool isLoading = false;
  bool isFirstMessageSent = false;
  late Color qColor = Colors.transparent;
  late Color mColor = Colors.transparent;

  Future<void> deleteAllAudioFiles() async {
    final response = await http.delete(
      Uri.parse('https://arinsoni.pythonanywhere.com/delete-audios'),
    );

    if (response.statusCode == 200) {
      print('All audio files deleted successfully');
    } else {
      throw Exception('Failed to delete audio files');
    }
  }

  Future<Map<String, dynamic>> fetchResponseFromAPI(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('https://arinsoni.pythonanywhere.com/process_query'),
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

  void _sendMessage() async {
    if (isLoading) {
      return;
    }

    String message = _messageController.text.trim();
    if (!isFirstMessageSent) {
      setState(() {
        isFirstMessageSent = true;
      });
    }

    if (message.isNotEmpty) {
      setState(() {
        audioUrl = '';

        if (originalMessage.isNotEmpty) {
          int index = messages.indexWhere(
              (m) => m['text'] == originalMessage && m['sender'] == 'user');

          if (index != -1) {
            messages[index]['text'] = message;
            if (index - 1 >= 0 && messages[index - 1]['sender'] == 'server') {
              messages.removeAt(index - 1);
            }
          }

          originalMessage = "";
        } else {
          messages.insert(0, {'text': message, 'sender': 'user'});
        }

        _messageController.clear();
        isLoading = true;
      });

      await Future.delayed(Duration(seconds: 2));

      Map<String, dynamic> apiResponse = await fetchResponseFromAPI(message);
      setState(() {
        messages.insert(0, {
          'text': apiResponse['text_response'],
          'sender': 'server',
          'audio': apiResponse['audio_response']
        });

        if (apiResponse['audio_response'] != null) {
          audioUrl = apiResponse['audio_response'];
        }

        isLoading = false;
      });
    }
  }

  void mySendMessageFunction(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  void _refreshMessage(int index) async {
    if (isLoading) {
      return;
    }

    String message = messages[index + 1]['text'];

    setState(() {
      messages.removeAt(index);
      isLoading = true;
    });

    Map<String, dynamic> apiResponse = await fetchResponseFromAPI(message);

    setState(() {
      messages.insert(0, {
        'text': apiResponse['text_response'],
        'sender': 'server',
        'audio': apiResponse['audio_response']
      });

      if (apiResponse['audio_response'] != null) {
        audioUrl = apiResponse['audio_response'];
      }

      isLoading = false;
    });
  }

  void _clearHistory() async {
    print('Clearing history');
    try {
      await deleteAllAudioFiles();
      print('Files deleted successfully');

      setState(() {
        messages.clear();
        isFirstMessageSent = false;
      });

      print('Messages cleared');
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  void _isQuestion() {
    setState(() {
       qColor = Color(0xFFDFDFF4);
       mColor = Colors.transparent;
    });
  }

  void _isMotivation() {
     setState(() {
       mColor = Color(0xFFDFDFF4);
       qColor = Colors.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String desc =
        "some response text here yes, count that as an answer. some response text here yes, count that as an answer. some response text here yes, ";
    final GlobalKey imageKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF4E4E4E),
            size: 40,
          ),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/logo.svg',
              width: 45.0,
              height: 45.0,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
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
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          )),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 14,
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
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/svg/history.svg',
                width: 20.0,
                height: 20.0,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF4E4E4E),
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'A red up arrow',
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      try {
                        await deleteAllAudioFiles();
                        _clearHistory();
                        print('Files deleted successfully');
                      } catch (e) {
                        print('Error deleting files: $e');
                      }
                    },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ListView.builder(
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      controller: _scrollController,
                      reverse: true,
                      itemBuilder: (context, index) {
                        if (isLoading && index == 0) {
                          return _buildLoadingIndicator();
                        }

                        int messageIndex = isLoading ? index - 1 : index;

                        return MessageContainer(
                          message: messages[messageIndex],
                          onEdit: (String text) {
                            setState(() {
                              _messageController.text = text;
                              originalMessage = text;
                            });
                          },
                          isLoading: isLoading && index == 0,
                          onRefresh: _refreshMessage,
                          index: messageIndex,
                        );
                      },
                    ),
                  ),
                ),
                MessageInput(
                  messageController: _messageController,
                  sendMessage: mySendMessageFunction,
                  onAddIconPressed: () {},
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
          if (!isFirstMessageSent)
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/logo_bg.svg',
                          width: 0.7 * screenWidth,
                          height: 0.4 * screenHeight,
                          key: imageKey,
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/logo_bg.svg',
                          width: 0.7 * screenWidth,
                          height: 0.4 * screenHeight,
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/NV.AI.svg',
                          width: 0.4 * screenWidth,
                          height: 0.06 * screenHeight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFDFDFF4),
                          width: 4.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(qColor),
                                  elevation: MaterialStateProperty.all(0),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed))
                                      return Colors.transparent;
                                    return null;
                                  }),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(10, 40)),
                                  maximumSize:
                                      MaterialStateProperty.all(Size(200, 40)),
                                ),
                                onPressed: () {
                                  _isQuestion();
                                },
                                child: Text(
                                  'Questions',
                                  style: TextStyle(
                                      color: Color(0xFF4E4E4E),
                                      fontSize: (0.045 * screenWidth)
                                          .clamp(12, 24)
                                          .toDouble(),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: ElevatedButton(
                                style:ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(mColor),
                                  elevation: MaterialStateProperty.all(0),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed))
                                      return Colors.transparent;
                                    return null;
                                  }),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(10, 40)),
                                  maximumSize:
                                      MaterialStateProperty.all(Size(200, 40)),
                                ),
                                onPressed: () {
                                  _isMotivation();
                                },
                                child: Text(
                                  'Motivation',
                                  style: TextStyle(
                                      color: Color(0xFF4E4E4E),
                                      fontSize: (0.045 * screenWidth)
                                          .clamp(12, 24)
                                          .toDouble(),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right: screenWidth * 0.1,
                        top: 10,
                        left: 0.1 * screenWidth),
                    child: Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF878787),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
