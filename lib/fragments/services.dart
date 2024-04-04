//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../helpers/components.dart';
import '../helpers/services.dart';
import '../helpers/session.dart';
import '../map/.env.dart';
import 'artisans.dart';

class ServicePage extends StatefulWidget {

  @override
  ServicePageWidget createState() => ServicePageWidget();
}

class ServicePageWidget extends State<ServicePage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;
  late Future<List<PadimanServices>>? allServices;
  String searching = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();


  Column deleteAssetView(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: TextButton(
              onPressed: () {
                _setState(() {
                  processing = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Later', style: TextStyle(fontSize: 12, color: Colors.black38),),
            )),
            Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.only(left: 20,right: 8,top: 2,bottom: 2),
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.red,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Yes delete  ", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.white),),
                        (processing == 1) ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white,),) : const Icon(Icons.delete,color: Colors.white,size: 15,),
                      ],
                    ),
                  ),
                  onTap: () async {
                    // await deleteAsset();
                  },
                )
            ),
          ],
        ),
      ],
    );
  }

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

  GridView _jobsListView(data, BuildContext context) {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: total,
      itemBuilder: (ctx, index) {
        Icon icon;
        if(data[index].slug.toString().contains('mechan')){
          icon = Icon(Icons.car_repair, color: Colors.yellow, size: 50,);
        }else if(data[index].slug.toString().contains('wash')){
          icon = Icon(Icons.local_car_wash, color: Colors.yellow, size: 50,);
        }else{
          icon = Icon(Icons.bluetooth_drive_rounded, color: Colors.yellow, size: 50,);
        }
        return GestureDetector(
          child: Card(
            color: defaultColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                      decoration:
                      BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(data[index].avatar)
                          )
                    ),
                    child: SizedBox(height: 100,),
                  ),
                  const SizedBox(height: 5,),
                  Text(data[index].name, style: GoogleFonts.quicksand(color: darkColor),),
                  Row(
                    children: [
                      Text(data[index].total, style:
                        GoogleFonts.quicksand(fontSize: 25, color: darkColor, fontWeight: FontWeight.bold),),
                      const Spacer(),
                      Icon(Icons.arrow_circle_right_sharp, color: secondaryColor, size: 30,)
                    ],
                  )
                ],
              ),
            ),
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ArtisansPage(service: data[index].name),
              ),
            );
          },
        );
      }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: 0.0,
      mainAxisSpacing: 2,
      mainAxisExtent: 184,
    ),
    );
  }

  bool canFetchServicesNow = false;
  String progressMessage = 'Getting your current location...';
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text("Find a Service", style: GoogleFonts.quicksand(),),
        // actions: [
        //   PopupMenuButton<int>(
        //     onSelected: (item){
        //       if(item == 2){
        //         // Navigator.push(
        //         //   context,
        //         //   MaterialPageRoute(
        //         //     builder: (BuildContext context) => EditAssetPage(assetObj: assetObj),
        //         //   ),
        //         // );
        //       }
        //       if(item == 419){
        //         showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             return StatefulBuilder(  // You need this, notice the parameters below:
        //                 builder: (BuildContext context, StateSetter setState)
        //                 {
        //                   _setState = setState;
        //                   return AlertDialog(
        //                     title: Wrap(
        //                       children: [
        //                         Text('Delete this asset?'.toUpperCase(), textAlign: TextAlign.center,
        //                             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red))
        //                       ],
        //                     ),
        //                     content: SingleChildScrollView(
        //                       child: deleteAssetView(context),
        //                     ),
        //                   );
        //                 }
        //             );
        //           },
        //         );
        //       }
        //     },
        //     itemBuilder: (context) => [
        //       PopupMenuItem<int>(value: 0, child: Row(
        //         children: const [
        //           Icon(Icons.car_crash_outlined, color: Colors.black,),
        //           Text(' Find a Mechanic', style: TextStyle(color: Colors.black),)
        //         ],
        //       )),
        //       PopupMenuItem<int>(value: 10, child: Row(
        //         children: const [
        //           Icon(Icons.water_drop_sharp, color: Colors.black,),
        //           Text(' Find a Car wash', style: TextStyle(color: Colors.black),)
        //         ],
        //       )),
        //       PopupMenuItem<int>(value: 1, child: Row(
        //         children: const [
        //           Icon(Icons.history, color: Colors.blue,),
        //           Text(' View history', style: TextStyle(color: Colors.blue),)
        //         ],
        //       )),
        //       PopupMenuItem<int>(value: 2, child: Row(
        //         children: const [
        //           Icon(Icons.edit, color: Colors.green,),
        //           Text(' Edit', style: TextStyle(color: Colors.green),)
        //         ],
        //       )),
        //       PopupMenuItem<int>(value: 419, child: Row(
        //         children: const [
        //           Icon(Icons.delete, color: Colors.red,),
        //           Text(' Delete', style: TextStyle(color: Colors.red),)
        //         ],
        //       )),
        //     ],
        //   ),
        // ]
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Wrap(
                    children: [
                      Text('Get a handy workman to suit your need.',
                        style: GoogleFonts.quicksand(),)
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(20),
                    child: searchBar()
                ),
                (canFetchServicesNow) ? FutureBuilder<List<PadimanServices>>(
                  future: allServices,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<PadimanServices>? data = snapshot.data;
                      if(data!.isEmpty){
                        return  const Center(child: Chip(label: Text('No service found',)));
                      }
                      return Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
                          child: Column(
                            children: [
                              _jobsListView(data, context),
                            ],
                          )
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return const Center(child: Chip(label: Text('No or Bad internet connection',)));
                    }
                    return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(progressMessage, style: const TextStyle(fontSize: 12, color: Colors.black45),),
                            Component().line_loading()
                          ],
                        )
                    );
                  },
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(progressMessage, style: const TextStyle(fontSize: 12, color: Colors.black45),),
                    Component().line_loading(),
                    (state.isNotEmpty) ? Column(
                      children: [
                        const SizedBox(height: 10,),
                        const Divider(height: 1,),
                        const SizedBox(height: 10,),
                        Text('Or'.toUpperCase(), style: const TextStyle(fontSize: 30),),
                        const SizedBox(height: 10,),
                        const Divider(height: 1,),
                        const SizedBox(height: 10,),
                        OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                processing = 0;
                                canFetchServicesNow = true;
                                progressMessage = 'Fetching service data';
                              });
                              allServices = fetchServices();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text('I have not moved to a new location',
                                    style: GoogleFonts.quicksand(fontSize: 14, color: secondaryColor, fontWeight: FontWeight.bold),)
                                ],
                              ),
                            )
                        )
                      ],
                    ) : const SizedBox(),

                  ],
                )
              ],
            )
        ),
      ),
    );
  }

  Form searchBar(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 16,left: 0,right: 0),
        child: TextFormField(
          controller: searchController,
          onChanged: (String search){
            setState(() {
              searching = search;
            });
            // allServices = _fetchJobs();
          },
          decoration: InputDecoration(
            hintText: "Type in profession...",
            hintStyle: TextStyle(color: Colors.grey.shade900),
            prefixIcon: Icon(Icons.search,color: Colors.grey.shade900, size: 20,),
            filled: true,
            fillColor: Colors.grey.shade300,suffixIcon: const Material(
            elevation: 5.0,
            color: secondaryColor,
            shadowColor: secondaryColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
            child: Icon(Icons.search, color: Colors.white),
          ),
            contentPadding:
            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                    color: Colors.grey.shade100
                )
            ),
          ),
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

  Future<List<PadimanServices>> saveMyLocation(String area, String locality, String subLocality, String thoroughfare,
      String subThoroughfare, String state) async {
    if(canFetchServicesNow){
      return fetchServices();
    }
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/update_locations');
      print('0.01');
      var response = await http.post(url, body: {
        'state': state,
        'fetch_services': '1',
        'area': area,
        'sub_locality': subLocality,
        'thoroughfare': thoroughfare,
        'locality': locality,
        'user_id': user_id.toString(),
        'sub_thoroughfare': subThoroughfare,
      });
      print('...........................................');
      print('0.9');
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
      List jsonResponse;
      jsonResponse = server_response['services']['data'];
      total = int.parse(server_response['services']['total'].toString());
      return jsonResponse.map((job) => PadimanServices.fromJson(job)).toList();

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  int total = 0;

  Future<List<PadimanServices>> fetchServices() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/fetch/services');
      var response = await http.post(url, body: {
        'state': '',
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
      // Component().success_toast(message);
      setState(() {
        processing = 0;
        canFetchServicesNow = true;
        progressMessage = 'Fetching service data';
      });
      List jsonResponse;
      jsonResponse = server_response['services']['data'];
      total = int.parse(server_response['services']['total'].toString());
      return jsonResponse.map((job) => PadimanServices.fromJson(job)).toList();

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

  Future<void> _getCurrentPosition() async {
    if(canFetchServicesNow){
      return;
    }
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
    if(canFetchServicesNow){
      return;
    }
    await placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      var session = FlutterSession();
      session.set("state", place.administrativeArea!);

      allServices = saveMyLocation(place.subAdministrativeArea!, place.locality!, place.subLocality!,
          place.thoroughfare!, place.subThoroughfare!, place.administrativeArea!);
      setState(() {
        _currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String state = '';

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
    state = await session.get('state');
    setState(() {
      state = state;
    });

  }

}