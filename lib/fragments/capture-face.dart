import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:padimanartisan/fragments/referal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../auth/change-password.dart';
import '../auth/change-pin.dart';
import '../drawer/drawer.dart';
import '../helpers/session.dart';

class FaceCaptureScreen extends StatefulWidget {
  @override
  FaceCaptureScreenState createState() => FaceCaptureScreenState();
}

class FaceCaptureScreenState extends State<FaceCaptureScreen> {
  File? _capturedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(7, 84, 40, 1),
        title: const Text('Settings', style: TextStyle(color: Colors.yellow),),
      ),
      backgroundColor: Color.fromRGBO(243, 243, 247, 1),
        body: Builder(builder: (context) {
          if (_capturedImage != null) {
            return Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.file(
                    _capturedImage!,
                    width: double.maxFinite,
                    fit: BoxFit.fitWidth,
                  ),
                  ElevatedButton(
                      onPressed: () => setState(() => _capturedImage = null),
                      child: const Text(
                        'Capture Again',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ))
                ],
              ),
            );
          }
          return SmartFaceCamera(
              autoCapture: true,
              defaultCameraLens: CameraLens.front,
              onCapture: (File? image) {
                setState(() => _capturedImage = image);
              },
              onFaceDetected: (Face? face) {
                //Do something
              },
              messageBuilder: (context, face) {
                if (face == null) {
                  return _message('Place your face in the camera');
                }
                if (!face.wellPositioned) {
                  return _message('Center your face in the square');
                }
                return const SizedBox.shrink();
              });
        })
    );
  }

  Widget _message(String msg) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
    child: Text(msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
  );

  void startThings() async {
    await Permission.camera.request();
    await FaceCamera.initialize();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startThings();
  }

}