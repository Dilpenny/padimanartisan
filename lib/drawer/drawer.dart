import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padimanartisan/auth/become-workman.dart';
import 'package:padimanartisan/fragments/lost-items.dart';
import 'package:padimanartisan/fragments/sent-requests.dart';
import 'package:padimanartisan/fragments/services.dart';
import 'package:padimanartisan/map/.env.dart';
import '../fragments/CarForHire.dart';
import '../fragments/assets.dart';
import '../fragments/requests.dart';
import '../fragments/wallet_history.dart';
import '../auth/login.dart';
import '../fragments/profile.dart';
import '../helpers/components.dart';
import 'package:http/http.dart' as http;
import '../helpers/session.dart';
import '../home_page.dart';

class navigationDrawer extends StatefulWidget {
  final page; // if si attendant
  navigationDrawer({Key? key, this.page}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState(page);
}

class _MyDrawerState extends State<navigationDrawer> {
  final page;
  @override
  bool sidebar_memory_collapsible = false;
  bool sidebar_request_collapsible = false;
  bool sidebar_hire_collapsible = false;

  _MyDrawerState(this.page);
  int user_id = 0;
  int isAttendant = 0;
  String fullname = 'John Doe';
  String gender = 'Female';
  String art_scope = '';
  String email = '';
  String imgurl = '';
  String isArtisan = '';

  bool loggingOut = false;
  @override
  void initState() {
    firstThings();
    // TODO: implement initState
    super.initState();
  }

  Future firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    art_scope = await session.get('art_scope');
    isArtisan = await session.get('isArtisan');
    email = await session.get('email');
    imgurl = await session.get('img');
    // gender = await session.get('gender');
    fullname = await session.get('fullname');
    setState(() {
      fullname = fullname;
      email = email;
      isAttendant = isAttendant;
      isArtisan = isArtisan;
      art_scope = art_scope;
      gender = gender;
      imgurl = imgurl;
      user_id = user_id;
    });

  }

  int expanded = 0;
  int deliveries_expanded = 0;
  int profilesExpanded = 0;
  int memosExpanded = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListTileTheme(
        textColor: mutedColor,
        iconColor: mutedColor,
        selectedTileColor: activeSidebarColor,
        child: Container(
            // decoration: const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("graphics/rectangle3.png"),
            //     fit: BoxFit.cover,
            //   ),
            // ),
          color: whiteColor,
            child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20,),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
                leading: const Icon(Icons.home),
                title: const Text('Home'),
              ),
              ExpansionTile(
                onExpansionChanged: (value){
                  print('----------------');
                  print(value);
                  print('----------------');
                  if(value){
                    setState(() {
                      sidebar_hire_collapsible = false;
                    });
                  }else{
                    setState(() {
                      sidebar_hire_collapsible = true;
                    });
                  }
                },
                iconColor: (!sidebar_hire_collapsible) ? secondaryColor : mutedColor,
                leading: Icon(Icons.car_crash_sharp, color: (!sidebar_hire_collapsible) ? secondaryColor : mutedColor),
                title: Text("Hire", style:
                  GoogleFonts.quicksand(color: (!sidebar_hire_collapsible) ? secondaryColor : mutedColor),),
                initiallyExpanded: sidebar_hire_collapsible,//all even tiles will be exapnded by default
                children: [
                  // (isArtisan == '1')
                  //     ?
                  // SizedBox()
                  //   :
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ServicePage(),
                        ),
                      );
                    },
                    leading: SizedBox(),
                    title: Text('Hire a workman', style: GoogleFonts.quicksand(fontSize: 14),),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CarHirePage(),
                        ),
                      );
                    },
                    leading: SizedBox(),
                    title: Text('Hire equipment', style: GoogleFonts.quicksand(fontSize: 14),),
                  ),
                ],
              ),
              ExpansionTile(
                onExpansionChanged: (value){
                  print('----------------');
                  print(value);
                  print('----------------');
                  if(value){
                    setState(() {
                      sidebar_request_collapsible = false;
                    });
                  }else{
                    setState(() {
                      sidebar_request_collapsible = true;
                    });
                  }
                },
                iconColor: (!sidebar_request_collapsible) ? secondaryColor : mutedColor,
                leading: Icon(Icons.playlist_play_sharp, color: (!sidebar_request_collapsible) ? secondaryColor : mutedColor),
                title: Text("Requests", style:
                GoogleFonts.quicksand(color: (!sidebar_request_collapsible) ? secondaryColor : mutedColor),),
                initiallyExpanded: sidebar_request_collapsible,//all even tiles will be exapnded by default
                children: [
                    (isArtisan == '0')
                        ?
                    SizedBox()
                        :
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const RequestsPage(),
                          ),
                        );
                      },
                      leading: const SizedBox(),
                      title: Text('Received Requests', style: GoogleFonts.quicksand(fontSize: 14),),
                    ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SentRequestsPage(),
                        ),
                      );
                    },
                    leading: const SizedBox(),
                    title: Text('Sent Requests', style: GoogleFonts.quicksand(fontSize: 14),),
                  )
                  ]
                ),
              (isArtisan == '1')
                  ?
              SizedBox()
                :
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const AssetsPage(),
                    ),
                  );
                },
                leading: const Icon(Icons.diamond_outlined),
                title: const Text('My Assets'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => WalletHistoryPage(),
                    ),
                  );
                },
                leading: const Icon(Icons.wallet),
                title: const Text('Wallet'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProfileScreen(),
                    ),
                  );
                },
                leading: const Icon(Icons.account_box),
                title: const Text('Profile'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LostItemsPage(),
                    ),
                  );
                },
                leading: const Icon(Icons.car_repair_rounded),
                title: const Text('Lost & Found'),
              ),
              const Divider(height: 20,),
              const SizedBox(height: 10,),
              (isArtisan == '1')
                  ?
              SizedBox()
                  :
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: secondaryColor,
                  ),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => WorkmanApplicationPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 15,),
                      Text('Become a workman',
                        style: GoogleFonts.quicksand(color: whiteColor),)
                    ],
                  )
              ),
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () async{
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
                                  onPressed: () async {
                                    Component().default_toast('Please wait...');
                                    setState(() {
                                      loggingOut = true;
                                    });
                                    await go_offline();
                                    
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

                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.power_settings_new_outlined, color: errorColor,),
                              Text(' Sign out', style:
                              GoogleFonts.quicksand(color: errorColor, fontSize: 16),)
                            ],
                          ),
                        ),
                        Spacer(),
                      ],
                    )
                  ),
                ),
              ),
            ],
          ),
          )
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

}