import 'package:chat_app/config.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/chat_rooms.dart';
import 'package:chat_app/views/signup.dart';
import 'package:chat_app/widgets/app_bar.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email, password;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  AuthMethods authMethods = AuthMethods();

  signIn() async {
    if (email != null || email.isNotEmpty && password != null || password.isNotEmpty) {
      if (!email.contains('@')) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Please Enter a valid email'),
          duration: Duration(seconds: 3),
        ));
        return;
      }
      if (password.length < 6) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Passwrord must be more then 6 characters'),
          duration: Duration(seconds: 3),
        ));
        return;
      }
      setState(() {
        isLoading = true;
      });
      userInfo = await authMethods.signInWithEmailAndPassword(email, password);
      print("USER:$userInfo");
      if (userInfo != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ChatRooms()));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Don\'t leave empty fields'),
        duration: Duration(seconds: 3),
      ));
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
                CustomInput(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  hintText: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomInput(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  hintText: "Password",
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      signIn();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff007ef4)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignUp())),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
