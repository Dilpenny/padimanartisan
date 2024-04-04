import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padimanartisan/fragments/referal.dart';
import '../auth/change-password.dart';
import '../auth/change-pin.dart';
import 'package:http/http.dart' as http;
import '../auth/login.dart';
import '../auth/verify-email-to-change-password.dart';
import '../drawer/drawer.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  int user_id = 0;
  bool loggingOut = false;
  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: whiteColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: whiteColor,
          title: Text('Settings', style: GoogleFonts.quicksand(color: darkColor),),
          leading: SizedBox(
            width: 40,
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: mutedColorx,
              onPressed: _handleMenuButtonPressed,
              child: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                      color: secondaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
        body: Container(
          padding: EdgeInsets.all(20),
          child: body(),
        ),
      ),
      drawer: navigationDrawer(),
    );
  }

  Widget body(){
    return Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('graphics/megaphone.png', width: 35,),
                    const SizedBox(width: 20,),

                    Text.rich(
                        TextSpan(
                            text: 'Referral program',
                            style: GoogleFonts.quicksand(color: mutedColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                  ],
                ),
              ),
              onTap: () async {
                var session = FlutterSession();
                String referalCode = await session.get('referal_code');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReferalScreen(referalCode: referalCode,),
                  ),
                );
              },
            ),
            const SizedBox(height: 10,),
            GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyEmailPage(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('graphics/lock.png', width: 35,),
                    const SizedBox(width: 20,),
                    Text.rich(
                        TextSpan(
                            text: 'Change password',
                            style: GoogleFonts.quicksand(color: mutedColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: defaultColor,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset('graphics/shield.png', width: 25,),
                  const SizedBox(width: 20,),
                  Text.rich(
                      TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.quicksand(color: mutedColor),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '',
                              style: TextStyle(color: darkColor),
                            )
                          ]
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: defaultColor,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset('graphics/help-web-button.png', width: 35,),
                  const SizedBox(width: 20,),
                  Text.rich(
                      TextSpan(
                          text: 'Help',
                          style: GoogleFonts.quicksand(color: mutedColor),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '',
                              style: TextStyle(color: darkColor),
                            )
                          ]
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: defaultColor,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset('graphics/activity.png', width: 25,),
                  const SizedBox(width: 20,),
                  Text.rich(
                      TextSpan(
                          text: 'Activity History',
                          style: GoogleFonts.quicksand(color: mutedColor),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '',
                              style: TextStyle(color: darkColor),
                            )
                          ]
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('graphics/on-off-button.png', width: 25,),
                    const SizedBox(width: 20,),
                    Text.rich(
                        TextSpan(
                            text: 'Log out',
                            style: GoogleFonts.quicksand(color: errorColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                  ],
                ),
              ),
              onTap: () async {
                if (await confirm(
                context,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('graphics/warning.png', width: 100,),
                    const SizedBox(height: 10,),
                    Text('Are you sure you want to log out?',
                      style: GoogleFonts.quicksand(color: darkColor, fontSize: 16), textAlign: TextAlign.center,),
                  ],
                ),
                content: Center(
                  child: Text('All unsaved data will be lost',
                    style: GoogleFonts.quicksand(fontSize: 12, color: mutedColor),),
                ),
                textOK: SizedBox(
                  width: 120,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {

                    },
                    child: Text('Yes, I\'m sure', style:
                    GoogleFonts.quicksand(
                      fontSize: 13,
                        color: whiteColor, fontWeight: FontWeight.w600),),
                  ),
                ),
                textCancel: SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    child: Text('Cancel',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600, color: secondaryColor, fontSize: 12
                      ),),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      side: BorderSide(color: secondaryColor, width: 2),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),)
                ) {
                Component().default_toast('Please wait...');
                setState(() {
                loggingOut = true;
                });
                await go_offline();
                }
              }
            )

            // Container(
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(40),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            //     child: Column(
            //       children: [
            //         Text('Change pin')
            //       ],
            //     )
            // )
          ],
        ),
    );
  }

    Future<void> go_offline() async {
    try{
    String is_online = '0';
    var session = FlutterSession();
    user_id = await session.getInt('id');

    var url = Uri.parse('${Component().API}mobile/user/go/offline_online');
    var response = await http.post(url, body: {
    'is_online': is_online,
    'user_id': user_id.toString(),
    });
    var server_response = jsonDecode(response.body.toString());
    Component().default_toast('Be back soon...');
    if (response.statusCode == 200) {
      var session = FlutterSession();
      await session.setInt('id', 0);
      setState(() {
      loggingOut = false;
      });
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
    throw Exception('Failed to load activities from API');
    }
    }on Exception{

    }
    }
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}