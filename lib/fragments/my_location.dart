//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class MyLocationPage extends StatefulWidget {

  @override
  MyLocationPageWidget createState() => MyLocationPageWidget();
}

class MyLocationPageWidget extends State<MyLocationPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();

  Column actionBoxes(){
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
              onPressed: (){},
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.white10),
              ),
              child: Column(
                children: [
                  ImageIcon(AssetImage('graphics/mechanic.png',), size: 100, color: Colors.black,),
                  Text('Mechanic', style: TextStyle(fontSize: 20, color: Colors.black),),
                ],
              )
          ),
        ),
        SizedBox(height: 4,),
        Divider(height: 1,),
        SizedBox(height: 4,),
        SizedBox(
          width: double.infinity,
          child: TextButton(
              onPressed: (){},
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.white10),
              ),
              child: Column(
                children: [
                  ImageIcon(AssetImage('graphics/car-wash.png',), size: 100, color: Colors.black,),
                  Text('Car wash', style: TextStyle(fontSize: 20, color: Colors.black),),
                ],
              )
          ),
        ),
      ],
    );
  }

  bool canFetchServicesNow = false;
  String progressMessage = 'Getting your location...';
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Text("Set my service location", style: GoogleFonts.quicksand(),),
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Container(
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
            child: (canFetchServicesNow) ? Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 70, color: secondaryColor,),
                  Text('Location saved!!', style: TextStyle(color: secondaryColor, fontSize: 30),)
                ],
              ),
            ) : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(progressMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black45, fontStyle: FontStyle.italic),),
                Text('Make sure you are in your WORKSHOP while during this process', textAlign: TextAlign.center, style: GoogleFonts.quicksand(fontSize: 25, color: Colors.black45),),
                Component().line_loading()
              ],
            )
        ),
      ),
    );
  }

  Widget actions(String? title, String value){
    if(value.isEmpty || value == 'null'){
      return const SizedBox();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){

          },
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!.substring(0, 1).toUpperCase()+title.substring(1),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                ],
              ),
              const Spacer(),
              Text(value,style: const TextStyle(color: Colors.black, fontSize: 20))
            ],
          ),
        ),
        const SizedBox(height: 10,),
        const Divider(height: 0.5, color: Colors.black26,),
        const SizedBox(height: 10,),
      ],
    );
  }

  late Position _currentPosition;
  late String _currentAddress;

  Future<List> saveMyLocation(String area, String locality, String subLocality, String thoroughfare,
      String subThoroughfare, String state, String country, String longitude, String latitude) async {
    var client = http.Client();
    try {
      var session = FlutterSession();

      await session.set("country", country);
      await session.set("state", state);

      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/update_locations');
      var response = await http.post(url, body: {
        'longitude': longitude,
        'latitude': latitude,
        'state': state,
        'country': country,
        'area': area,
        'sub_locality': subLocality,
        'thoroughfare': thoroughfare,
        'locality': locality,
        'user_id': user_id.toString(),
        'sub_thoroughfare': subThoroughfare,
      });
      print('...........................................');
      print(response.body.toString());
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
        _setState(() {
          processing = 0;
        });
        return [];
      }
      Component().success_toast(message);
      setState(() {
        processing = 0;
        canFetchServicesNow = true;
        progressMessage = 'Fetching service data';
      });
      return [];
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      Component().error_toast('Please goto SETTINGS and put ON your GPS');
      Navigator.pop(context);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        Component().error_toast('Please goto SETTINGS and put ON your GPS');
        Navigator.pop(context);
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

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      saveMyLocation(place.subAdministrativeArea!, place.locality!, place.subLocality!,
          place.thoroughfare!, place.subThoroughfare!, place.administrativeArea!, place.country!,
          position.longitude.toString(), position.latitude.toString(),
      );
      setState(() {
        _currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
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
    _getCurrentPosition();
    user_id = await session.getInt('id');

  }

}