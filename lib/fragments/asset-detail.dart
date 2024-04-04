//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/asset.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import 'edit_asset.dart';
import 'locator.dart';

class AssetDetailPage extends StatefulWidget {
  final assetObj;

  const AssetDetailPage({super.key, required this.assetObj});
  @override
  AssetDetailPageWidget createState() => AssetDetailPageWidget(assetObj);
}

class AssetDetailPageWidget extends State<AssetDetailPage> {
  final CustomerAsset assetObj;
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();

  AssetDetailPageWidget(this.assetObj);

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
                    await deleteAsset();
                  },
                )
            ),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Text("Asset information", style: GoogleFonts.quicksand(),),
          actions: [
            PopupMenuButton<int>(
              onSelected: (item){
                if(item == 2){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => EditAssetPage(assetObj: assetObj),
                    ),
                  );
                }
                if(item == 419){
                   showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(  // You need this, notice the parameters below:
                          builder: (BuildContext context, StateSetter setState)
                          {
                            _setState = setState;
                            return AlertDialog(
                              title: Wrap(
                                children: [
                                  Text('Delete this asset?'.toUpperCase(), textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red))
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: deleteAssetView(context),
                              ),
                            );
                          }
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Row(
                  children: const [
                    Icon(Icons.car_crash_outlined, color: Colors.black,),
                    Text(' Find a Mechanic', style: TextStyle(color: Colors.black),)
                  ],
                )),
                PopupMenuItem<int>(value: 10, child: Row(
                  children: const [
                    Icon(Icons.water_drop_sharp, color: Colors.black,),
                    Text(' Find a Car wash', style: TextStyle(color: Colors.black),)
                  ],
                )),
                PopupMenuItem<int>(value: 1, child: Row(
                  children: const [
                    Icon(Icons.history, color: Colors.blue,),
                    Text(' View history', style: TextStyle(color: Colors.blue),)
                  ],
                )),
                PopupMenuItem<int>(value: 2, child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.green,),
                    Text(' Edit', style: TextStyle(color: Colors.green),)
                  ],
                )),
                PopupMenuItem<int>(value: 419, child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red,),
                    Text(' Delete', style: TextStyle(color: Colors.red),)
                  ],
                )),
              ],
            ),
          ]
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Container(
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
            child:
            Column(
              children: [
                slide(),
                const SizedBox(height: 20,),
                actions('Asset ID:', assetObj.slug!),
                actions('Model:', assetObj.model!),
                actions('Year:', assetObj.year!),
                actions('Chassis Number:', assetObj.chassis_number!),
                actions('Plate Number:', assetObj.plate_number!),
                actions('Requests:', assetObj.requests!),
                actions('Color:', assetObj.color!),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        primary: const Color.fromRGBO(7, 84, 40, 1),
                        padding: const EdgeInsets.all(15)
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => GeolocatorWidget(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Find a Mechanic ', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_forward, color: Colors.yellow, size: 20,)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        primary: Colors.yellow,
                        padding: const EdgeInsets.all(15)
                    ),
                    onPressed: () async {

                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Find a Car wash ', style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1), fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_forward, color: Color.fromRGBO(7, 84, 40, 1), size: 20,)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }

  Widget slide(){
    int slideSize = 1;
    if(assetObj.photo2! != 'null'){
      slideSize++;
    }
    if(assetObj.photo3! != 'null'){
      slideSize++;
    }
    return
    CarouselSlider.builder(
      itemCount: slideSize,
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
      ),
      itemBuilder: (context, index, realIdx) {
        return Container(
          child: Center(
              child: GestureDetector(
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(  // You need this, notice the parameters below:
                          builder: (BuildContext context, StateSetter setState)
                          {
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Image.network(assetObj.photo1!, fit: BoxFit.cover, width: 1000),
                                    (assetObj.photo2! != 'null') ? Image.network(assetObj.photo2!, fit: BoxFit.cover, width: 1000) : const SizedBox(),
                                    (assetObj.photo3! != 'null') ? Image.network(assetObj.photo3!, fit: BoxFit.cover, width: 1000) : const SizedBox(),
                                  ],
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    Image.network(assetObj.photo1!, fit: BoxFit.cover, width: 1000),
                    (assetObj.photo2! != 'null') ? Image.network(assetObj.photo2!, fit: BoxFit.cover, width: 1000) : const SizedBox(),
                    (assetObj.photo3! != 'null') ? Image.network(assetObj.photo3!, fit: BoxFit.cover, width: 1000) : const SizedBox(),
                  ],
                ),
              )
          ),
        );
      },
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
                    style: GoogleFonts.quicksand(color: Colors.black54, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                ],
              ),
              const Spacer(),
              Text(value,style: GoogleFonts.quicksand(color: Colors.black))
            ],
          ),
        ),
        const SizedBox(height: 10,),
        // const Divider(height: 0.5, color: Colors.black26,),
        const SizedBox(height: 10,),
      ],
    );
  }

  Future<void> deleteAsset() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/trash/asset');
      var response = await http.post(url, body: {
        'asset_id': assetObj.id,
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
        _setState(() {
          processing = 0;
        });
        return;
      }
      Component().success_toast(message);
      setState(() {
        processing = 0;
      });
      _setState(() {
        processing = 0;
      });
      Navigator.pop(context);
      Navigator.pop(context);

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
    setState(() {
      user_id = user_id;
    });
  }

}