//import 'dart:html';

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import 'assets.dart';

class AddAssetPage extends StatefulWidget {

  const AddAssetPage({Key? key}) : super(key: key);
  @override
  AddAssetPageWidget createState() => AddAssetPageWidget();
}

class AddAssetPageWidget extends State<AddAssetPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = new TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text("Add new asset", style: GoogleFonts.quicksand()),
          // actions: [
          //   Padding(
          //       padding: const EdgeInsets.only(right: 20.0),
          //       child: GestureDetector(
          //         onTap: () async {
          //           int userId = 0;
          //           // var session = FlutterSession();
          //           // userId = await session.getInt('id');
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (BuildContext context) => const AssetsPage(),
          //             ),
          //           );
          //         },
          //         child: const Icon(
          //           Icons.car_rental, color: Colors.yellow,
          //         ),
          //       )
          //   ),
          // ]
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: SizedBox(
                                width: 100,
                                child: Image.asset('graphics/no-photo-camera.png'),
                              ),
                            ),
                            const SizedBox(height: 40,),
                            const Text('Provide asset information correctly'),
                            const SizedBox(height: 10,),
                            Text('Brand name', style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: modelController,
                              obscureText: false,
                              maxLines: null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: mutedColorx,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(color: mutedColorx, width: 0.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: mutedColorx, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10,),
                            Text('Year', style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: yearController,
                              obscureText: false,
                              maxLines: null,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: mutedColorx,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(color: mutedColorx, width: 0.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: mutedColorx, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10,),
                            Text('Chassis number', style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: chassisController,
                              obscureText: false,
                              maxLines: null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: mutedColorx,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(color: mutedColorx, width: 0.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: mutedColorx, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10,),
                            Text('Plate number', style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: plateController,
                              obscureText: false,
                              maxLines: null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: mutedColorx,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(color: mutedColorx, width: 0.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: mutedColorx, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    primary: const Color.fromRGBO(7, 84, 40, 1),
                                    padding: const EdgeInsets.all(15)
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      processing = 1;
                                    });
                                    await saveAsset(modelController.text,
                                        yearController.text, chassisController.text, plateController.text, '');
                                    Navigator.pop(context);
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (BuildContext context) => AssetsPage(),
                                    //   ),
                                    // );
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Save  '.toUpperCase(), style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold),),
                                    (processing == 1) ? const SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              )
            ],
          )
      ),
    );
  }

  Future<void> saveAsset(String model, String year, String chassis_number, String plate_number, String color) async {
    String photo1 = 'https://media.ed.edmunds-media.com/toyota/venza/2021/oem/2021_toyota_venza_4dr-suv_xle_fq_oem_2_1600.jpg';
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/add/asset');
      var response = await http.post(url, body: {
        'plate_number': plate_number,
        'chassis_number': chassis_number,
        'photo1': photo1,
        'year': year,
        'model': model,
        'user_id': user_id.toString(),
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
      Component().success_toast(message);
      // Map user = server_response['user'].toString();
      setState(() {
        processing = 0;
      });
      modelController.text = '';
      yearController.text = '';
      plateController.text = '';
      chassisController.text = '';

      Component().success_toast(message);

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
    fullname = await session.get('fullname');
    setState(() {
      fullname = fullname;
      imgurl = imgurl;
      user_id = user_id;
    });
  }

}