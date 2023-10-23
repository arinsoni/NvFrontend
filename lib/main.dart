import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:nvsirai/schema/message.dart';
import 'package:nvsirai/widgets/loading_indicator.dart';
import 'package:nvsirai/widgets/message_container.dart';
import 'package:nvsirai/widgets/message_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:nvsirai/widgets/message_list_item.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'schema/thread.dart';

Future<void> main() async {
  await dotenv.load();
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
  // Schemas
  final List<Message> messages = [];
  List<Thread> threads = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // initiallization
  String originalMessage = "";
  String audioUrl = "";
  String userId = '';
  String currentThreadId = '';
  String currentThreadName = '';
  bool isLoading = false;
  bool isFirstMessageSent = false;
  bool isFavorite = false;
  late bool isFav;

  String HOST = dotenv.env['HOST']!;
  DateTime threadTimestamp = DateTime.now();

  Color qColor = Color.fromARGB(255, 248, 208, 134).withOpacity(1);
  Color mColor = Colors.transparent;

  bool isFetching = true;
  bool isNewThread = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // key: _scaffoldKey,
      endDrawer: _buildHistoryDrawer(),

      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            height: 20,
            width: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nvsir.png',
              width: 30.0,
              height: 30.0,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
                const Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF595959),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                        width: 1.2,
                        color: Color(0xFFE1D6FF).withOpacity(0.45))),
                child: GestureDetector(
                  onTap: () {
                    !isLoading ? Scaffold.of(context).openEndDrawer() : "";
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/svg/history.svg',
                          width: 12.0,
                          height: 14.0,
                          colorFilter: !isLoading
                              ? const ColorFilter.mode(
                                  Color(0xFF4E4E4E),
                                  BlendMode.srcIn,
                                )
                              : const ColorFilter.mode(
                                  Color.fromARGB(255, 193, 191, 191),
                                  BlendMode.srcIn,
                                ),
                          semanticsLabel: 'A red up arrow',
                        ),
                        onPressed: () {
                          !isLoading
                              ? Scaffold.of(context).openEndDrawer()
                              : "";
                        },
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      Text(
                        "History",
                        style: TextStyle(
                          color: isLoading
                              ? Color.fromARGB(255, 193, 191, 191)
                              : Color(0xFF2D2D2D),
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: isFetching
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Stack(
              children: [
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFFEBEEFD),
                        ],
                      ),
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
                                return TypingIndicator();
                              }

                              int messageIndex = isLoading ? index - 1 : index;
                              print("\n");
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
                                isRefresh: messageIndex == 0 ? true : false,
                                isEditable: messageIndex == 1 ? true : false,
                                isLastMessage:
                                    messageIndex == messages.length - 1
                                        ? true
                                        : false,
                              );
                            },
                          ),
                        ),
                      ),
                      MessageInput(
                        messageController: _messageController,
                        sendMessage: mySendMessageFunction,
                        onAddIconPressed: () {
                          print("Add button pressed");
                          setState(() {
                            _generateNewThreadId();
                            print("New thread ID generated: $currentThreadId");
                            print(threads);
                            // threads.add(currentThreadId);
                            print("Current threads: $threads");
                            messages.clear();
                          });
                          print("State set");
                        },
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
                !isFirstMessageSent
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: IntrinsicWidth(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                width: 3,
                                                color: qColor,
                                              ),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1.2,
                                                    color: Color(0xFFE1D6FF)
                                                        .withOpacity(0.45)),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFF9EE),
                                                    Color(0xFFFFEFD0)
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  end: Alignment.centerLeft,
                                                  begin: Alignment.centerRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                children: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent),
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all(0),
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color?>((Set<
                                                                      MaterialState>
                                                                  states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .pressed))
                                                          return Colors
                                                              .transparent;
                                                        return null;
                                                      }),
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(10, 40)),
                                                      maximumSize:
                                                          MaterialStateProperty
                                                              .all(Size(
                                                                  200, 40)),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        qColor = Color.fromARGB(
                                                                255,
                                                                248,
                                                                208,
                                                                134)
                                                            .withOpacity(1);
                                                        mColor =
                                                            Colors.transparent;
                                                      });
                                                    },
                                                    child: Text(
                                                      'Questions',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF4E4E4E),
                                                          fontSize: (0.025 *
                                                                  screenWidth)
                                                              .clamp(12, 24)
                                                              .toDouble(),
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    'assets/images/atom.png',
                                                    width: 18,
                                                    height: 18,
                                                    color: Color.fromARGB(
                                                        255, 247, 211, 143),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                              child: SizedBox(
                                            width: 20,
                                          )),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  width: 3, color: mColor),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(
                                                        0xFFFFBCD4), // #FFBCD4
                                                    Color(
                                                        0xFFFFF3F8), // #FFF3F8
                                                  ],
                                                  stops: [
                                                    0,
                                                    1,
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                children: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent),
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all(0),
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color?>((Set<
                                                                      MaterialState>
                                                                  states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .pressed))
                                                          return Colors
                                                              .transparent;
                                                        return null;
                                                      }),
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(10, 40)),
                                                      maximumSize:
                                                          MaterialStateProperty
                                                              .all(Size(
                                                                  200, 40)),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        mColor =
                                                            Color(0xFFFFBCD4)
                                                                .withOpacity(1);
                                                        qColor =
                                                            Colors.transparent;
                                                      });
                                                    },
                                                    child: Text(
                                                      'Motivation',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF4E4E4E),
                                                          fontSize: (0.025 *
                                                                  screenWidth)
                                                              .clamp(12, 24)
                                                              .toDouble(),
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    'assets/images/motivation.png',
                                                    width: 20,
                                                    height: 20,
                                                    color: Color(0xFFFEB1CD),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
    );
  }

  Widget _buildHistoryDrawer() {
    if (userId.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    Map<String, List<Thread>> threadsByDate = organizeThreadsByDate(threads);

    print("length: ${threadsByDate.keys.length}");

    return Drawer(
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
                            padding:
                                const EdgeInsets.only(right: 10.0, bottom: 10),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
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
                  itemCount: threadsByDate.keys.length,
                  itemBuilder: (context, index) {
                    String date =
                        threadsByDate.keys.toList().elementAt(index);
                    DateTime currentDate = DateTime.now();
                    DateTime threadTimestamp = DateTime.parse(date);
                    int daysDifference =
                        currentDate.difference(threadTimestamp).inDays;

                    // Define the section text based on days difference
                    String sectionText;
                    if (daysDifference == 0) {
                      sectionText = 'Today';
                    } else if (daysDifference == 1) {
                      sectionText = 'Yesterday';
                    } else if (daysDifference == 2) {
                      sectionText = '2 Days Ago';
                    } else {
                      sectionText =
                          DateFormat('MMMM dd, yyyy').format(threadTimestamp);
                    }

                    List<Thread> threadsForDate = threadsByDate[date]!;

                    // print("timestamp debuggggg: $date and $threadsForDate");

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            sectionText,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: "SourceCodePro"),
                          ),
                        ),
                        ...threadsForDate.reversed.map((thread) {
                          String threadName = thread.threadName;
                          String threadId = thread.threadId;
                          bool isFavorite = thread.isFavorite;
                          isFav = isFavorite;
                          print("fav debug: $thread");

                          return MessageListItem(
                            message: threadName,
                            userId: userId,
                            threadId: threadId,
                            isFavorite: isFavorite,
                            onDelete: () {
                              _deleteThread(threadId);
                              messages.clear();
                            },
                            onTap: () {
                              setState(() {
                                currentThreadId = threadId;
                                currentThreadName = threadName;
                                messages.clear();
                                Navigator.of(context).pop();
                              });

                              fetchMessages(userId, threadId)
                                  .then((fetchedMessages) {
                                setState(() {
                                  messages.addAll(fetchedMessages
                                      .map((messageData) {
                                        Message inputMessage = Message(
                                          text: messageData['input'],
                                          sender: 'user',
                                          timestamp: DateTime.parse(
                                              messageData['timestamp']),
                                          userId: userId,
                                        );

                                        Message outputMessage = Message(
                                          text: messageData['output'],
                                          sender: 'server',
                                          timestamp: DateTime.parse(
                                              messageData['timestamp']),
                                          userId: userId,
                                          audioUrl: messageData['audioUrl'],
                                        );

                                        return [inputMessage, outputMessage];
                                      })
                                      .expand((pair) => pair)
                                      .toList()
                                      .reversed);
                                  isFetching = false;
                                });
                              }).catchError((error) {
                                print('Error fetching messages: $error');
                              });
                            },
                            fetchThreads: () {
                              _fetchThreads();
                            },
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                    _generateNewThreadId();
                    print("New thread ID generated: $currentThreadId");
                    print(threads);
                    print("Current threads: $threads");
                    messages.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFEBEEFD),
                  elevation: 0,
                  padding: EdgeInsets.all(2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  ' + ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isFetching = true;

    _generateNewThreadId();
    _loadUserId().then((_) {
      _fetchThreads().then((_) {
        if (mounted) {
          setState(() {
            isFetching = false;
          });
        }
      });
    });
  }

  void _generateNewThreadId() {
    var random = Random();
    var values = List<int>.generate(12, (i) => random.nextInt(256));
    currentThreadId = base64UrlEncode(values);
  }

  Future<void> _fetchThreads() async {
    print("fetching threads...");

    var url = Uri.parse('${HOST}/$userId/get_threads');
    print("API URL: $url");
    print("userID: $userId");

    var response = await http.get(url);
    print("fetch threads:  ${response.body}");
    if (response.statusCode == 200) {
      print("API response status code: 200");

      var data = json.decode(response.body);
      print("data fetched by fetchThreads: $data");

      if (data is List) {
        setState(() {
          threads = data.map<Thread>((thread) {
            print("Raw thread data: ${thread.runtimeType}");

            if (thread is Map<String, dynamic>) {
              print('threadId: ${thread['threadId']}');
              print('threadName: ${thread['threadName']}');
              print('isFavorite: ${thread['isFavorite']}');
              print('lastMessageTimestamp: ${thread['lastMessageTimestamp']}');
              return Thread.fromMap(thread);
            } else {
              throw Exception('Invalid thread data');
            }
          }).toList();

          print("threads fetched: ${threads}");
        });
      } else {
        print("Unexpected data format received");
      }
    } else {
      print("API response status code: ${response.statusCode}");
    }
  }

  Map<String, List<Thread>> organizeThreadsByDate(List<Thread> threads) {
    Map<String, List<Thread>> organized = {};

    for (var thread in threads) {
      DateTime lastMessageDate = DateTime.parse(thread.threadTimestamp);
      String dateKey = DateFormat('yyyy-MM-dd').format(lastMessageDate);

      if (organized[dateKey] == null) {
        organized[dateKey] = [];
      }
      organized[dateKey]!.add(thread);
    }

    return organized;
  }

  Future<bool> deleteThread(userId, threadId) async {
    try {
      print("mi gai $threadId");
      var response = await http.post(
        Uri.parse('${HOST}/delete_thread'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'threadId': threadId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete thread: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while deleting thread: $e');
      return false;
    }
  }

  void _deleteThread(String threadId) async {
    bool isDeleted = await deleteThread(userId, threadId);

    if (isDeleted) {
      setState(() {
        threads.removeWhere((thread) => thread.threadId == threadId);
        Navigator.of(context).pop();
      });
      print('Thread deleted successfully');
    } else {
      print('Failed to delete the thread');
    }
  }

  Future<void> _loadUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('user_id');
      if (id == null) {
        var random = Random();
        var values = List<int>.generate(12, (i) => random.nextInt(256));
        id = base64UrlEncode(values);
        await prefs.setString('user_id', id);
      }

      if (mounted) {
        // Ensure the widget is still in the tree
        setState(() {
          userId = id!;
          isFetching = true; // Update this based on when you need it
        });
      }
    } catch (e) {
      print('Error loading user ID: $e');
      setState(() {
        isFetching = true; // Ensure the UI isn't locked in a loading state
      });
    }
  }

  Future<void> deleteAllAudioFiles() async {
    final response = await http.delete(
      Uri.parse('${HOST}/delete-audios'),
    );

    if (response.statusCode == 200) {
      print('All audio files deleted successfully');
    } else {
      throw Exception('Failed to delete audio files');
    }
  }

  Future<Map<String, dynamic>> fetchResponseFromAPI(String userInput,
      String userId, DateTime timestamp, bool isFirstMessageSent) async {
    print("userid in process enq: $userId");
    try {

      final response = await http.post(
        Uri.parse('${HOST}/$userId/process_query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_input': userInput,
          'userId': userId,
          'timestamp': timestamp.toIso8601String(),
          'threadId': currentThreadId,
          'isFirstMessageSent': isFirstMessageSent,
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

    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      DateTime now = DateTime.now();

      print("All messages ${messages}");
      setState(() {
        // audioUrl = '';

        if (originalMessage.isNotEmpty) {
          int index = messages.indexWhere(
              (m) => m.text == originalMessage && m.sender == 'user');

          print("index $index");

          if (index != -1) {
            deleteMessage(userId, currentThreadId, index);
            messages[index].text = messageText;

            if (index - 1 >= 0 && messages[index - 1].sender == 'server') {
              messages.removeAt(index - 1);
            }
          }

          originalMessage = "";
        } else {
          Message message = Message(
            text: messageText,
            sender: 'user',
            timestamp: now,
            userId: userId,
            threadId: currentThreadId,
          );
          messages.insert(0, message);
          if (messages.isNotEmpty) {
            isFirstMessageSent = true;
          }
          _messageController.clear();
          isLoading = true;
        }

        _messageController.clear();
        isLoading = true;
      });

      Map<String, dynamic> apiResponse = await fetchResponseFromAPI(
          messageText, userId, now, isFirstMessageSent);
      now = DateTime.now();

      Message responseMessage = Message(
        text: apiResponse['text_response'],
        sender: 'server',
        timestamp: now,
        userId: userId,
        audioUrl: apiResponse['audio_response'],
      );

      Thread? matchingThread;
      for (var thread in threads) {
        if (thread.threadId == currentThreadId) {
          matchingThread = thread;
          break;
        }
      }

      if (matchingThread != null) {
        print('Matching Thread Data: $matchingThread');
      } else {
        print('No matching thread data found.');
        _fetchThreads();
      }

      setState(() {
        messages.insert(0, responseMessage);
        isLoading = false;
      });
    }
  }

  Future<void> deleteMessage(String userId, String threadId, int index) async {
    // }
    try {
      var response = await http.post(
        Uri.parse('${HOST}/delete_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'threadId': threadId,
          'index': index,
        }),
      );

      if (response.statusCode == 200) {
        print('Message deleted successfully');
      } else {
        print('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while deleting message: $e');
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

    Message messageToRefresh = messages[index + 1];
    deleteMessage(userId, currentThreadId, index);
    DateTime now = DateTime.now();

    setState(() {
      messages.removeAt(index);
      isLoading = true;
    });

    Map<String, dynamic> apiResponse = await fetchResponseFromAPI(
        messageToRefresh.text, messageToRefresh.userId, now, false);

    Message refreshedMessage = Message(
        text: apiResponse['text_response'],
        sender: 'server',
        timestamp: now,
        userId: messageToRefresh.userId,
        audioUrl: apiResponse['audio_response']);

    setState(() {
      messages.insert(0, refreshedMessage);

      if (apiResponse['audio_response'] != null) {
        audioUrl = apiResponse['audio_response'];
      }

      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String userId,
      [String? threadId]) async {
    if (userId != null) {
      print("UserId: $userId");
      var url = Uri.parse('${HOST}/get_messages/$userId/$threadId');
      print("URL: $url");

      try {
        final response =
            await http.get(url, headers: {'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data is Map<String, dynamic> && data['messages'] is List) {
            return List.from(data['messages']);
          } else {
            throw Exception('Response data is not in expected format');
          }
        } else {
          throw Exception('Failed to load messages from the server');
        }
      } catch (e) {
        throw Exception('Failed to make the API request for gteMsg: $e');
      }
    } else {
      return [];
    }
  }
}
