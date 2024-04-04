
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import '../auth/forgot.dart';
import '../map/.env.dart';
import '../auth/register.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provideford by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  int processing = 0;
  String email = '';
  String password = '';
  int view_password = 0;

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  get mutedColors => null;
  bool isEmailSignup = true;

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
                          'Welcome back,',
                          style: TextStyle(fontSize: 30),
                        ),
                        Image.asset('graphics/wave.png', width: 25,)
                      ],
                    ),
                    SizedBox(height: 10,),
                    Wrap(
                      children: [
                        Text('Great to have you back, kindly confirm your details and continue your journey with us.')
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      color: mutedColorx,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Text('Email', style: TextStyle(color: darkColor),),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all((isEmailSignup) ? whiteColor : mutedColorx)),
                              onPressed: () {
                                setState(() {
                                  isEmailSignup = true;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: TextButton(
                              child: Text('Phone', style: TextStyle(color: darkColor)),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all((isEmailSignup) ? mutedColorx : whiteColor)),
                              onPressed: () {
                                setState(() {
                                  isEmailSignup = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    my_form(),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   color: Colors.yellow,
          // )
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
                          Text((isEmailSignup) ? 'Email' : 'Phone'),
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
                              prefixIcon: Icon((isEmailSignup) ? Icons.email_outlined : Icons.phone),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0,),
                          SizedBox(height: 10.0,),
                          Text('Password'),
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: passwordController,
                            obscureText: (view_password == 0) ? true : false,
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
                              prefixIcon: Icon(Icons.lock_outline),
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
                                },),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => const ForgotPage(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Forgot password?', style: TextStyle(color: mutedColor),
                                  ),
                                ),
                              )
                            ],
                          ),
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
                              await login();
                            }
                          },
                          child:
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Sign In  ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              (processing == 1) ? const SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text('Dont\'t have an account?'),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => RegisterPage(type: 'user',),
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
                                        text: 'Sign up as a user',
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
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const RegisterPage(type: 'artisan',),
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
                                        text: 'Sign up as a workman',
                                        style: TextStyle(color: secondaryColor),
                                      )
                                    ]
                                )
                            ),
                            Icon(Icons.arrow_forward, color: secondaryColor, size: 20,)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height:20.0),
            ],
          )
      ),
    );
  }

  Future<void> login() async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/signin?type=artisan');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'email': email,
            'password': password,
            'isAdmin': 1,
          })
      );
      print('${response.body}===================');
      var server_response = jsonDecode(response.body.toString());
      print('==============='+server_response['status']);

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

      var session = FlutterSession();
      await session.set("email", server_response['user']['email']);
      if(server_response['user']['name'] != null){
        await session.set("fullname", server_response['user']['name']);
      }
      if(server_response['user']['phone'] != null) {
        await session.set("phone", server_response['user']['phone']);
      }
      if(server_response['user']['username'] != null) {
        await session.set("username", server_response['user']['username']);
      }

      // if(server_response['user']['dob'] != null) {
      //   await session.set("dob", server_response['user']['dob']);
      // }

      if(server_response['user']['email_verified_at'] != null) {
        await session.set("email_verified_at", server_response['user']['email_verified_at']);
      }
      if(server_response['user']['wallet'] != null) {
        await session.set("wallet", server_response['user']['wallet']);
      }
      if(server_response['user']['country'] != null) {
        await session.set("country", server_response['user']['country']);
      }else{
        await session.set("country", '---');
      }
      if(server_response['user']['state'] != null) {
        await session.set("state", server_response['user']['state']);
      }
      if(server_response['user']['img'] != null) {
        await session.set("img", server_response['user']['img']);
      }
      if(server_response['user']['art_scope'] != null) {
        await session.set("art_scope", server_response['user']['art_scope']);
      }
      await session.set("referal_code", server_response['user']['username']);
      await session.setInt("id", server_response['user']['id']);
      await session.set("isArtisan", server_response['user']['isArtisan']);
      await session.set("isCustomer", server_response['user']['isCustomer']);
      if(server_response['user']['business_name'] != null) {
        await session.set("business_name", server_response['user']['business_name']);
      }

      String deviceToken = await session.get('device_token');
      await save_devicetoken(deviceToken, server_response['user']['id']);
      emailController.text = '';
      passwordController.text = '';

      Component().success_toast('Welcome '+server_response['user']['name']);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        ),
            (route) => false,
      );

      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> save_devicetoken(String device_token, int user_id) async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}save-push-notification-token');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'token': device_token,
      });
      print('===============================================');

      // print('Response status: ${response.statusCode}');
    } finally {
      client.close();
    }
  }
}
