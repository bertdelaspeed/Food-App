import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                  onPressed: () {},
                  child: const Text(
                    'Login',
                  ),
                ),
                const SizedBox(height: 20),
              ]))
        ]));
  }
}
