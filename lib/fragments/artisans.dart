//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/reviews.dart';
import 'package:padimanartisan/fragments/view-artisan-profile.dart';
import 'package:padimanartisan/map/.env.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../browser.dart';
import '../helpers/artisan.dart';
import '../helpers/components.dart';
import '../helpers/customer-request.dart';
import '../helpers/customer.dart';
import '../helpers/session.dart';
import 'customer-hire-artisan.dart';
import 'maps.dart';

class ArtisansPage extends StatefulWidget {
  final service;

  const ArtisansPage({super.key, required this.service});
  @override
  ArtisansPageWidget createState() => ArtisansPageWidget(service);
}

class ArtisansPageWidget extends State<ArtisansPage> {
  final service;
  int processing = 0;
  int total = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;
  late Future<List<Artisan>>? allArtisans;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  Artisan? holdingObj;
  ArtisansPageWidget(this.service);

  Widget equipmentDetail(){
    return SlidingUpPanel(
      minHeight: 0,
      controller: detailed_pc,
      panel: detailedScreen(),
      onPanelClosed: (){
        // detailed_pc.hide();
      },
      body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          margin: const EdgeInsets.only(top: 10),
          // height: screen_height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: const DecorationImage(
              image: AssetImage("graphics/dashboard-bg.png"),
              fit: BoxFit.cover,
            ),
            color: Colors.white,
          ),
          child: FutureBuilder<List<Artisan>>(
            future: allArtisans,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Artisan>? data = snapshot.data;
                if(data!.isEmpty){
                  return  Center(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(label: Text('No $service found at this time',)),
                      SizedBox(
                        width: 200,
                        child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(secondaryColor),
                                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(top: 18, bottom: 18)),
                                foregroundColor: MaterialStateProperty.all<Color>(whiteColor),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                )
                            ),
                            onPressed: (){
                              String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return MyBrowser(title: 'Chat With Agent', link: url,);
                              }));
                            },
                            child: Text('Contact Admin', style: GoogleFonts.quicksand(),)
                        ),
                      )
                    ],
                  ));
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
      borderRadius: radius,
    );
  }

  Widget detailedScreen(){
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: CircleAvatar(
                    radius: 48, // Image radius
                    backgroundImage: NetworkImage(holdingObj?.img! ?? ''),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 50,),
                GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MapHomePage(destinationLongitude: double.parse(holdingObj?.longitude! ?? '0'),
                            destinationLatitude: double.parse(holdingObj?.latitude! ?? '0'), artisanObj: holdingObj!,),
                        ),
                      );
                    },
                    child: Image.asset('graphics/location.png', width: 40,)
                ),
                const Spacer(),
                OutlinedButton(
                  child: Text('Reviews',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: secondaryColor),),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    side: BorderSide(color: secondaryColor, width: 2),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ReviewsPage(artisanObj: Customer(
                        name: holdingObj?.name! ?? 'John doe',
                        email: holdingObj?.latitude! ?? '',
                        phone: holdingObj?.phone! ?? '',
                        latitude: holdingObj?.latitude! ?? '0',
                        longitude: holdingObj?.longitude! ?? '0',
                        art_scope: holdingObj?.art_scope! ?? '',
                        area: holdingObj?.area! ?? '',
                        country: holdingObj?.country! ?? 'Nigeria',
                        state: holdingObj?.state! ?? 'Lagos',
                        slug: holdingObj?.slug! ?? '',
                        id: holdingObj?.id! ?? '0',
                        img: holdingObj?.img! ?? '',
                        img_sm: holdingObj?.img_sm! ?? '',
                        device_token: holdingObj?.device_token! ?? '',
                        rating: holdingObj?.rating! ?? '0',
                      ),);
                    }));
                  },
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text(holdingObj?.name! ?? '', style: GoogleFonts.quicksand(fontSize: 15),),
              ],
            ),
            const SizedBox(height: 10,),
            Text(holdingObj?.art_scope! ?? '',
              style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            RatingBarIndicator(
              rating: (holdingObj?.rating == null || holdingObj?.rating == 'null') ? 0 : double.parse(holdingObj?.rating!.toString()  ?? '0'),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 40.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 10,),
            const Divider(height: 1,),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Skill set:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.art_scope! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Years of Experience:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.years_of_experience! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Location:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                const SizedBox(width: 10,),
                Text(holdingObj?.country! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                      child: Text('Cancel',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: secondaryColor),),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(40))),
                        side: BorderSide(color: secondaryColor, width: 2),
                      ),
                      onPressed: () {
                        setState(() {
                          holdingObj = null;
                        });
                        // detailed_pc.show();
                        detailed_pc.close();
                      },
                    )
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(  // You need this, notice the parameters below:
                              builder: (BuildContext context, StateSetter setState)
                              {
                                return AlertDialog(
                                  title: Text('What is your\nMODE OF PAYMENT?'.toUpperCase(), textAlign: TextAlign.center,
                                      style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.bold, color: secondaryColor)),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: primaryColor,
                                            ),
                                            onPressed: () async {
                                              var session = FlutterSession();
                                              await session.set("payment_method", 'wallet');
                                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                                return HireArtisanPage(from: 'user-profile', artisanObj: holdingObj,
                                                    requestObj: CustomerRequest(
                                                        amount: '', status_code: '', time_ago: '', service: '', payment_method: ''
                                                    )
                                                );
                                              }));
                                            },
                                            child: Row(
                                              children: [
                                                Text('WALLET', style: GoogleFonts.quicksand(color: secondaryColor),),
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
                                                return HireArtisanPage(from: 'user-profile', artisanObj: holdingObj,
                                                  requestObj: CustomerRequest(
                                                      amount: '', status_code: '', time_ago: '', service: '', payment_method: ''
                                                  ),);
                                              }));
                                            },
                                            child: Row(
                                              children: [
                                                Text('ONLINE', style: GoogleFonts.quicksand(color: secondaryColor),),
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
                    child: Text('Hire', style:
                    GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.w600),),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  PanelController detailed_pc = PanelController();
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  ListView _jobsListView(data, BuildContext context) {
    return ListView.builder(
      itemCount: total,
      itemBuilder: (context, index) {
        double rating = 0;
        if(data[index].rating == null || data[index].rating == 'null'){
          rating = 0.0;
        }else{
          rating = double.parse(data[index].rating);
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
                  style: GoogleFonts.quicksand(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
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
              ],
            ),
            onTap: (){
              setState(() {
                holdingObj = data[index];
              });
              detailed_pc.show();
              detailed_pc.open();
            },
            trailing: PopupMenuButton<int>(
              onSelected: (item){
                if(item == 1){
                  if(data[index].longitude == 'null' || data[index].longitude == null || data[index].latitude == 'null'){
                    Component().error_toast('Seems not locatable!');
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MapHomePage(destinationLongitude: double.parse(data[index].longitude),
                        destinationLatitude: double.parse(data[index].latitude), artisanObj: data[index],),
                    ),
                  );
                }
                if(item == 2){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => UserProfilePage(artisanObj: data[index], from: 'artisan-list',),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 1, child: Row(
                  children: const [
                    Icon(Icons.location_on_outlined, color: Colors.black54,),
                    Text(' View on map', style: TextStyle(color: Colors.black54, fontSize: 14),)
                  ],
                )),
                PopupMenuItem<int>(value: 2, child: Row(
                  children: const [
                    Icon(Icons.account_circle, color: Colors.black54,),
                    Text(' Profile', style: TextStyle(color: Colors.black54, fontSize: 14),)
                  ],
                )),
              ],
            ),
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
    double screen_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Text("Select a $service", style: GoogleFonts.quicksand(),),
          actions: [

          ]
      ),
      backgroundColor: whiteColor,
      body:  Container(
          width: double.infinity,
          height: screen_height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: const DecorationImage(
              image: AssetImage("graphics/dashboard-bg.png"),
              fit: BoxFit.cover,
            ),
            color: Colors.white,
          ),
          child: equipmentDetail()
      ),
    );
  }

  late Position _currentPosition;
  late String _currentAddress;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    firstThings();
    allArtisans = _fetchArtisans();
    super.initState();
  }

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
  }

  Future<List<Artisan>> _fetchArtisans() async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/fetch/artisans?type=$service&user_id=$userId';

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
        print(jsonResponses.toString());
        List jsonResponse;
        jsonResponse = jsonResponses['artisans']['data'];
        setState(() {
          total = int.parse(jsonResponses['artisans']['total'].toString());
        });
        return jsonResponse.map((job) => Artisan.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

}