//import 'dart:html';

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/asset.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class EditAssetPage extends StatefulWidget {
  final assetObj;

  const EditAssetPage({super.key, required this.assetObj});
  @override
  EditAssetPageWidget createState() => EditAssetPageWidget(assetObj);
}

class EditAssetPageWidget extends State<EditAssetPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  final CustomerAsset assetObj;
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

  EditAssetPageWidget(this.assetObj);

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    modelController.text = assetObj.model!;
    yearController.text = assetObj.year!;
    plateController.text = assetObj.plate_number!;
    chassisController.text = assetObj.chassis_number!;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Text("Editing ${assetObj.model}", style: GoogleFonts.quicksand(),),
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(assetObj.photo1!),
                    radius: 220,
                  ),
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                            const SizedBox(height: 40,),
                            Text('Model:'.toUpperCase(), style: GoogleFonts.quicksand(),),
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
                            const SizedBox(height: 20,),
                            Text('Year:'.toUpperCase(), style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: yearController,
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
                            Text('Chassis number:'.toUpperCase(), style: GoogleFonts.quicksand(),),
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
                            const SizedBox(height: 20,),
                            Text('Plate number:'.toUpperCase(), style: GoogleFonts.quicksand(),),
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
                                      photo1 = assetObj.photo1!;
                                      photo2 = assetObj.photo2!;
                                      processing = 1;
                                    });
                                    await saveAsset(modelController.text,
                                        yearController.text, chassisController.text, plateController.text, '');
                                    Navigator.pop(context);
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Save  '.toUpperCase(), style: GoogleFonts.quicksand(),),
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
  String photo1 = '';
  String photo2 = '';
  String photo3 = '';

  Future<void> saveAsset(String model, String year, String chassis_number, String plate_number, String color) async {

    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/add/asset');
      var response = await http.post(url, body: {
        'plate_number': plate_number,
        'chassis_number': chassis_number,
        'photo1': photo1,
        'photo2': photo2,
        'year': year,
        'asset_id': assetObj.id,
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
      // Navigator.pop(context);
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