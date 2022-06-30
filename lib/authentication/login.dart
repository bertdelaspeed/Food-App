import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/global/global.dart';
import 'package:foodpanda_sellers_app/mainScreens/home_screen.dart';
import 'package:foodpanda_sellers_app/widgets/custom_text_field.dart';
import 'package:foodpanda_sellers_app/widgets/error_dialog.dart';
import 'package:foodpanda_sellers_app/widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      //show error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill all the fields'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (context) {
        return LoadingDialog(
          message: "Checking credentials",
        );
      },
    );
    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            message: error.toString(),
          );
        },
      );
    });

    if (currentUser != null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      await sharedPreferences!.setString('uid', currentUser.uid);
      await sharedPreferences!
          .setString('email', snapshot.data()!['sellerEmail']);
      await sharedPreferences!
          .setString('name', snapshot.data()!['sellerName']);
      await sharedPreferences!
          .setString('photoUrl', snapshot.data()!['sellerAvatarUrl']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        reverse: false,
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  'images/seller.png',
                  height: 270,
                ),
              )),
          Form(
              key: _formKey,
              child: Column(children: [
                CustomTextField(
                  data: Icons.email,
                  hintText: 'Email',
                  controller: emailController,
                  isObscured: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  hintText: 'Password',
                  controller: passwordController,
                  isObscured: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[500],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  onPressed: () {
                    formValidation();
                  },
                  child: const Text(
                    'Login',
                  ),
                ),
                const SizedBox(height: 20),
              ]))
        ]));
  }
}
