import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padimanartisan/fragments/view_user.dart';
import 'dart:math' show cos, sqrt, asin;
import '../helpers/artisan.dart';
import '../map/.env.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({Key? key, required this.destinationLongitude, required this.destinationLatitude, required this.artisanObj}) : super(key: key);
  final double destinationLatitude;
  final double destinationLongitude;
  final Artisan artisanObj;
  @override
  Map_HomePageState createState() => Map_HomePageState(destinationLongitude, destinationLatitude, artisanObj);
}

class Map_HomePageState extends State<MapHomePage> {
  Completer<GoogleMapController> _controller = Completer();
// on below line we have specified camera position
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  final Artisan artisanObj;
  final double destinationLatitude;
  final double destinationLongitude;
  late double startLatitude;
  late double startLongitude;

// on below line we have created the list of markers
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )
    ),
  ];

  Map_HomePageState(this.destinationLongitude, this.destinationLatitude, this.artisanObj);
  String kilometersToDestination = '';
// created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    print('------------------- GETTING LOCATION ---------------------');
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
          backgroundColor: whiteColor,
          // on below line we have given title of app
          title: Column(
            children: [
              Text("Locating Artisan", style: GoogleFonts.quicksand(),),
              (kilometersToDestination.length < 1)
                  ? SizedBox() : Column(
                children: [
                  SizedBox(height: 4,),
                  Text(double.parse(kilometersToDestination).toStringAsFixed(2)+'km', style: TextStyle(fontSize: 12, color: Colors.yellow),)
                ],
              ),
            ],
          ),
          // actions: [
          //   GestureDetector(
          //     onTap: (){
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (BuildContext context) => UserProfilePage(artisanObj: artisanObj, from: 'map',),
          //         ),
          //       );
          //     },
          //     child: Image.network(artisanObj.img!, width: 30, height: 30,),
          //   ),
          //   SizedBox(width: 20,)
          // ]
      ),
      body: Container(
        child: SafeArea(
          // on below line creating google maps
          child: GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            // on below line setting camera position
            initialCameraPosition: _kGoogle,
            // on below line we are setting markers on the map
            markers: Set<Marker>.of(_markers),
            // on below line specifying map type.
            mapType: MapType.normal,
            // on below line setting user location enabled.
            myLocationEnabled: true,
            // on below line setting compass enabled.
            compassEnabled: true,
            // on below line specifying controller on map complete.
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
          ),
        ),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          _letsGetCurrentLocation();
        },
        child: Icon(Icons.local_activity),
      ),
    );
  }

  String _currentAddress = '';
  late Position _currentPosition;
  Set<Marker> markers = {};
  String _startAddress = '';
  String _destinationAddress = '';
  double totalDistance = 0.0;

  // Object for PolylinePoints
  late PolylinePoints polylinePoints;
  late String _placeDistance;
  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];
  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, destinationLatitude, destinationLongitude);
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        print('.................... MOM ........................1:'+point.latitude.toString());
      });
    }
    print(result.points.toString());
    // Defining an ID
    PolylineId id = PolylineId('poly');
    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    // Adding the polyline to the map
    polylines[id] = polyline;

    // Calculating the total distance by adding the distance
    // between small segments
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    // Storing the calculated total distance of the route
    setState(() {
      _placeDistance = totalDistance.toStringAsFixed(2);
      kilometersToDestination = distanceInMeters.toString();
    });

  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      // Places are retrieved using the coordinates
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude
      );
      // Taking the most probable result
      Placemark place = p[0];
      setState(() {
        // Structuring the address
        _currentAddress = "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        // Update the text of the TextField
        // startAddressController.text = _currentAddress;
        // Setting the user's present location as the starting address
        _startAddress = _currentAddress;
      });

      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark = await locationFromAddress(_destinationAddress);

      // Storing latitude & longitude of start and destination location
      double startLatitude = startPlacemark[0].latitude;
      double startLongitude = startPlacemark[0].longitude;
      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString = '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

    } catch (e) {
      print(e);
    }
  }

  void _letsGetCurrentLocation(){
    getUserCurrentLocation().then((value) async {
      _currentPosition = value;
      print(value.latitude.toString() +" "+value.longitude.toString());
      startLatitude = value.latitude;
      startLongitude = value.longitude;

      // marker added for current users location
      _markers.add(
          Marker(
            markerId: const MarkerId("2"),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: InfoWindow(
              title: 'My Current Location',
            ),
          )
      );

      _markers.add(
          Marker(
            markerId: MarkerId('artisan'),
            position: LatLng(destinationLatitude, destinationLongitude),
            infoWindow: InfoWindow(
              title: 'Destination ',
            ),
            icon: BitmapDescriptor.fromBytes(bytes),
          )
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // specified current users location
      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );

      final GoogleMapController controller = await _controller.future;
      // controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );
      if(!mounted){
        return;
      }
      await _createPolylines(startLatitude, startLongitude, destinationLatitude, destinationLongitude);
      setState(() {
      });
    });
  }
  late BitmapDescriptor customIcon;

  @override
  void initState() {
    // TODO: implement initState
    _letsGetCurrentLocation();
    _getThingsStarted(); // KEPP GETTING CURRENT LOCATION EVERY 5 MINUTES
    _getAddress();
    super.initState();
  }

  late Uint8List bytes;

  void _getThingsStarted() async {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // debugPrint(timer.tick.toString());
      _letsGetCurrentLocation();
    });
    bytes = (await NetworkAssetBundle(Uri.parse(artisanObj.img_sm!))
        .load(artisanObj.img_sm!))
        .buffer
        .asUint8List();
  }
}
