//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../map/.env.dart';
import 'assets.dart';
import 'edit_asset.dart';
import 'locator.dart';
import 'maps.dart';
import 'view_user.dart';
import '../helpers/customer.dart';
import '../helpers/asset.dart';
import '../helpers/review.dart';
import '../helpers/services.dart';
import '../helpers/customer.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class ReviewsPage extends StatefulWidget {
  final Customer artisanObj;

  const ReviewsPage({super.key, required this.artisanObj});
  @override
  ReviewsPageWidget createState() => ReviewsPageWidget(artisanObj);
}

class ReviewsPageWidget extends State<ReviewsPage> {
  final Customer artisanObj;
  int processing = 0;
  int total = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;
  late Future<List<Review>>? allReviews;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();

  ReviewsPageWidget(this.artisanObj);

  ListView _jobsListView(data, BuildContext context) {
    return ListView.builder(
      itemCount: total,
      itemBuilder: (context, index) {
        double rating = 0;
        if(data[index].star == 'null' || data[index].name == null){
          rating = 0;
        }else{
          rating = double.parse(data[index].star.toString());
        }
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: defaultColor,
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    data[index].name,
                    style: GoogleFonts.quicksand(fontSize: 15.0, fontWeight: FontWeight.bold)
                ),
                Text(
                    data[index].review,
                    style: GoogleFonts.quicksand(fontSize: 12.0,)
                ),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const Spacer(),
                    Text(data[index].time, style: GoogleFonts.quicksand(fontSize: 10, color: Colors.black54),)
                  ],
                )
              ],
            ),
            onTap: (){

            },
            leading: CircleAvatar(
              backgroundColor: Colors.yellow[400],
              radius: 20,
              backgroundImage: NetworkImage(data[index].img), //Text
            ),
          ),
        );
      },
    );
  }

  bool canFetchServicesNow = false;
  String progressMessage = 'Fetching artisans near you...';
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Text("${artisanObj.name} reviews", style: GoogleFonts.quicksand(),),
        
      ),
      backgroundColor: whiteColor,
      body:  Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 10),
          height: screen_height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: const DecorationImage(
              image: AssetImage("graphics/dashboard-bg.png"),
              fit: BoxFit.cover,
            ),
            color: Colors.white,
          ),
          child: FutureBuilder<List<Review>>(
            future: allReviews,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Review>? data = snapshot.data;
                if(data!.isEmpty){
                  return  const Center(child: Chip(label: Text('No review found',)));
                }
                return Container(
                  padding: const EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
                  child: _jobsListView(data, context),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());
                return const Center(child: Chip(label: Text('No or Bad internet connection',)));
              }
              return Center(
                  child: Column(
                    children: [
                      Text(progressMessage, style: TextStyle(fontSize: 12, color: Colors.black45),),
                      Component().line_loading()
                    ],
                  )
              );
            },
          )
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    firstThings();
    allReviews = _fetchReviews();
    super.initState();
  }

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
  }

  Future<List<Review>> _fetchReviews() async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/user/reviews?user_id='+artisanObj.id.toString();

      // if(searching.isNotEmpty){
      //   basicUrl = '$basicUrl&search=$searching';
      // }
      //
      var url = Uri.parse(basicUrl);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponses = json.decode(response.body);
        if(jsonResponses == null){
          // return [];
          // return Center(child: Chip(label: Text('No data found',)));
        }

        List jsonResponse;
        jsonResponse = jsonResponses['reviews']['data'];
        setState(() {
          total = int.parse(jsonResponses['reviews']['total'].toString());
        });
        return jsonResponse.map((job) => Review.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

}