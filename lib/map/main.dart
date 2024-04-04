import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'MyMapScreen.dart';
import 'TaskDetail.dart';
import 'location_map.dart';
import 'location_provider.dart';


Color myHexColor = Color(0xff003499);
var task =TaskDetail("", "", "",0, 0);


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  TaskDetail _taskDetail= TaskDetail("01", "Destination Address", "", 48.51,14.55);

  runApp( MyMapScreen(_taskDetail));

}



class MyMapScreen extends StatelessWidget {
  MyMapScreen(TaskDetail taskDetails){
    _taskDetail= taskDetails;
  }

  TaskDetail _taskDetail= TaskDetail("01", "Destination Address", "", 48.51,14.55);


  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(_taskDetail.lat,_taskDetail.lon),
          child: LocationMap(_taskDetail),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Map',
        home: LocationMap(_taskDetail),
      ),
    ), onWillPop: () {
      return Future.value(true); // if true allow back else block it
    } );
  }
}






