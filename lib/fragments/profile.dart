import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:padimanartisan/auth/update-workman-data.dart';
import 'package:padimanartisan/auth/upload-id.dart';
import 'package:padimanartisan/fragments/receive_request.dart';
import 'package:padimanartisan/fragments/referal.dart';
import 'package:padimanartisan/fragments/requests.dart';
import 'package:padimanartisan/map/.env.dart';
import '../auth/verify-email.dart';
import '../drawer/drawer.dart';
import '../fragments/settings.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../home_page.dart';
import 'capture-face.dart';
import 'my_location.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
  final _formKey = GlobalKey<FormState>();

  String img_src = '';
  int processing = 0;
  int user_id = 0;
  String fullname = '';
  String state = '';
  String email = '';
  String phone = '';
  String country = '';
  String work_address_1 = '';
  String category = '';
  String home_address_1 = '';
  String username = '';
  String gender = '';
  String art_scope = '';
  String area = '';
  String approvedDriversLicence = '0';
  String driversLicence = '';
  String profileAvatar = '';
  String longitude = '';
  String latitude = '';
  String referalCode = '';
  String locality = '';
  late Uri avatar;
  int avatar_uploading = 0;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController stateController = new TextEditingController();
  final TextEditingController countryController = new TextEditingController();
  final TextEditingController homeAdressController = new TextEditingController();
  final TextEditingController workAdressController = new TextEditingController();
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController areaController = new TextEditingController();
  final TextEditingController localityController = new TextEditingController();

  late FirebaseMessaging _firebaseMessaging;

  String email_verified_at = '';

  Future firstThings() async {
    var session = FlutterSession();
    email_verified_at = await session.get("email_verified_at");

    user_id = await session.getInt('id');
    state = await session.get('state');
    isArtisan = await session.get('isArtisan');
    country = await session.get('country');
    home_address_1 = await session.get('home_address_1');
    work_address_1 = await session.get('work_address_1');
    img_src = await session.get('img');
    referalCode = await session.get('referal_code');
    email = await session.get('email');
    phone = await session.get('phone');
    category = await session.get('category');
    username = await session.get('username');
    area = await session.get('area');
    fullname = await session.get('fullname');
    latitude = await session.get('latitude');
    longitude = await session.get('longitude');
    locality = await session.get('locality');
    setState(() {
      email_verified_at = email_verified_at;
      home_address_1 = home_address_1;
      work_address_1 = work_address_1;
      country = country;
      email = email;
      category = category;
      phone = phone;
      area = area;
      state = state;
      fullname = fullname;
      locality = locality;
      img_src = img_src;
      user_id = user_id;
      latitude = latitude;
      referalCode = referalCode;
      longitude = longitude;
      username = username;
      isArtisan = isArtisan;
    });

    usernameController.text = username;
    nameController.text = fullname;
    workAdressController.text = home_address_1;
    homeAdressController.text = home_address_1;
    countryController.text = country;
    stateController.text = state;
    phoneController.text = phone;
    areaController.text = area;
    localityController.text = locality;

    _firebaseMessaging = FirebaseMessaging.instance;
    // FirebaseMessaging.onBackgroundMessage(_messageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("Home page ============ +++++++++++++++++ received");
      String notificationTitle = event.notification!.title.toString();
      print(event.data);
      print("Home page ============ -----------------");
      if(event.data['new_request'] != null){
        customer_id = event.data['user_id'].toString();
        if (!mounted) return;
        setState(() {
          createdRequestId = event.data['request_id'].toString();
          newCustomerImg = event.data['sender_avatar'].toString();
          newCustomerName = event.data['name'];
          hasCall = true;
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
      print('HOMEPAGE ********************************** Message clicked!');
      String notificationTitle = message.notification!.title.toString();
      String notificationMessage = message.notification!.body.toString();
      await player.stop();
      if(message.data['new_request'] != null){
        customer_id = message.data['user_id'].toString();
        setState((){
          createdRequestId = message.data['request_id'].toString();
          newCustomerImg = message.data['sender_avatar'].toString();
          newCustomerName = message.data['name'];
          hasCall = true;
          noNeedForNewSound = true;
        });
      }
      if(notificationMessage.toLowerCase().contains('customer has accepted your stated price')){
        // notificationTitle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RequestsPage(tag: notificationTitle,),
          ),
        );
      }
    });
  }

  Color profileCompletionColor = Colors.red;
  String isArtisan = '';
  String business_name = '';

  @override
  void initState() {
    // TODO: implement initState
    firstThings();
    getProfile();
    super.initState();
  }

  Future getProfile() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    var url = Uri.parse('${Component().API}mobile/user/profile?user_id=$user_id');
    var response = await http.post(url, body: {
      'user_id': user_id.toString(),
    });
    var jsonResponses = json.decode(response.body.toString());
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
        // page = 0;
      });
      return;
    }

    setState(() {
      phone = server_response['profile']['phone'].toString();
      fullname = server_response['profile']['name'].toString();
      state = server_response['profile']['state'].toString();
      country = server_response['profile']['country'].toString();
      profileAvatar = server_response['profile']['profile_avatar'].toString();
      gender = server_response['profile']['gender'].toString();
      referalCode = server_response['profile']['username'].toString();
      area = server_response['profile']['area'].toString();
      img_src = server_response['profile']['img'].toString();
      approvedDriversLicence = server_response['profile']['approved_drivers_licence'].toString();
      driversLicence = server_response['profile']['driver_licence'].toString();
      art_scope = server_response['profile']['art_scope'].toString();
      if(server_response['profile']['longitude'] != null){
        longitude = server_response['profile']['longitude'].toString();
      }
      if(server_response['profile']['latitude'] != null){
        latitude = server_response['profile']['latitude'].toString();
      }
      if(server_response['profile']['country'] != null){
        countryController.text = server_response['profile']['country'].toString();
      }
      if(server_response['profile']['state'] != null){
        stateController.text = server_response['profile']['state'].toString();
      }

      if(server_response['profile']['business_name'] != null){
        business_name = server_response['profile']['business_name'].toString();
      }

      // if(server_response['profile']['isArtisan'] != null){
      //   isArtisan = server_response['profile']['isArtisan'].toString();
      // }

      nameController.text = server_response['profile']['name'].toString();
      emailController.text = server_response['profile']['email'].toString();
      usernameController.text = server_response['profile']['username'].toString();
      phoneController.text = server_response['profile']['phone'].toString();
    });
    var sessions = FlutterSession();
    await sessions.set("fullname", fullname);
    await sessions.set("country", country);
    await sessions.set("state", state);
    // if(server_response['profile']['isArtisan'] != null) {
    //   await sessions.set("isArtisan", isArtisan);
    // }
    await sessions.set("img", img_src);
    await sessions.set("referal_code", referalCode);
    await sessions.set("art_scope", art_scope);
    await sessions.set("longitude", longitude);
    await sessions.set("latitude", latitude);

   setState(() {
     screen_width = 0;
   });
    if(profileAvatar.isNotEmpty && profileAvatar != 'null' && profileAvatar != null){
      setState(() {
        screen_width = screen_width + 25;
      });
    }
    if(latitude.isNotEmpty && latitude != 'null' && latitude != null){
      setState(() {
        screen_width = screen_width + 25;
      });
    }
    if(email_verified_at.isNotEmpty && email_verified_at != 'null'){
      setState(() {
        screen_width = screen_width + 25;
      });
    }
    if(driversLicence.isNotEmpty && driversLicence != 'null' && driversLicence != null){
      setState(() {
        screen_width = screen_width + 25;
      });
    }

    if(screen_width < 40){
      setState(() {
        profileCompletionColor = Colors.deepOrangeAccent;
      });
    }else if(screen_width < 60){
      setState(() {
        profileCompletionColor = Colors.orange;
      });
    }else if(screen_width < 80){
      setState(() {
        profileCompletionColor = Colors.blue;
      });
    }else if(screen_width == 100){
      setState(() {
        profileCompletionColor = Colors.green;
      });
    }
    return server_response['profile'];

  }

  String calleeName = '';
  String incomingCallChannel = '';
  bool hasCall = false;
  bool noNeedForNewSound = false;
  String newCustomerName = '';
  String createdRequestId = '';
  String customer_id = '';
  String newCustomerImg = '';

  @override
  Widget build(BuildContext context) {
    if(hasCall){
      return ReceiveRequestPage(createdRequestId: createdRequestId, customer: {
        'user_id': customer_id, 'name' : newCustomerName, 'img' : newCustomerImg
      },);
    }
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
          title: Text('Profile', style: GoogleFonts.quicksand(color: darkColor),),
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
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SettingsScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.settings, color: Color.fromRGBO(7, 84, 40, 1),
                  ),
                )
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: body(),
      ),
      drawer: navigationDrawer(),
    );
  }
  double screen_width = 0;

  Widget infoSection(String title, String value){
    return Column(
      children: [
        Row(
          children: [
            Text(title, style: GoogleFonts.quicksand(color: mutedColor),),
            Spacer(),
            Text(value, style: GoogleFonts.quicksand(color: darkColor),)
          ],
        ),
        const SizedBox(height: 20,)
      ],
    );
  }

  Widget body(){
    return SingleChildScrollView(child: Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("graphics/dashboard-bg.png"),
            fit: BoxFit.cover,
          ),
          // borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child:Column(
          children: [
            SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                          decoration: new BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              image: NetworkImage(img_src),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 110,
                          alignment: Alignment.center,
                          height: 110,
                          child: SizedBox()
                      ),
                    ),
                    Positioned(
                      right: 5.0,
                      bottom: 0.0,
                      child:
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(7, 84, 40, 1)),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(top: 18, bottom: 18)),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            )
                        ),
                        onPressed: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return FaceCaptureScreen();
                          }));
                          // await select_file_avatar();
                        },
                        child: (avatar_uploading == 0) ? const Icon(Icons.camera_alt_sharp, size: 15,)
                            : const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),),
                      ),

                    )
                  ],
                ),
                SizedBox(height: 10,),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Profile completion: ${screen_width}% ', style: TextStyle(fontSize: 10),),
                              Icon(Icons.help, size: 15, color: mutedColor,)
                            ],
                          ),
                          LinearProgressIndicator(
                            value: screen_width / 100,
                            semanticsValue: screen_width.toString(),
                            valueColor: new AlwaysStoppedAnimation<Color>(profileCompletionColor),
                            backgroundColor: Colors.black12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(  // You need this, notice the parameters below:
                                builder: (BuildContext context, StateSetter setState)
                                {
                                  return AlertDialog(
                                    title: Wrap(
                                      children: [
                                        Text('Complete Your Profile'.toUpperCase(), textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red))
                                      ],
                                    ),
                                    content: SizedBox(
                                      height: 300,
                                      child: ListView(
                                        children: [
                                          ListTile(
                                            title: Text('1- Set profile picture', style: TextStyle(fontSize: 12),),
                                            trailing: (profileAvatar.isNotEmpty)
                                                ?
                                            Icon(Icons.check_circle, color: secondaryColor,)
                                                : Icon(Icons.info_rounded, color: errorColor,) ,
                                          ),
                                          ListTile(
                                            title: Text('2- Verify email', style: TextStyle(fontSize: 12),),
                                            trailing: (email_verified_at.isNotEmpty)
                                                ?
                                            Icon(Icons.check_circle, color: secondaryColor,)
                                                : Icon(Icons.info_rounded, color: errorColor,) ,
                                          ),
                                          ListTile(
                                            title: Text('3- Set your location', style: TextStyle(fontSize: 12),),
                                            trailing: (latitude.isNotEmpty && latitude.toString() != 'null')
                                                ?
                                            Icon(Icons.check_circle, color: secondaryColor,)
                                                : Icon(Icons.info_rounded, color: errorColor,) ,
                                          ),
                                          ListTile(
                                            title: Text('4- Upload a verified Identity Document', style: TextStyle(fontSize: 12),),
                                            trailing: (driversLicence.isNotEmpty && driversLicence.toString() != 'null')
                                                ?
                                            Icon(Icons.check_circle, color: secondaryColor,)
                                                : Icon(Icons.info_rounded, color: errorColor,) ,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            );
                          },
                        );
                      },
                    )
                ),
                SizedBox(height: 10,),

              ],
            ),
          ),
            (!canEdit) ? Column(
              children: [
                Divider(height: 1,),
                Container(
                  color: Colors.white,
                  child: TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReferalScreen(referalCode: referalCode,),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Referral program', style: GoogleFonts.quicksand(fontSize: 15, color: basicColor),),
                          Icon(Icons.chevron_right, color: basicColor,)
                        ],
                      )
                  ),
                ),
                Divider(height: 1,),
                Container(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: Column(
                    children: [
                      infoSection('Full Name:', fullname),
                      infoSection('Username:', username),
                      infoSection('Mobile Number:', phone),
                      infoSection('Gender:', gender),
                      infoSection('Email:', email),
                      infoSection('Address:', '....'),
                      infoSection('City of residence:', 'Port Harcourt'),
                      infoSection('Means of Identification:', 'National ID'),
                      (isArtisan == '1')
                          ?
                      infoSection('Skillset:', art_scope)
                          :
                      const SizedBox(),
                      (isArtisan == '1')
                          ?
                      infoSection('Business Name:', business_name)
                          :
                      const SizedBox(),
                      (isArtisan == '1')
                          ?
                      TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateWorkmanDataPage(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20, color: secondaryColor,),
                              Text(' Change workman data',
                                style: GoogleFonts.quicksand(fontSize: 14, color: secondaryColor),)
                            ],
                          )
                      )
                          :
                      const SizedBox(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 30, left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromRGBO(7, 84, 40, 1),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      onPressed: () async {
                        setState(() {
                          canEdit = true;
                        });
                      },
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Edit profile', style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )  : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white30,
                ),
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20,),
                      Text('Primary Info '.toUpperCase(), style: TextStyle(fontSize: 15, color: Colors.black38), textAlign: TextAlign.start,),
                      const SizedBox(height: 20,),
                      (driversLicence.isEmpty || driversLicence.toString() == 'null')
                          ?
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadIDPage(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text('Upload Means of Identification ', style: TextStyle(fontSize: 12, color: errorColor),),
                              Icon(Icons.info, color: errorColor, size: 20,)
                            ],
                          )
                      ) : const SizedBox(),
                      input_field(nameController, 'Full name', Icons.account_circle_outlined, true),
                      input_field(emailController, 'Email', Icons.email_outlined, true),
                      input_field(phoneController, 'Phone number', Icons.phone, true),
                      input_field(usernameController, 'Username', Icons.supervised_user_circle_outlined, true),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Text('Location Info '.toUpperCase(), style: TextStyle(fontSize: 15, color: Colors.black38), textAlign: TextAlign.start,),
                          Spacer(),
                          TextButton(
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyLocationPage(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text('Set', style: TextStyle(fontSize: 12),),
                                  Icon(Icons.chevron_right)
                                ],
                              )
                          )
                        ],
                      ),
                      // SizedBox(height: 20,),
                      // input_field(countryController, 'Country:', Icons.flag_outlined, true),
                      // input_field(stateController, 'State:', Icons.edit_location_rounded, true),
                      // input_field(areaController, 'Last Known Area:', Icons.map_rounded, true),
                      // input_field(localityController, 'Last Known Location:', Icons.maps_home_work_outlined, true),
                      const SizedBox(height: 20,),
                      // Center(
                      //   child: SizedBox(
                      //     width: 200,
                      //     child: ElevatedButton(
                      //       style: ElevatedButton.styleFrom(
                      //           shape: StadiumBorder(),
                      //           padding: EdgeInsets.all(15),
                      //           backgroundColor: const Color.fromRGBO(7, 84, 40, 1)
                      //       ),
                      //       onPressed: () async {
                      //         if (_formKey.currentState!.validate()) {
                      //           // If the form is valid, display a Snackbar.
                      //           setState(() {
                      //             fullname = nameController.text;
                      //             home_address_1 = homeAdressController.text;
                      //             work_address_1 = workAdressController.text;
                      //             phone = phoneController.text;
                      //             state = stateController.text;
                      //             country = countryController.text;
                      //             processing = 1;
                      //           });
                      //           await save_profile();
                      //         }
                      //       },
                      //       child:
                      //       Row(
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text('Update  '.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      //           (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                )
            )
          ],
        ),
      )
    ),
    );
  }

  bool canEdit = false;

  Column input_field (TextEditingController nController, String title, IconData icon, bool readonly){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(),),
            (title.toLowerCase().contains('email') && email_verified_at.isEmpty) ? const Spacer() : const SizedBox(),
            (title.toLowerCase().contains('email') && email_verified_at.isEmpty)
                ?
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyEmailPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text('Verify now ', style: TextStyle(fontSize: 12, color: errorColor),),
                    Icon(Icons.info, color: errorColor, size: 15,)
                  ],
                )
            )
                :
              const SizedBox()
          ],
        ),
        TextFormField(
          controller: nController,
          readOnly: readonly,
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
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Required field';
            }
            return null;
          },
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }


  Future<void> select_file_avatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'gif', 'png'],);

    if (result != null) {
      File file = File(result.files.single.path!);
      avatar = file.uri;
      setState(() {
        avatar = avatar;
        avatar_uploading = 1;
      });
      upload_avatar();
    } else {
      // User canceled the picker
    }
  }

  Future<void> upload_avatar() async {
    var client = http.Client();
    try {
      var postUri = Uri.parse(Component().API+'mobile/user/upload/avatar');
      var request = new http.MultipartRequest("POST", postUri);
      request.fields['user_id'] = user_id.toString();
      request.files.add(await http.MultipartFile.fromPath('avatar', await File.fromUri(avatar).path));
      request.send().then((response) async {
        print('=============');
        print(response.statusCode);
        if (response.statusCode == 200) {
          Component().success_toast('Uploaded successfully');
          //
          // var url = Uri.parse(Component().API+'mobile/user/avatar');
          // var response = await http.post(url, body: {
          //   'user_id': user_id.toString(),
          // });
          // print('==========----------');
          // print(response.body.toString());
          // var server_response = jsonDecode(response.body.toString());
          //
          // String img = server_response['img'].toString();
          // var session = FlutterSession();
          // await session.set("img", img);
          await getProfile();
          setState(() {
            avatar_uploading = 0;
          });
          return;

        } else {
          Component().error_toast('Select a file');
          setState(() {
            avatar_uploading = 0;
          });
          throw Exception('Failed to load activities from API');
        }
      });
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> save_profile() async {

    var client = http.Client();
    try {
      var session = FlutterSession();
      session.set('firstname', fullname);
      session.set('home_address_1', home_address_1);
      session.set('country', country);
      session.set('work_address_1', work_address_1);
      session.set('phone', phone);
      session.set('state', state);

      var url = Uri.parse(Component().API+'save/profile/action');
      var response = await http.post(url, body: {
        'firstname': fullname,
        'phone': phone,
        'state': state,
        'phone': phone,
        'work_address_1': work_address_1,
        'country': country,
        'home_address_1': home_address_1,
        'user_id': user_id.toString(),
      });
      print(response.body.toString()+'======================');
      var server_response = jsonDecode(response.body.toString());

      String status = server_response['status'].toString();
      status = status.replaceAll('[', '');
      status = status.replaceAll(']', '');
      String message = server_response['message'].toString();
      message = message.replaceAll('[', '');
      message = message.replaceAll(']', '');
      setState(() {
        processing = 0;
      });
      if(status == 'error'){
        Component().error_toast(message);

        return;
      }
      Component().success_toast(message);

      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }
}