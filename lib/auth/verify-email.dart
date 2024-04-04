//import 'dart:html';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../fragments/profile.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class VerifyEmailPage extends StatefulWidget {

  @override
  VerifyEmailPageWidget createState() => VerifyEmailPageWidget();
}


class VerifyEmailPageWidget extends State<VerifyEmailPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  VerifyEmailPageWidget();

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
              Text('Email Verification', style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: highlightedAppBar(),
      backgroundColor: whiteColor,
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
                          Row(
                            children: const [
                              Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          TextFormField(
                            controller: otpController,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 4),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Icon(Icons.lock_outline),
                              // hintText: 'Password',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter the OTP sent to your email';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    otpController.text = '';
                                    await verify_email();
                                  },
                                  child: Row(
                                    children: const [
                                      Text('Resend code ', style: TextStyle(fontSize: 12, color: secondaryColor),),
                                      Icon(Icons.refresh, color: secondaryColor, size: 15,)
                                    ],
                                  )
                              )
                            ],
                          ),
                          const SizedBox(height: 20,),
                          SizedBox(
                            width: 200,
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

                                  });
                                  await verify_email_otp();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Verify  '.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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

  Future<void> verify_email_otp() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/otp/email');
      var response = await http.post(url, body: {
        'email': email,
        'token': otpController.text,
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
      Component().success_toast(message);
      var sessionL = FlutterSession();
      await sessionL.set("email_verified_at", 'today');
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ProfileScreen(),
        ),
      );

      setState(() {
        processing = 0;
        // account_message = message;
        // emailOtpEnabled = false;
        // spage = 2;
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }


  Future<void> verify_email() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/email');
      var response = await http.post(url, body: {
        'email': email,
      });
      print(response.body.toString());
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
      Component().success_toast(message);
      // Map user = server_response['user'].toString();

      setState(() {
        processing = 0;
        // account_message = message;
        // spage = 0;
        // emailOtpEnabled = true;
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
    await verify_email();
  }

}