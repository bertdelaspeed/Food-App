import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/authentication/login.dart';
import 'package:foodpanda_sellers_app/authentication/register.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.green],
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            title: const Text(
              'Food App',
              style: TextStyle(fontSize: 30, fontFamily: 'Lobster'),
            ),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.lock), text: 'Login'),
                Tab(
                    icon: Icon(Icons.person, color: Colors.white),
                    text: 'Register'),
              ],
              indicatorColor: Colors.white,
            ),
          ),
          body: TabBarView(
            children: [
              LoginScreen(),
              RegisterScreen(),
            ],
          ),
        ));
  }
}
