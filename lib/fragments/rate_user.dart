//import 'dart:html';

import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/reviews.dart';
import 'package:padimanartisan/home_page.dart';
import '../helpers/customer.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class RateUserPage extends StatefulWidget {
  final Customer artisanObj;

  const RateUserPage({super.key, required this.artisanObj});
  @override
  RateUserPageWidget createState() => RateUserPageWidget(artisanObj);
}


class RateUserPageWidget extends State<RateUserPage> {
  final Customer artisanObj;
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  RateUserPageWidget(this.artisanObj);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController reviewController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String review = '';
  String selectedRating = '';

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.yellow,
        backgroundColor: Color.fromRGBO(7, 84, 40, 1),
        elevation: 0,
        title: Text("Rate ${artisanObj.name}"),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ReviewsPage(artisanObj: artisanObj,);
                }));
              },
              icon: const Icon(Icons.playlist_add_check_circle)
          )
        ],
      ),
      backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
      body: SingleChildScrollView(
          child: Container(
              height: screen_height,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child:
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                              setState(() {
                                selectedRating = rating.toString();
                              });
                            },
                          ),
                          SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("How do you feel about ${artisanObj.name}?", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: reviewController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Icon(Icons.comment),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3, color: const Color.fromRGBO(7, 84, 40, 1)), //<-- SEE HERE
                              )
                              // hintText: 'Password',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required field';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20,),

                          SizedBox(height: 20,),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: const Color.fromRGBO(7, 84, 40, 1)
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    processing = 1;
                                    review = reviewController.text;
                                  });
                                  await saveReview();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(' Send  '.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
          )
      ),
    );
  }

  Future<void> saveReview() async {

    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse(Component().API+'mobile/add/review');
      var response = await http.post(url, body: {
        'review': review,
        'star': selectedRating,
        'rater_id': user_id.toString(),
        'user_id': artisanObj.id,
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
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
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
    setState(() {
      imgurl = imgurl;
      user_id = user_id;
    });
  }

}