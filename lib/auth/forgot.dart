
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import '../helpers/components.dart';
import '../helpers/session.dart';

import '../home_page.dart';
import '../map/.env.dart';
import 'login.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({Key? key}) : super(key: key);

  @override
  State<ForgotPage> createState() => _ForgotState();
}

class _ForgotState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();

  int processing = 0;
  String email = '';
  String password = '';
  int view_password = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Max Size
          Container(
            alignment: Alignment.bottomRight,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // SizedBox(height: 300,),
                    Row(
                      children: [
                        Text(
                          'Reset Password,',
                          style: TextStyle(fontSize: 30),
                        ),
                        Image.asset('graphics/wave.png', width: 25,)
                      ],
                    ),
                    SizedBox(height: 10,),
                    Wrap(
                      children: [
                        Text('Forgot your password?')
                      ],
                    ),
                    SizedBox(height: 10,),
                    my_form(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Form my_form(){
    return Form(
      key: _formKey,
      child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email'),
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: emailController,
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
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0,),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 30),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(7, 84, 40, 1),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.all(15),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a Snackbar.
                              setState(() {
                                email = emailController.text;
                                processing = 1;
                                password = passwordController.text;
                              });
                              await reset();
                            }
                          },
                          child:
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Reset  ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              (processing == 1) ? const SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text('Already have an account?'),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                                TextSpan(
                                    text: '',
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(color: secondaryColor),
                                      )
                                    ]
                                )
                            ),
                            Icon(Icons.arrow_forward, color: secondaryColor, size: 20,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:20.0),
            ],
          )
      ),
    );
  }

  Future<void> reset() async {

    var client = http.Client();
    try {
      var url = Uri.parse(Component().API+'mobile/reset/password');
      var response = await http.post(url, body: {
        'email': email,
      });
      var server_response = jsonDecode(response.body.toString());
      print('==============='+server_response['status']);
      String status = server_response['status'].toString();
      status = status.replaceAll('[', '');
      status = status.replaceAll(']', '');
      String message = server_response['message'].toString();
      message = message.replaceAll('[', '');
      message = message.replaceAll(']', '');
      if(status == 'admin'){
        Component().error_toast(message);
        setState(() {
          processing = 0;
        });
        return;
      }

      if(status == 'error'){
        Component().error_toast(message);
        setState(() {
          processing = 0;
        });
        return;
      }
      Component().success_toast(message);
      emailController.text = '';

      Navigator.pop(context);

      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }
}
