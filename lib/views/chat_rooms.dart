import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/views/searh.dart';
import 'package:chat_app/views/Signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class ChatRooms extends StatefulWidget {
  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();

  Stream chatRoomsStream;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return ChatRoomTile(snapshot.data.docs[index].id);
                },
              )
            : Container();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getChatRooms();
  }

  getChatRooms() async {
    var snap = await databaseMethods.getChatRooms(currentUser.email);

    if (snap != null) {
      setState(() {
        chatRoomsStream = snap;
      });
    }
  }

  getUserInfo() async {
    if (userInfo == null) {
      DocumentSnapshot snap = await databaseMethods.getUserByUid(currentUser.uid);
      print(snap.data());
      setState(() {
        userInfo = Users(
          email: snap.data()["email"],
          name: snap.data()["name"],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userInfo.name == null ? '' : userInfo.name),
        actions: [
          IconButton(
            onPressed: () async {
              await authMethods.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignIn()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScree()));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

class ChatRoomTile extends StatefulWidget {
  final String uid;

  ChatRoomTile(this.uid);

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  Users tempUser;

  getDoctorInfo() async {
    var docEmail = await DatabaseMethods().getChatUser(widget.uid);
    var docData = await DatabaseMethods().getDoctorsByEmail(docEmail);

    if (docData.docs[0].data() != null) {
      setState(() {
        tempUser = Users(
          email: docData.docs[0].data()["email"],
          name: "${docData.docs[0].data()["name"]}",
          photoURL: docData.docs[0].data()['photoUrl'],
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDoctorInfo();
  }

  @override
  Widget build(BuildContext context) {
    return tempUser != null
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConversationScreen(chatId: widget.uid)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: EdgeInsets.symmetric(vertical: 5),
              color: Colors.black26,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      tempUser.photoURL,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    tempUser.name,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
