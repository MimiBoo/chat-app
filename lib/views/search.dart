import 'package:chat_app/config.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/widgets/app_bar.dart';
import 'package:chat_app/widgets/custom_search_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String search;

  DatabaseMethods databaseMethods = DatabaseMethods();

  QuerySnapshot snapshot;

  Widget searchList() {
    return snapshot != null
        ? ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                id: snapshot.docs[index].id,
                email: snapshot.docs[index].data()['email'],
                name: "${snapshot.docs[index].data()['name']}",
              );
            },
          )
        : Container();
  }

  //Init search resaults
  initSearch() async {
    var tempSnap = await databaseMethods.getDoctorsByEmail(search);
    // print("DATA: ${tempSnap.docs[0].data()}");
    setState(() {
      snapshot = tempSnap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomSearchInput(
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    hintText: "Search For Doctor...",
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(color: Color(0xffE8E8E9).withAlpha(50), borderRadius: BorderRadius.circular(45)),
                  child: IconButton(
                    onPressed: () async {
                      initSearch();
                    },
                    icon: Icon(
                      Icons.search,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: searchList(),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SearchTile extends StatelessWidget {
  final String id;
  final String name;
  final String email;

  SearchTile({this.id, this.name, this.email});

  DatabaseMethods databaseMethods = DatabaseMethods();

  // Create chat room
  createChatroom(BuildContext context, String userId) async {
    // QuerySnapshot temp = await databaseMethods.getChatRoomsId(userInfo.email);
    List<String> users = [
      userId,
      currentUser.uid
    ];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
    };

    var id = databaseMethods.createChatRoom(chatRoomMap);
    print(id);
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (_) => ConversationScreen(
    //           chatId: chatId,
    //         )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              Text(
                email,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
          Spacer(),
          Container(
            child: ElevatedButton(
              onPressed: () {
                createChatroom(context, id);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)),
              ),
              child: Text(
                'Message',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
