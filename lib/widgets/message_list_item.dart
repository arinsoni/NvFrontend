import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageListItem extends StatefulWidget {
  final String message;
  final bool isFavorite;
  final Function() onTap;
  final String userId;
  final String threadId;
  final Function() onDelete;
  final Function() fetchThreads;

  const MessageListItem({
    required this.message,
    required this.isFavorite,
    Key? key,
    required this.onTap,
    required this.userId,
    required this.threadId,
    required this.onDelete,
    required this.fetchThreads,
  }) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavorite;
  }

  Future<void> _updateFavorite(bool favStatus) async {
    print('Updating favorite thread status... to $favStatus');
    String HOST = dotenv.env['HOST']!;

    var response = await http.post(
      Uri.parse('${HOST}/update-favorite-thread'),
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
      widget.fetchThreads();
      setState(() {
        isFav = !isFav;
      });
    } else {
      print('Error updating favorite status: ${data['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(25),
            topLeft: const Radius.circular(25),
            bottomLeft: const Radius.circular(25),
            bottomRight: const Radius.circular(0),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rate_rounded : Icons.star_border_rounded,
                color: isFav ?  Colors.red : Colors.grey,
                size: 25,
              ),
              onPressed: () async {
                await _updateFavorite(!isFav);
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.message,
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
