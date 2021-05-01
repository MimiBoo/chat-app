import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/custom_search_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chat_app/widgets/custom_search_input.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen(this.chatId);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();

  Stream chatStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection("messages").orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  print("MESSAGES: ${snapshot.data.docs[index].data()['message']}|${snapshot.data.docs[index].data()['user']}");

                  return MessageTile(
                    snapshot.data.docs[index].data()['message'],
                    snapshot.data.docs[index].data()['user'] == currentUser.email,
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
        "user": currentUser.email,
        'photoUrl': currentUser.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
      };
      databaseMethods.sendMessages(widget.chatId, messageMap);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(child: chatMessageList()),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xffdfe6e9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(55, 84, 170, 0.15),
                      offset: Offset(7, 7),
                      blurRadius: 15,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(55, 84, 170, 0.15),
                      offset: Offset(-7, -7),
                      blurRadius: 20,
                    )
                  ],
                ),
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
                        icon: FaIcon(
                          Icons.send,
                          size: 35,
                          color: Colors.black,
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
          color: isMe ? Color(0xff74b9ff) : Color(0xffdfe6e9),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(55, 84, 170, 0.15),
              offset: Offset(7, 7),
              blurRadius: 15,
            ),
            BoxShadow(
              color: Color.fromRGBO(55, 84, 170, 0.15),
              offset: Offset(-7, -7),
              blurRadius: 20,
            )
          ],
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
          style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
