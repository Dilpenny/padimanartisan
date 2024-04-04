//import 'dart:html';

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:padimanartisan/auth/change-password.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

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
  final _formKeyPhone = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  OtpFieldController emailOtpController = OtpFieldController();
  bool canVerifyEmailOTP = false;
  bool shouldEnterEmailOTP = false;
  String email = '';

  Widget email_otp_entry(){
    if(!shouldEnterEmailOTP){
      return SizedBox();
    }
    return Form(
      key: _formKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/reset-banner.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'Change password',
              style: GoogleFonts.quicksand(fontSize: 25),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Center(
                child: Text('Enter the OTP sent to',
                  textAlign: TextAlign.center,),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Center(
            child: Text(emailController.text, style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,),
          ),
          SizedBox(height: 40,),
          Center(
            child: OTPTextField(
                controller: emailOtpController,
                length: 5,
                otpFieldStyle: OtpFieldStyle(focusBorderColor: secondaryColor),
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 45,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                style: TextStyle(fontSize: 17),
                onChanged: (pin) {
                  print("Changed: " + pin);
                  setState(() {
                    emailOTP = pin;
                  });
                },
                onCompleted: (pin) {
                  setState(() {
                    canVerifyEmailOTP = true;
                  });
                  print("Completed: " + pin);
                }),
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: () async {
              await verify_email();
            },
            child: Center(
              child: Text.rich(
                  TextSpan(
                      text: 'Didn’t receive the OTP?  ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Resend code',
                          style: TextStyle(color: errorColor),
                        )
                      ]
                  )
              ),
            ),
          ),
          const SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (canVerifyEmailOTP) ? const Color.fromRGBO(7, 84, 40, 1) : disabledColor,
                      shape: const StadiumBorder(),

                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyPhone.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      //await register();
                      if(!canVerifyEmailOTP){
                        return Component().error_toast('Kindly enter the OTP sent to you');
                      }
                      setState(() {
                        processing = 1;
                      });
                      await verify_email_otp();
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify & Proceed  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String emailOTP = '';

  Widget email_entry(){
    if(shouldEnterEmailOTP){
      return SizedBox();
    }
    return Form(
      key: _formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/reset-banner.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'Change Password',
              style: GoogleFonts.quicksand(fontSize: 30),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Center(
                child: Text('We will send an OTP to', style: GoogleFonts.quicksand(),
                  textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 10,),
              Center(
                child: Text(email, style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,),
              )
            ],
          ),
          SizedBox(height: 40,),
          Text('Email'),
          SizedBox(height: 10,),
          TextFormField(
            controller: emailController,
            readOnly: true,
            decoration: InputDecoration(
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
              suffixIcon: const Icon(Icons.check_circle, color: accentSuccess,),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter email';
              }
              return null;
            },
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: const StadiumBorder(),

                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyEmail.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      setState(() {
                        processing = 1;
                      });
                      await verify_email();
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify & Proceed  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text(''),
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Container(
              // height: screen_height,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  email_otp_entry(),
                  email_entry()
                ],
              ),
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

  Future<void> verify_email_otp() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/otp/email');
      var response = await http.post(url, body: {
        'email': emailController.text,
        'token': emailOTP,
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
      // START REGISTRATION
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordPage(),
        ),
      );
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
        'email': emailController.text,
        'neglect_uniqueness': 'true',
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
      });
      setState(() {
        shouldEnterEmailOTP = true;
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

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    imgurl = await session.get('img');
    email = await session.get('email');
    fullname = await session.get('fullname');
    setState(() {
      email = email;
      fullname = fullname;
      imgurl = imgurl;
      user_id = user_id;
    });
    emailController.text = email;
  }

}