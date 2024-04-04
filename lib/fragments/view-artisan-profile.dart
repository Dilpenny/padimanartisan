//import 'dart:html';

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../helpers/artisan.dart';
import '../helpers/components.dart';

import '../helpers/customer-request.dart';
import '../helpers/session.dart';
import '../map/.env.dart';
import 'chat_detail_page.dart';
import 'customer-hire-artisan.dart';
import 'maps.dart';


class UserProfilePage extends StatefulWidget {
  final artisanObj;
  final String from;

  const UserProfilePage({Key? key, this.artisanObj, required this.from}) : super(key: key);
  @override
  UserProfilePageWidget createState() => UserProfilePageWidget(artisanObj,from);
}


class UserProfilePageWidget extends State<UserProfilePage> {
  final Artisan artisanObj;
  final String from;
  int processing = 1;
  int logged_in = 41900000;

  UserProfilePageWidget(this.artisanObj, this.from);

  final _formKey = GlobalKey<FormState>();
  bool hasCall = false;
  String incomingCallChannel = '';
  String token = "";
  var calleeImg;
  double rating = 0;
  var calleeName;

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 210;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.yellow,
        backgroundColor: Color.fromRGBO(7, 84, 40, 1),
        elevation: 0,
        title: Text(artisanObj.art_scope!.toUpperCase(), style: GoogleFonts.karla()),
      ),
      backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(artisanObj.img!),
                        maxRadius: 70,
                      ),
                      SizedBox(height: 10, width: double.infinity,),
                      Text(artisanObj.name!, style: TextStyle(fontSize: 30, color: Colors.white),),
                      SizedBox(height: 10, width: double.infinity,),
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 50.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(height: 10, width: double.infinity,),
                    ],
                  ),
                ),
                Container(
                  height: screen_height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.yellow,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Text(" View on map ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color.fromRGBO(7, 84, 40, 1)),),
                                    Icon(Icons.location_on, size: 20, color: const Color.fromRGBO(7, 84, 40, 1),)
                                  ],
                                ),
                              ),
                              onTap: () {
                                if(from.contains('map')){
                                  Navigator.pop(context);
                                  return;
                                }
                                if(artisanObj.longitude == 'null' || artisanObj.longitude == null || artisanObj.latitude == 'null'){
                                  Component().error_toast('Seems not locatable!');
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => MapHomePage(destinationLongitude: double.parse(artisanObj.longitude!),
                                      destinationLatitude: double.parse(artisanObj.latitude!), artisanObj: artisanObj,),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: const Color.fromRGBO(7, 84, 40, 1),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Text(" HIRE NOW ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.yellow),),
                                    Icon(Icons.check_circle, size: 20, color: Colors.yellow,)
                                  ],
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(  // You need this, notice the parameters below:
                                        builder: (BuildContext context, StateSetter setState)
                                        {
                                          return AlertDialog(
                                            title: Text('What is your\nMODE OF PAYMENT?'.toUpperCase(), textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: secondaryColor)),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: primaryColor,
                                                      ),
                                                      onPressed: () async {
                                                        var session = FlutterSession();
                                                        await session.set("payment_method", 'cash');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                                          return HireArtisanPage(from: 'user-profile', artisanObj: artisanObj,
                                                              requestObj: CustomerRequest(
                                                                  amount: '', status_code: '', time_ago: '', service: '', payment_method: ''
                                                              )
                                                          );
                                                        }));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text('CASH', style: TextStyle(color: secondaryColor),),
                                                          Spacer(),
                                                          Icon(Icons.chevron_right, color: secondaryColor)
                                                        ],
                                                      )
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: primaryColor,
                                                      ),
                                                      onPressed: () async {
                                                        var session = FlutterSession();
                                                        await session.set("payment_method", 'wallet');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                                          return HireArtisanPage(from: 'user-profile', artisanObj: artisanObj,
                                                              requestObj: CustomerRequest(
                                                                  amount: '', status_code: '', time_ago: '', service: '', payment_method: ''
                                                              )
                                                          );
                                                        }));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text('WALLET', style: TextStyle(color: secondaryColor),),
                                                          Spacer(),
                                                          Icon(Icons.chevron_right, color: secondaryColor)
                                                        ],
                                                      )
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: primaryColor,
                                                      ),
                                                      onPressed: () async {
                                                        var session = FlutterSession();
                                                        await session.set("payment_method", 'online');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                                          return HireArtisanPage(from: 'user-profile', artisanObj: artisanObj,
                                                            requestObj: CustomerRequest(
                                                                amount: '', status_code: '', time_ago: '', service: '', payment_method: ''
                                                            ),);
                                                        }));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text('ONLINE', style: TextStyle(color: secondaryColor),),
                                                          Spacer(),
                                                          Icon(Icons.chevron_right, color: secondaryColor)
                                                        ],
                                                      )
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
                            ),
                          ),
                        ],
                      ),
                      profileData('Personal Information', '', 1),
                      profileData('Name:', artisanObj.name!, 0),
                      profileData('Email:', '**************', 0),
                      profileData('Phone:', '**********', 0),
                      profileData('Other Information', '', 1),
                      profileData('Rating:', rating.toString(), 0),
                      profileData('Location Information', '', 1),
                      profileData('State:', artisanObj.state!, 0),
                      profileData('Country:', artisanObj.country!, 0),
                      const SizedBox(height: 20,),
                      const Divider(height: 1,),
                      const SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Reviews', style: const TextStyle(color: Color.fromRGBO(7, 84, 40, 1), fontSize: 20)),
                          SizedBox(width: 20,),
                          // TextButton(
                          //     onPressed: (){
                          //       Navigator.push(context, MaterialPageRoute(builder: (context){
                          //         return ReviewsPage(artisanObj: artisanObj,);
                          //       }));
                          //     },
                          //     child: Text('View')
                          // )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }

  Column profileData(String title, String value, int isHeading){
    double fontSize = 14;
    if(value == 'null'){
      value = '';
    }
    if(value.contains('**')){
      fontSize = 30;
    }
    return Column(
      children: [
        (isHeading == 1)
            ?
        Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              children: [
                Text(title.toUpperCase(), style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1)),)
              ],
            ),
            const SizedBox(height: 10,),
          ],
        )
            :
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black38),),
            const SizedBox(width: 20,),
            Text(value, style: TextStyle(fontSize: fontSize, color: Colors.black87),),
          ],
        ),
        const SizedBox(height: 10,)
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    initializePage();
    super.initState();
  }

  void initializePage(){
    if(artisanObj.rating == null || artisanObj.rating == 'null'){
      setState(() {
        rating = 0.0;
      });
    }else{
      setState(() {
        rating = double.parse(artisanObj.rating!);
      });
    }
  }
}