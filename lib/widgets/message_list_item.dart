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
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isFav ? Icons.star : Icons.star_border,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () async {
            await _updateFavorite(!isFav);
          },
        ),
        title: Text(widget.message),
        trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.grey,
            ),
            onPressed: widget.onDelete),
      ),
    );
  }
}
