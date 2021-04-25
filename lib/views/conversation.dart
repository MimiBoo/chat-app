import 'package:chat_app/config.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/app_bar.dart';
import 'package:chat_app/widgets/custom_search_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;

  const ConversationScreen({this.chatId});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController _controller = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();

  Stream chatStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    snapshot.data.docs[index].data()['message'],
                    snapshot.data.docs[index].data()['by'] == currentUser.uid,
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (_controller.text != null) {
      Map<String, dynamic> messageMap = {
        'message': _controller.text,
        "by": currentUser.uid,
        'timestemp': FieldValue.serverTimestamp(),
      };
      databaseMethods.sendMessages(widget.chatId, messageMap);
      _controller.clear();
    }
  }

  getMessages() async {
    print(widget.chatId);
    var snap = await databaseMethods.getMessages(widget.chatId);
    print(snap);
    if (snap != null) {
      setState(() {
        chatStream = snap;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarMain(context),
        body: Container(
          child: Stack(
            children: [
              chatMessageList(),
              Container(
                alignment: Alignment.bottomCenter,
                color: Color(0xffE8E8E9).withAlpha(50),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchInput(
                        controller: _controller,
                        onChanged: (value) {},
                        hintText: "Message...",
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isMe;
  const MessageTile(this.message, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isMe ? 0 : 24, right: isMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width,
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [
                    Color(0xff007af4),
                    Color(0xff2a75bc),
                  ]
                : [
                    Color(0x1affffff),
                    Color(0x1affffff),
                  ],
          ),
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
