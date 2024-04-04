
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:padimanartisan/auth/login.dart';
import '../auth/forgot.dart';
import '../map/.env.dart';
import '../auth/register.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

import '../home_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  final _formKey = GlobalKey<FormState>();

  int processing = 0;
  String email = '';
  String password = '';
  int view_password = 0;

  get mutedColors => null;
  bool isEmailSignup = true;
  List paragraphs = [
    '',
    'Let\'s get started on making your home a better place.',
    'Save your money and worry less about service charges.',
    'Never worry about being cut off amenities.'
  ];

  List headies = [
    null,
    Text.rich(
        TextSpan(
            text: 'Welcome to ',
            style: GoogleFonts.quicksand(fontSize: 27),
            children: <InlineSpan>[
              TextSpan(
                text: 'Padiman',
                style: TextStyle(color: secondaryColor),
              ),
              TextSpan(
                text: ', your go-to app for all your home repair needs.',
                style: TextStyle(),
              )
            ]
        )
    ),
    Text.rich(
        TextSpan(
            text: 'Discover skilled and efficient',
            style: GoogleFonts.quicksand(fontSize: 27),
            children: <InlineSpan>[
              TextSpan(
                text: 'Handymen',
                style: TextStyle(color: secondaryColor),
              ),
              TextSpan(
                text: ', around your location',
                style: TextStyle(),
              )
            ]
        )
    ),
    Text.rich(
        TextSpan(
            text: '',
            style: GoogleFonts.quicksand(fontSize: 27),
            children: <InlineSpan>[
              TextSpan(
                text: 'Easy ',
                style: TextStyle(color: secondaryColor),
              ),
              TextSpan(
                text: 'booking and peace of mind. We don’t joke with your time!',
                style: TextStyle(),
              )
            ]
        )
    ),
  ];

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
                    SizedBox(
                      child: Image.asset('graphics/logo.jpeg'),
                    ),
                    SizedBox(
                      child: Image.asset('graphics/splash$stages.png'),
                    ),
                    SizedBox(height: 20,),
                    headies[stages],
                    SizedBox(height: 20,),
                    Text(
                      paragraphs[stages],
                      style: TextStyle(fontSize: 12),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  stages = 1;
                                });
                              },
                              child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: (stages == 1) ? secondaryColor : disabledColor,
                                  ),
                                )
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(child:
                            GestureDetector(
                                onTap: (){
                                  setState(() {
                                    stages = 2;
                                  });
                                },
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: (stages == 2) ? secondaryColor : disabledColor,
                                  ),
                                )
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    stages = 3;
                                  });
                                },
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: (stages == 3) ? secondaryColor : disabledColor,
                                  ),
                                )
                            ),
                          )

                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextButton(
                      child: SizedBox(
                        height: 35,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((stages < 3) ? 'Next ' : 'Get Started', style: TextStyle(color: whiteColor),),
                            Icon(Icons.arrow_forward, size: 15, color: whiteColor,)
                          ],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        if(stages == 3){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        }else{
                          setState(() {
                            stages++;
                          });
                        }
                      },
                    ),
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

  int stages = 1;

}
