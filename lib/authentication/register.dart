// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/widgets/custom_text_field.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

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
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.green[500],
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          // ignore: avoid_print
          onPressed: () => print('Sign up !'),
          child: const Text('Sign up',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ]),
    );
  }
}
