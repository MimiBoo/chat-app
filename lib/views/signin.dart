import 'package:chat_app/config.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/Home.dart';
import 'package:chat_app/widgets/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  AuthMethods authMethods = AuthMethods();

  signIn() async {
    setState(() {
      isLoading = true;
    });
    var user = await googleSignIn.signIn();
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      var googleAuth = await user.authentication;
      var credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      currentUser = userCredential.user;
      if (currentUser != null) {
        var snap = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (!snap.exists) {
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set(
            {
              "name": currentUser.displayName,
              "email": currentUser.email,
              "photoUrl": currentUser.photoURL,
              "lastSeen": FieldValue.serverTimestamp(),
            },
          );
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: appBarMain(context),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
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
                      signIn();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xffdfe6e9)),
                      elevation: MaterialStateProperty.all<double>(0),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sign In With Google',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
