import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/authentication/auth_screen.dart';
import 'package:foodpanda_sellers_app/global/global.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title: Text(
            sharedPreferences?.getString('name') ?? '',
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                firebaseAuth.signOut().then((value) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AuthScreen();
                  }));
                });
              },
              // ignore: sort_child_properties_last
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(primary: Colors.green[500])),
        ));
  }
}
