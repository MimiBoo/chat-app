import 'package:chat_app/config.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();
  fetchUserData() async {
    var snap = await databaseMethods.getUserByUid(currentUser.uid);

    return snap;
  }

  Future<Users> _userFromFirebase() async {
    var temp = await fetchUserData();
    return currentUser != null
        ? Users(
            email: currentUser.email,
            name: temp.data()['name'],
          )
        : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = credential.user;
      currentUser = user;
      return _userFromFirebase();
    } catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = credential.user;
      currentUser = user;
      return _userFromFirebase();
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
