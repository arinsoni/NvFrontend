import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:nvsirai/widgets/message_container.dart';
import 'package:nvsirai/widgets/message_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isFavorite = false;

  String userId = '';
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('user_id');
    if (id == null) {
      var random = Random();
      var values = List<int>.generate(12, (i) => random.nextInt(256));
      id = base64UrlEncode(values);
      await prefs.setString('user_id', id);
    }
    setState(() {
      userId = id!;
    });
  }

  Future<void> deleteAllAudioFiles() async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/delete-audios'),
    );

    if (response.statusCode == 200) {
      print('All audio files deleted successfully');
    } else {
      throw Exception('Failed to delete audio files');
    }
  }

  Future<Map<String, dynamic>> fetchResponseFromAPI(
      String userInput, String userId, DateTime timestamp) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/process_query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_input': userInput,
          'userId': userId,
          'timestamp': timestamp.toIso8601String(),
        }),
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
      DateTime now = DateTime.now();

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
          messages.insert(0, {
            'text': message,
            'sender': 'user',
            'favorite': false,
            'timestamp': now,
            'userId': userId,
          });
        }

        _messageController.clear();
        isLoading = true;
      });

      // await Future.delayed(Duration(seconds: 2));

      Map<String, dynamic> apiResponse =
          await fetchResponseFromAPI(message, userId, now);
      now = DateTime.now();
      setState(() {
        messages.insert(0, {
          'text': apiResponse['text_response'],
          'sender': 'server',
          'audio': apiResponse['audio_response'],
          'timestamp': now
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
    DateTime now = DateTime.now();

    setState(() {
      messages.removeAt(index);
      isLoading = true;
    });

    Map<String, dynamic> apiResponse =
        await fetchResponseFromAPI(message, userId, now);

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

  Future<List<Map<String, dynamic>>> fetchMessages(String userId) async {
    if (userId != null) {
      print("UserId: $userId");
      var url = Uri.parse('http://127.0.0.1:5000/get_messages/$userId');
      print("URL: $url");

      try {
        final response =
            await http.get(url, headers: {'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data is List) {
            return data.map((message) {
              if (message is Map<String, dynamic>) {
                print(message);
                return message;
              } else {
                throw Exception('Data format is not as expected');
              }
            }).toList();
          } else {
            throw Exception('Response data is not a list');
          }
        } else {
          throw Exception(
              'Failed to load messages with status code getMsg ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Failed to make the API request for gteMsg: $e');
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String desc =
        "some response text here yes, count that as an answer. some response text here yes, count that as an answer. some response text here yes, ";
    final GlobalKey imageKey = GlobalKey();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      // key: _scaffoldKey,
      endDrawer: _buildHistoryDrawer(),

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
          Builder(
            builder: (context) => Padding(
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
                  onPressed: () => Scaffold.of(context).openEndDrawer()),
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
          ),
          if (!isFirstMessageSent)
            SingleChildScrollView(
              child: Padding(
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
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed))
                                        return Colors.transparent;
                                      return null;
                                    }),
                                    minimumSize:
                                        MaterialStateProperty.all(Size(10, 40)),
                                    maximumSize: MaterialStateProperty.all(
                                        Size(200, 40)),
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
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(mColor),
                                    elevation: MaterialStateProperty.all(0),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed))
                                        return Colors.transparent;
                                      return null;
                                    }),
                                    minimumSize:
                                        MaterialStateProperty.all(Size(10, 40)),
                                    maximumSize: MaterialStateProperty.all(
                                        Size(200, 40)),
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
            ),
          Container(
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

  Widget _buildHistoryDrawer() {
    if (userId.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    print("1st come here ");
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMessages(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading messages '));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages found'));
        } else {
          List<Map<String, dynamic>> userMessages =
              snapshot.data!.map((message) {
            if (message['timestamp'] != null) {
              message['timestamp'] = DateTime.parse(message['timestamp']);
            }
            return message;
          }).toList();

          print("userMessages : $userMessages");

          return Container(
            margin: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).padding.top, 0, 0),
            child: Drawer(
              child: AbsorbPointer(
                absorbing: false,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFF7356E8),
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7356E8),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(50),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, bottom: 10),
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.close, color: Colors.white),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    splashRadius: 1,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Chat History',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'Goldman',
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(50, 0, 30, 0),
                                      child: Divider(
                                        thickness: 1,
                                        color: Color(0xFF878787),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: userMessages.length,
                          itemBuilder: (context, index) {
                            // DateTime messageTime = DateTime.parse(
                            //     userMessages[index]['message']['timestamp']);

                            // print("message Time: ${messageTime.day}");
                            print(
                                "debugging time: ${userMessages[index]['message']['timestamp']}");


                            DateTime messageTime = DateTime.parse(
                                userMessages[index]['message']['timestamp']
                                    .toString());
                                    DateTime currentDate = DateTime.now();

                            print("Parsed message time: ${DateTime.parse(
                                userMessages[index]['message']['timestamp']
                                    .toString()).day}");
                            

                            

                            bool isToday = messageTime.day ==
                                    currentDate.day &&
                                messageTime.month ==
                                    currentDate.month &&
                                messageTime.year ==
                                    currentDate.year;
                            print("checking bool: $isToday");

                            String timestampHeading = isToday
                                ? 'Today'
                                : DateFormat('MMMM yyyy').format(messageTime);

                            if (index == 0 ||
                                messageTime.day !=
                                    DateTime.parse(
                                userMessages[index]['message']['timestamp']
                                    .toString()).day ||
                                messageTime.month !=
                                     DateTime.parse(
                                userMessages[index]['message']['timestamp']
                                    .toString()).month) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 8.0, 0, 8.0),
                                    child: Text(
                                      timestampHeading,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  
                                  MessageListItem(
                                    message: userMessages[index]['message'],
                                    isFavorite: userMessages[index]
                                            ['favorite'] ??
                                        false,
                                  ),
                                ],
                              );
                            } else {
                              return MessageListItem(
                                message: userMessages[index]['message'],
                                isFavorite:
                                    userMessages[index]['favorite'] ?? false,
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class MessageListItem extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isFavorite;

  const MessageListItem(
      {required this.message, required this.isFavorite, Key? key})
      : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          setState(() {
            isFavorite = !isFavorite;
          });
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
        ),
      ),
      title: Text(widget.message['input']),
    );
  }
}
