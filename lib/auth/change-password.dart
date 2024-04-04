//import 'dart:html';

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

class ChangePasswordPage extends StatefulWidget {

  @override
  ChangePasswordPageWidget createState() => ChangePasswordPageWidget();
}


class ChangePasswordPageWidget extends State<ChangePasswordPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  ChangePasswordPageWidget();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';
  int view_password = 0;
  bool view_npassword = false;
  bool view_ncpassword = false;


  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text("Change password", style: GoogleFonts.quicksand(),),
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child:
                Column(
                  children: [
                    Center(
                      child: SizedBox(
                        child: Image.asset('graphics/reset-banner.png'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("Current Password", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: passwordController,
                            obscureText: (view_password == 0) ? true : false,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(icon: (view_password == 0) ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                onPressed: () {
                                  if(view_password == 1){
                                    setState(() {
                                      view_password = 0;
                                    });
                                  }else{
                                    setState(() {
                                      view_password = 1;
                                    });
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: mutedColorx,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(color: mutedColorx, width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: mutedColorx, width: 2),
                              ),

                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required field';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              Text("New Password", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: view_npassword,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(icon: (view_npassword) ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                onPressed: () {
                                  if(view_npassword){
                                    setState(() {
                                      view_npassword = false;
                                    });
                                  }else{
                                    setState(() {
                                      view_npassword = true;
                                    });
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: mutedColorx,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(color: mutedColorx, width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: mutedColorx, width: 2),
                              ),
                              // hintText: 'New Password',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required field';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: view_ncpassword,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(icon: (view_ncpassword) ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                onPressed: () {
                                  if(view_ncpassword){
                                    setState(() {
                                      view_ncpassword = false;
                                    });
                                  }else{
                                    setState(() {
                                      view_ncpassword = true;
                                    });
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: mutedColorx,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(color: mutedColorx, width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: mutedColorx, width: 2),
                              ),
                              // hintText: 'Confirm Password',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required field';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.all(15),
                                backgroundColor: const Color.fromRGBO(7, 84, 40, 1)
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    processing = 1;
                                    password = passwordController.text;
                                    newPassword = newPasswordController.text;
                                    confirmPassword = confirmPasswordController.text;
                                  });
                                  await change_password();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Proceed  '.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                                ],
                              ),
                            ),
                          )
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

  Future<void> change_password() async {

    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse(Component().API+'mobile/change/password');
      var response = await http.post(url, body: {
        'password': password,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
        'user_id': user_id.toString(),
      });
      var server_response = jsonDecode(response.body.toString());

      String status = server_response['status'].toString();
      status = status.replaceAll('[', '');
      status = status.replaceAll(']', '');
      String message = server_response['message'].toString();
      message = message.replaceAll('[', '');
      message = message.replaceAll(']', '');
      if(status == 'error'){
        Component().error_toast(message);
        setState(() {
          processing = 0;
        });
        return;
      }
      setState(() {
        processing = 0;
      });
      Component().success_toast(message);
      // Map user = server_response['user'].toString();

      passwordController.text = '';
      confirmPasswordController.text = '';
      newPasswordController.text = '';

      Component().success_toast(message);

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

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    imgurl = await session.get('img');
    fullname = await session.get('fullname');
    setState(() {
      fullname = fullname;
      imgurl = imgurl;
      user_id = user_id;
    });
  }

}