import 'package:chat_app/config.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/Chat.dart';
import 'package:chat_app/views/Search.dart';
import 'package:chat_app/views/Signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseMethods databaseMethods = DatabaseMethods();

  Stream chatRoomsStream;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return ChatRoomTile(snapshot.data.docs[index].id);
                  },
                ),
              )
            : Container();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // getUserInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(currentUser.displayName.toUpperCase()),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await googleSignIn.disconnect();
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignIn()));
              })
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen()));
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Color(0xffdfe6e9),
            borderRadius: BorderRadius.circular(45),
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
          child: Center(child: FaIcon(FontAwesomeIcons.search)),
        ),
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
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(widget.uid)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: EdgeInsets.symmetric(vertical: 5),
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      tempUser.photoURL,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    tempUser.name,
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
