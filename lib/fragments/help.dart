import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padimanartisan/fragments/lost-items.dart';
import 'package:padimanartisan/map/.env.dart';
import '../auth/change-password.dart';
import '../auth/change-pin.dart';
import '../drawer/drawer.dart';
import '../helpers/session.dart';
import 'contact_us.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        elevation: 0,
        backgroundColor: whiteColor,
        title: Text('Help', style: TextStyle(color: darkColor),),
      ),
      backgroundColor: whiteColor,
      body: body(),
    );
  }

  Widget body(){
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Not sure about something, we’ve got you covered!',
                  style: GoogleFonts.quicksand(fontSize: 18), textAlign: TextAlign.center,)
              ],
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset('graphics/funds.png', width: 35,),
                        const SizedBox(width: 20,),
                        Text.rich(
                            TextSpan(
                                text: 'Distress Sales',
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
                    Text('Not yet available in your area', style: GoogleFonts.quicksand(color: errorColor),)
                  ],
                )
              ),
              onTap: () async {
                var session = FlutterSession();
                String referalCode = await session.get('referal_code');

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ReferalScreen(referalCode: referalCode,),
                //   ),
                // );
              },
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: (){

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('graphics/terms-and-conditions.png', width: 35,),
                    const SizedBox(width: 20,),
                    Text.rich(
                        TextSpan(
                            text: 'Terms & Conditions',
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
            GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LostItemsPage(),
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
                    Image.asset('graphics/lost.png', width: 35,),
                    const SizedBox(width: 20,),
                    Text.rich(
                        TextSpan(
                            text: 'Lost & Found',
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
            GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactScreen(),
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
                    Image.asset('graphics/phonebook.png', width: 35,),
                    const SizedBox(width: 20,),
                    Text.rich(
                        TextSpan(
                            text: 'Contact Us',
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
          ],
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}