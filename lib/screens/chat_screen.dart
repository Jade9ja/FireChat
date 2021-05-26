import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

bool isMe = true;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String message;

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('🔥Chat'),
        backgroundColor: Color(0xFF311b92),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageController.clear();
                      _firestore.collection('messages').add({
                        'text': message,
                        'sender': loggedInUser.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      // ignore: missing_return
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubbles> messageWidgets = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];
          final currentUser = loggedInUser.email;
          final messageWidget = MessageBubbles(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender);
          messageWidgets.add(messageWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubbles extends StatelessWidget {
  MessageBubbles({this.text, this.sender, this.isMe});
  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(sender,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12.0,
              )),
          Material(
            borderRadius: !isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0))
                : BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0)),
            elevation: 5.0,
            color: !isMe ? Colors.white : Color(0xFF5b6abf),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: !isMe ? Colors.black54 : Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
