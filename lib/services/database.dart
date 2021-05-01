import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';

class DatabaseMethods {
  //Query for doctors by email
  Future<QuerySnapshot> getDoctorsByEmail(String email) async {
    return await FirebaseFirestore.instance.collection("doctors").where("email", isEqualTo: email).get();
  }

  Future getUserByUid(String uid) async {
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  Future getDoctorByUid(String uid) async {
    return await FirebaseFirestore.instance.collection("doctors").doc(uid).get();
  }

  //create user document
  uploadUserInfo(String id, userMap) {
    FirebaseFirestore.instance.collection('users').doc(id).set(userMap);
  }

  //create chat document
  createChatRoom(chatMap) async {
    DocumentReference temp = await FirebaseFirestore.instance.collection('chats').add(chatMap);
    return temp.id;
  }

  //send messages from chat
  sendMessages(String chatId, messageMap) {
    FirebaseFirestore.instance.collection('chats').doc(chatId).collection("messages").add(messageMap);
  }

  getMessages(String chatId) {
    return FirebaseFirestore.instance.collection('chats').doc(chatId).collection("messages").orderBy('timestemp').snapshots();
  }

  getChatRooms(String email) async {
    return await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: email).snapshots();
  }

  getChatRoomsId(String email) async {
    return await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: email).get();
  }

  getChatUser(String id) async {
    var temp = await FirebaseFirestore.instance.collection('chats').doc(id).get();
    List users = temp.data()["users"];
    var doc = users.where((item) => item != currentUser.email).toList();
    return doc.first;
  }
}
