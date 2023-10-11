import 'package:flutter/material.dart';
import 'package:nvsirai/widgets/circularIconButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/cupertino.dart';

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
  final List<String> messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

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

  Widget _buildMessageContainer(String message) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.9;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            icon: Image.asset(
              'assets/images/edit.png',
              height: 20,
              width: 20,
            ),
            onPressed: () {},
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 0, bottom: 8),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          decoration: BoxDecoration(
            color: Color(0xFF7356E8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(16, 8, 8, 8), // Add padding to the right
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
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

  void _sendMessage() {
    String message = _messageController.text;
    // print("hello");
    // print(message);
    if (message.isNotEmpty) {
      setState(() {
        messages.insert(0, message); // Insert at the top
        _messageController.clear(); // Clear the input field
      });

      // // Scroll to the top
      // _scrollController.animateTo(
      //   _scrollController.position.minScrollExtent,
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
    }
  }
}

class CustomCupertinoIcons {
  static const IconData paperplane = IconData(0xf733,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);
}
