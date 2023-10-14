import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nvsirai/widgets/message_container.dart';
import 'package:nvsirai/widgets/message_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart'
    as http; 
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

  void _sendMessage() async {
    if (isLoading) {
      return;
    }

    String message = _messageController.text.trim();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
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
              colorFilter:
                  const ColorFilter.mode(Color(0xFF4E4E4E), BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Container(
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
                  itemCount:
                      messages.length + (isLoading ? 1 : 0), 
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
                      onRefresh:
                          _refreshMessage, 
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
            )
          ],
        ),
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

  void _refreshMessage(int index) async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String message =
        messages[index + 1]['text']; 

    setState(() {
      messages.removeAt(index);
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
