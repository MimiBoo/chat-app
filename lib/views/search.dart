import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/Chat.dart';
import 'package:chat_app/widgets/custom_search_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();

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
                name: snapshot.docs[index].data()['name'],
              );
            },
          )
        : Container();
  }

  //Init search resaults
  initSearch() async {
    var tempSnap = await databaseMethods.getDoctorsByEmail(_controller.text.trim());
    // print("DATA: ${tempSnap.docs[0].data()}");
    setState(() {
      snapshot = tempSnap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
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
                        hintText: "Search For Doctor...",
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          initSearch();
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.search,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: searchList(),
              )
            ],
          ),
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

  createChatroom(BuildContext context, String userEmail) async {
    List<String> users = [
      userEmail,
      currentUser.email
    ];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
    };

    var id = await databaseMethods.createChatRoom(chatRoomMap);
    
    if (id == null) {
      Navigator.of(context).pop();
    }else{
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(id)));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
              Text(
                email,
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ],
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
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
            child: ElevatedButton(
              onPressed: () {
                createChatroom(context, email);
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
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
