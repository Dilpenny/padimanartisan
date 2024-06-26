import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions{
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final List totalSteps;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.totalSteps
});

  factory Directions.fromMap(Map<String, dynamic> map){
    // Check if route is not available
    // if((map['routes'] as List).isEmpty) return null;

    // Get route information
    final data = Map<String,dynamic>.from(map['routes'][0]);

    //Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
        southwest: LatLng(southwest['lat'],southwest['lng']),
        northeast:  LatLng(northeast['lat'],northeast['lng']));


    //Distance & Duration
    String distance ='';
    String duration ='';
    if((data['legs'] as List).isNotEmpty){
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];


    }



    return Directions(bounds: bounds,
        polylinePoints: PolylinePoints().decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration,
        totalSteps: data['legs'][0]['steps'] as List);

  }

}