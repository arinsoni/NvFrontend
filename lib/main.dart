import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:nvsirai/constants/constants.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;

    // final GlobalKey imageKey = GlobalKey();

    return SafeArea(
      child: Scaffold(
        // key: _scaffoldKey,
        endDrawer: _buildHistoryDrawer(),

        appBar: AppBar(
          elevation: 0, // Removes shadow
          backgroundColor: Colors.white,
          title: Row(
            children: [
              // Start of Row content
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
                    'NV.AI',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'SourceSansPro',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                  const Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'SourceSansPro',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595959),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 3),
              GestureDetector(
                onTap: () {
                  !isLoading
                      ? (setState(() {
                          _generateNewThreadId();
                          _messageController.clear();
                          messages.clear();
                          isFirstMessageSent = false;
                        }))
                      : " ";
                },
                child: Image.asset(
                  "assets/images/newChat.png", height: 100.0, // Set the height
                  width: 90.0, // Set the width
                ),
              ),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: GestureDetector(
                  onTap: () {
                    !isLoading ? Scaffold.of(context).openEndDrawer() : "";
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/hamburger.png',
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: () {
                          !isLoading
                              ? Scaffold.of(context).openEndDrawer()
                              : "";
                        },
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        body: isFetching
            ? Center(child: CircularProgressIndicator(color: Colors.red))
            : Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: double.infinity, // or a specific width
                    height: double.infinity, // or a specific height
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Opacity(
                            opacity:
                                1, // Adjust this value (0.0 to 1.0) to your preference
                            child: Image.asset(
                              'assets/images/bg_color.png',

                              fit: BoxFit
                                  .cover, // This will scale the image to cover the container
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity:
                                1, // Adjust this value (0.0 to 1.0) to your preference
                            child: Image.asset(
                              'assets/images/bg.png',

                              fit: BoxFit
                                  .cover, // This will scale the image to cover the container
                            ),
                          ),
                        ),
                      ],
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

                                int messageIndex =
                                    isLoading ? index - 1 : index;
                                print("\n");
                                print("deletinf the index ${messageIndex}");
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
                              _messageController.clear();
                              print(
                                  "New thread ID generated: $currentThreadId");
                              print(threads);
                              // threads.add(currentThreadId);
                              print("Current threads: $threads");
                              messages.clear();
                              isFirstMessageSent = false;
                            });
                            print("State set");
                          },
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment
                                .topRight, // This is approximately 277 degrees
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFFFFF3F8),
                              Color(0xFFFFF2E6),
                            ],
                          ),
                        ),
                        height: 50,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Color(0xff2D2D2D),
                                size: 25,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              splashRadius: 1,
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                            ),
                            Text(
                              "Chat History",
                              style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: !isLoading ? AppColors.accentColor : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: !isLoading
                          ? Colors.transparent
                          : Colors.grey, // Makes the button transparent
                      shadowColor: !isLoading
                          ? Colors.transparent
                          : Colors.grey, // Removes any shadow (elevation)
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      !isLoading
                          ? (setState(() {
                              _generateNewThreadId();
                              _messageController.clear();
                              messages.clear();
                              isFirstMessageSent = false;
                              Navigator.of(context).pop();
                            }))
                          : " ";
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add,
                            color: !isLoading
                                ? Colors.black
                                : Colors
                                    .grey), // Change to your desired icon color
                        SizedBox(width: 8), // Gap between the icon and text
                        Text("New Chat",
                            style: TextStyle(
                                color: Colors
                                    .black)), // Change to your desired text style
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: threadsByDate.keys.length,
                  itemBuilder: (context, index) {
                    String date =
                        threadsByDate.keys.toList().reversed.elementAt(index);
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

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  sectionText,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: "SourceCodePro",
                                      color: Color(0xff707070)),
                                ),
                              ],
                            ),
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
                              if (currentThreadId == threadId) {
                                messages.clear();
                              }
                            },
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                currentThreadId = threadId;
                                currentThreadName = threadName;
                                messages.clear();
                                isFirstMessageSent = true;
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
              Container(
                child: Divider(
                  thickness: 1,
                  color: Color(0xFF878787),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/footer.png',
                    width: 200,
                    height: 80,
                  ),
                ],
              ),
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
        _checkAndHandleUserLimit();
        if (mounted) {
          setState(() {
            isFetching = false;
          });
        }
      });
    });
  }

  Future<bool> checkUserLimit(String userId) async {
    try {
      final response = await http.get(Uri.parse('${HOST}/$userId/users'));
      if (response.statusCode == 200) {
        // User limit not reached
        return true;
      } else if (response.statusCode == 403) {
        // User limit reached
        return false;
      } else {
        // Handle other statuses or errors
        throw Exception('Failed to check user limit');
      }
    } catch (e) {
      throw Exception('Error checking user limit: $e');
    }
  }

  void _checkAndHandleUserLimit() async {
    bool isLimitNotReached = await checkUserLimit(userId);
    if (!isLimitNotReached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLimitReachedDialog();
      });
    }
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Limit Reached"),
          content: Text(
              "The maximum number of users has been reached. You cannot send more messages at this time."),
          // actions: <Widget>[
          //   ElevatedButton(
          //     child: Text("OK"),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
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
        // Navigator.of(context).pop();
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
    print("deleting");
    deleteMessage(userId, currentThreadId, index);
    print("deleted");
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
