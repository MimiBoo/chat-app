import 'package:cloud_firestore/cloud_firestore.dart';

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
  createChatRoom(String chatId, chatMap) {
    FirebaseFirestore.instance.collection('chats').doc(chatId).set(chatMap);
  }

  //send messages from chat
  sendMessages(String chatId, messageMap) {
    FirebaseFirestore.instance.collection('chats').doc(chatId).collection("messages").add(messageMap);
  }

  getMessages(String chatId) {
    return FirebaseFirestore.instance.collection('chats').doc(chatId).collection("messages").orderBy('timestemp').snapshots();
  }

  getChatRooms(String uid) async {
    return await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: uid).snapshots();
  }
}
