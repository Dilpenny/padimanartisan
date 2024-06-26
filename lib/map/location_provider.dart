import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'directions_model.dart';
import 'directions_repository.dart';

class LocationProvider with ChangeNotifier {

  late Directions info;
  List<String> stepsInstructions;
  BitmapDescriptor _pinLocationIcon;
  Map<MarkerId, Marker> _markers;
  Map<MarkerId, Marker> get markers => _markers;
  final MarkerId markerId = MarkerId("1");
  final MarkerId markerIdDest = MarkerId("Dest");
  Marker markerDest;
  GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  Location _location;
  Location get location => _location;
  BitmapDescriptor get pinLocationIcon => _pinLocationIcon;

  LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  LatLng _locationPositionDestination;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  LocationProvider(double lat, double lon) {
    _location = new Location();
    _locationPositionDestination= new LatLng(lat, lon);
    _markers = <MarkerId, Marker>{};
  }

  initialization() async {
    await getUserLocation();
    await setCustomMapPin();
  }


  

  _getPolyline(Marker markerDriver, Marker markerDest) async {

     LatLng origin = LatLng(markerDriver.position.latitude, markerDriver.position.longitude);
     LatLng dest = LatLng(markerDest.position.latitude, markerDest.position.longitude);
    final direction = await DirectionsRepository(dio: null).getDirections(origin: origin, dest: dest);
    if(direction!=null)
      {
        info = direction;

        notifyListeners();
        polylineCoordinates.clear();

          direction.polylinePoints.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

     _addPolyLine(info);

  }
  _addPolyLine(Directions info) {
      PolylineId id = PolylineId("poly");
      Polyline polyline = Polyline(
          polylineId: id,
          width: 5,
          color: Colors.blue,
          points: polylineCoordinates);
      polylines[id] = polyline;

      stepsInstructions= List<String>();
      for(int i =0 ; i<=info.totalSteps.length;i++){
        stepsInstructions.add(removeAllHtmlTags(info.totalSteps[i]['html_instructions'].toString()));
      }
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, ' ');
  }
  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    location.changeSettings(interval: 5000,distanceFilter: 5);

    location.onLocationChanged.listen(
      (LocationData currentLocation) {
        _locationPosition = LatLng(
          currentLocation.latitude,
          currentLocation.longitude,
        );


        moveCameraToUserLocation(currentLocation.latitude,currentLocation.longitude);

        print(_locationPosition);

        _markers.clear();

        Marker markerDriver = Marker(
          markerId: markerId,
          position: LatLng(
            _locationPosition.latitude,
            _locationPosition.longitude,
          ),

          draggable: false,
          onDragEnd: ((newPosition) {
            _locationPosition = LatLng(
              newPosition.latitude,
              newPosition.longitude,
            );

            notifyListeners();
          }),
        );

         markerDest = Marker(
          markerId: markerIdDest,
          position: _locationPositionDestination,
          icon: pinLocationIcon,


        );

        _markers[markerId] = markerDriver;
        _markers[markerIdDest] = markerDest;



        _getPolyline(markerDriver,markerDest);
        notifyListeners();
      },
    );
  }

  void moveCameraToUserLocation(double lat, double lon) async {

    LatLng location = new LatLng(lat, lon);
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15
        ),
      ),
    );
  }

  setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  setCustomMapPin() async {
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/destination_map_marker.png',
    );
  }

  takeSnapshot() {
    return _mapController.takeSnapshot();
  }

  getInfo() {
    return info;
  }

}
