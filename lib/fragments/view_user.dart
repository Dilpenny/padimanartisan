//import 'dart:html';

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'hire_artisan.dart';
import 'rate_user.dart';
import 'reviews.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../helpers/customer.dart';
import '../helpers/components.dart';
import 'package:url_launcher/url_launcher.dart';

import 'maps.dart';


class UserProfilePage extends StatefulWidget {
  final customerObj;
  final String from;

  const UserProfilePage({Key? key, this.customerObj, required this.from}) : super(key: key);
  @override
  UserProfilePageWidget createState() => UserProfilePageWidget(customerObj,from);
}


class UserProfilePageWidget extends State<UserProfilePage> {
  final Customer customerObj;
  final String from;
  int processing = 1;
  int logged_in = 41900000;

  UserProfilePageWidget(this.customerObj, this.from);

  final _formKey = GlobalKey<FormState>();
  bool hasCall = false;
  String incomingCallChannel = '';
  String token = "";
  var calleeImg;
  double rating = 0;
  var calleeName;
  late FirebaseMessaging _firebaseMessaging;

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 280;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.yellow,
        backgroundColor: Color.fromRGBO(7, 84, 40, 1),
        elevation: 0,
        title: Text(customerObj.art_scope!.toUpperCase(), style: GoogleFonts.karla()),
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
                        backgroundImage: NetworkImage(customerObj.img!),
                        maxRadius: 70,
                      ),
                      SizedBox(height: 10, width: double.infinity,),
                      Text(customerObj.name!, style: TextStyle(fontSize: 30, color: Colors.white),),
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
                                  if(customerObj.longitude == 'null' || customerObj.longitude == null || customerObj.latitude == 'null'){
                                    Component().error_toast('Seems not locatable!');
                                    return;
                                  }

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
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return HireArtisanPage(from: 'user-profile', customerObj: customerObj,);
                                  }));
                                },
                              ),
                          ),
                        ],
                      ),
                      profileData('Personal Information', '', 1),
                      profileData('Name:', customerObj.name!, 0),
                      profileData('Email:', customerObj.email!, 0),
                      profileData('Phone:', customerObj.phone!, 0),
                      profileData('Other Information', '', 1),
                      profileData('Rating:', rating.toString(), 0),
                      profileData('Location Information', '', 1),
                      profileData('State:', customerObj.state!, 0),
                      profileData('Country:', customerObj.country!, 0),
                      const SizedBox(height: 20,),
                      const Divider(height: 1,),
                      const SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Reviews', style: const TextStyle(color: Color.fromRGBO(7, 84, 40, 1), fontSize: 20)),
                          SizedBox(width: 20,),
                          TextButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return ReviewsPage(artisanObj: customerObj,);
                                }));
                              },
                              child: Text('View')
                          )
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
    if(value == 'null'){
      value = '';
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
                Text(title.toUpperCase(), style: const TextStyle(color: Color.fromRGBO(7, 84, 40, 1)),)
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
            Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87),),
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
    if(customerObj.rating == null || customerObj.rating == 'null'){
      setState(() {
        rating = 0.0;
      });
    }else{
      setState(() {
        rating = double.parse(customerObj.rating!);
      });
    }
  }

// Future get_profile() async {
//   String user_id = '';
//   var url = Uri.parse(Component().API+'profile?user_id='+user_id);
//   var response = await http.post(url, body: {
//     'user_id': user_id,
//   });
//   // final jsonResponse = json.decode();
//   // print(response.statusCode.toString());
//   var jsonResponses = json.decode(response.body.toString());
//   var serverResponse = jsonDecode(response.body.toString());
//   String status = serverResponse['status'].toString();
//   status = status.replaceAll('[', '');
//   status = status.replaceAll(']', '');
//   String message = serverResponse['message'].toString();
//   message = message.replaceAll('[', '');
//   message = message.replaceAll(']', '');
//   if(status == 'error'){
//     Component().error_toast(message);
//     return;
//   }
//   setState(() {
//     processing = 0;
//   });
//
//   print("==================++++++++++++++++++"+serverResponse['profile'].toString());
//   // List jsonResponse = jsonResponses['profile'];
//   // jsonResponse.map((job) => new Profile.fromJson(job)).toList();
//
//   return serverResponse['profile'];
//
// }

}