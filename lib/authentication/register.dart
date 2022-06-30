// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/global/global.dart';
import 'package:foodpanda_sellers_app/mainScreens/home_screen.dart';
import 'package:foodpanda_sellers_app/widgets/custom_text_field.dart';
import 'package:foodpanda_sellers_app/widgets/error_dialog.dart';
import 'package:foodpanda_sellers_app/widgets/loading_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = '';

  getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = newPosition;
    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];
    String completeAddress =
        '${pMark.subThoroughfare}, ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: 'Please select an image',
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          // firebase stuff
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialog(
                  message: "Registering account",
                );
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fstorage.Reference reference = fstorage.FirebaseStorage.instance
              .ref()
              .child("sellers")
              .child(fileName);

          fstorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          fstorage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            // save info to firestore
            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: 'Fill all the forms',
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: 'Passwords do not match',
              );
            });
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Route newRoute = MaterialPageRoute(builder: (c) {
          return HomeScreen();
        });
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(currentUser.uid)
        .set({
      'sellerUid': currentUser.uid,
      'sellerEmail': currentUser.email,
      'SellerName': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': locationController.text.trim(),
      'status': 'approved',
      'earning': 0.0,
      'lat': position!.latitude,
      'lng': position!.longitude,
      'createdAt': DateTime.now(),
    });

    // save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences?.setString('uid', currentUser.uid);
    await sharedPreferences?.setString('name', nameController.text.trim());
    await sharedPreferences?.setString('email', emailController.text.trim());
    await sharedPreferences?.setString('photoUrl', sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        const SizedBox(height: 20),
        InkWell(
            onTap: _getImage,
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.2,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  imageXFile == null ? null : FileImage(File(imageXFile!.path)),
              child: imageXFile == null
                  ? Icon(Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.2)
                  : null,
            )),
        const SizedBox(height: 20),
        Form(
            key: _formKey,
            child: Column(children: [
              CustomTextField(
                data: Icons.person,
                hintText: 'Name',
                controller: nameController,
                isObscured: false,
              ),
              CustomTextField(
                data: Icons.email,
                hintText: 'Email',
                controller: emailController,
                isObscured: false,
              ),
              CustomTextField(
                data: Icons.phone,
                hintText: 'Phone',
                controller: phoneController,
                isObscured: false,
              ),
              CustomTextField(
                data: Icons.lock,
                hintText: 'password',
                controller: passwordController,
                isObscured: true,
              ),
              CustomTextField(
                data: Icons.lock,
                hintText: 'Confirm password',
                controller: confirmPasswordController,
                isObscured: true,
              ),
              CustomTextField(
                data: Icons.my_location,
                hintText: 'Restaurant Location',
                controller: locationController,
                isObscured: false,
                enabled: false,
              ),
              Container(
                  width: 400,
                  height: 40,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    label: const Text("Get location",
                        style: TextStyle(color: Colors.white)),
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                    ),
                    // ignore: avoid_print
                    onPressed: () {
                      getCurrentLocation();
                    },
                  )),
            ])),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.green[500],
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          // ignore: avoid_print
          onPressed: () {
            formValidation();
          },
          child: const Text('Sign up',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ]),
    );
  }
}
