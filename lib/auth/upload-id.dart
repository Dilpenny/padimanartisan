//import 'dart:html';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../fragments/profile.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class UploadIDPage extends StatefulWidget {

  @override
  UploadIDPageWidget createState() => UploadIDPageWidget();
}


class UploadIDPageWidget extends State<UploadIDPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  UploadIDPageWidget();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';


  AppBar highlightedAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: secondaryColor,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProfileScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back, color: whiteColor,),
              ),
              const SizedBox(width: 2,),
              Text('Upload Identification', style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> select_file_avatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'gif', 'png'],);

    if (result != null) {
      File file = File(result.files.single.path!);
      avatar = file.uri;
      setState(() {
        avatar = avatar;
        avatar_uploading = true;
      });
    } else {
      // User canceled the picker
    }
  }

  Uri? avatar;
  bool avatar_uploading = false;

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: highlightedAppBar(),
      backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
      body: SingleChildScrollView(
          child: Container(
              height: screen_height,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child:
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 15,),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: secondaryColor, width: 1),
                              ),
                              onPressed: () async {
                                await select_file_avatar();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera, color: secondaryColor,),
                                  Text(' Select ID', style: TextStyle(color: secondaryColor),)
                                ],
                              )
                          ),
                          Text('Note that we will review this item before your account is approved for business',
                            style: TextStyle(fontSize: 14, color: mutedColor),),
                          const SizedBox(height: 25,),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                side: const BorderSide(color: secondaryColor, width: 1),
                              ),
                              onPressed: () async {
                                if(avatar == null){
                                  Component().error_toast('Please select a file');
                                  return;
                                }
                                setState(() {
                                  processing = 1;
                                });
                                await uploadID();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Upload '.toUpperCase(),
                                    style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),),
                                  (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                                ],
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          )
      ),
    );
  }

  Future<void> uploadID() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/upload/identity');

      var request = http.MultipartRequest("POST", url);
      request.fields['user_id'] = user_id.toString();
      request.files.add(await http.MultipartFile.fromPath('photo', File.fromUri(avatar!).path));
      request.send().then((response) async {
        print('=============');
        print(response.statusCode);
        if (response.statusCode == 200) {
          // Map user = server_response['user'].toString();
          setState(() {
            processing = 0;
          });

          Component().success_toast('Saved successfully');
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(),
            ),
          );
        } else {
          Component().error_toast('Select a file');
          setState(() {
            avatar_uploading = false;
          });
          throw Exception('Failed to load activities from API');
        }
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    firstThings();
    super.initState();
  }

  String email = '';

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    email = await session.get('email');
    imgurl = await session.get('img');
    fullname = await session.get('fullname');
    setState(() {
      email = email;
      fullname = fullname;
      imgurl = imgurl;
      user_id = user_id;
    });
  }

}