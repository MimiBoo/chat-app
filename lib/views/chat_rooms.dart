import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/views/signin.dart';
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
                  return ChatRoomTile(snapshot.data.docs[index].data()['chatroomId']);
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
    var snap = await databaseMethods.getChatRooms(currentUser.uid);

    if (snap != null) {
      print("SNAP: $snap");
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
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen()));
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
    var splitedList = widget.uid.split("_");
    splitedList.removeWhere((item) => item == currentUser.uid);

    DocumentSnapshot snap = await DatabaseMethods().getDoctorByUid(splitedList.first);

    if (snap.data() != null) {
      setState(() {
        tempUser = Users(
          email: snap.data()["email"],
          name: "${snap.data()["first_name"]} ${snap.data()["last_name"]}",
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
    return tempUser.name != null
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
                    child: Text(
                      tempUser.name.substring(0, 1).toUpperCase(),
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
