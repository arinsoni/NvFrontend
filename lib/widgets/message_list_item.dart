

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageListItem extends StatefulWidget {
  final String message;
  final bool isFavorite;
  final Function() onTap;
  final String userId;
  final String threadId;
  final Function() onDelete;

  const MessageListItem({
    required this.message,
    required this.isFavorite,
    Key? key,
    required this.onTap,
    required this.userId,
    required this.threadId,
    required this.onDelete,
  }) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  late bool isFavorite;
  
  get http => null;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  Future<void> _updateFavorite(bool favStatus) async {
    print('Updating favorite thread status...');
    String HOST = dotenv.env['HOST']!;
    try {
      var response = await http.post(
        Uri.parse(
            '${HOST}/update-favorite-thread'),
        body: jsonEncode({
          'userId': widget.userId,
          'threadId': widget.threadId,
          'isFavorite': favStatus,
        }),
        headers: {"Content-Type": "application/json"},
      );

      var data = json.decode(response.body);
      print('Response from backend: $data');
      if (data['success']) {
        setState(() {
          isFavorite = favStatus;
        });
      } else {
        print('Error updating favorite status: ${data['error']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _updateFavorite(!isFavorite);
            });
          },
        ),
        title: Text(widget.message),
        trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red, // You can choose your own color
            ),
            onPressed: widget.onDelete),
      ),
    );
  }
}
