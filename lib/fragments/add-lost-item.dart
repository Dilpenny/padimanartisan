//import 'dart:html';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../map/.env.dart';
import 'assets.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class AddLostItemPage extends StatefulWidget {

  const AddLostItemPage({Key? key}) : super(key: key);
  @override
  AddLostItemPageWidget createState() => AddLostItemPageWidget();
}

class AddLostItemPageWidget extends State<AddLostItemPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';

  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController identityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';

  // Initial Selected Value
  String typeInitialValue = 'Type';

  // List of items in our dropdown menu
  var items = [
    'Type',
    'Human',
    'Automobile',
    'Phone',
  ];

  late Uri avatar;
  bool avatar_uploading = false;

  Future<void> select_file_avatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'gif', 'png'],);

    if (result != null) {
      File file = File(result.files.single.path!);
      avatar = file.uri;
      setState(() {
        avatar = avatar;
        avatar_uploading = true;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: const Text("Add lost item"),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    int userId = 0;
                    // var session = FlutterSession();
                    // userId = await session.getInt('id');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const AssetsPage(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.car_rental, color: darkColor,
                  ),
                )
            ),
          ]
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
                            const SizedBox(height: 40,),
                            Text('Type of item', style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: mutedColorx,

                              ),
                              padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20, left: 20),
                              width: double.infinity,
                              child: DropdownButton(
                                // Initial Value
                                isExpanded: true,
                                value: typeInitialValue,
                                // Down Arrow Icon
                                underline: Container(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                // Array list of items
                                items: items.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    typeInitialValue = newValue!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Text(
                              (typeInitialValue.toLowerCase() == 'human') ? humanIdentity : (typeInitialValue.toLowerCase() == 'phone') ? phoneIdentity : autoIdentity
                              , style: GoogleFonts.quicksand(),),
                            TextFormField(
                              controller: identityController,
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
                            Text(
                              (typeInitialValue.toLowerCase() == 'human') ? humanDescription : (typeInitialValue.toLowerCase() == 'phone') ? phoneDescription : autoDescription
                              , style: GoogleFonts.quicksand(),),
                            const SizedBox(height: 5,),
                            TextFormField(
                              controller: descriptionController,
                              obscureText: false,
                              maxLength: 500,
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
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                const Spacer(),
                                SizedBox(
                                  width: 140,
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: defaultColor,
                                        side: BorderSide(color: disabledColor, width: 1),
                                      ),
                                      onPressed: () async {
                                        await select_file_avatar();
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.linked_camera_outlined, color: darkColor, size: 15,),
                                          Text(' Add photo', style:
                                          TextStyle(color: darkColor, fontSize: 12),)
                                        ],
                                      )
                                  ),
                                ),
                              ],
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
                                    if(typeInitialValue == 'Type'){
                                      Component().error_toast('Please select type lost');
                                      return;
                                    }
                                    if(avatar.path.isEmpty){
                                      Component().error_toast('Please select a photo');
                                      return;
                                    }
                                    setState(() {
                                      processing = 1;
                                    });
                                    await saveItem();
                                    // Navigator.pop(context);
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
                                    Text('Post  '.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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

  String photo = '';
  String selectedType = '';

  Future<void> saveItem() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/add/lost/items');

      var request = http.MultipartRequest("POST", url);
      request.fields['user_id'] = user_id.toString();
      request.fields['type'] = typeInitialValue;
      request.fields['description'] = descriptionController.text;
      request.fields['identity'] = identityController.text;
      request.files.add(await http.MultipartFile.fromPath('photo', File.fromUri(avatar).path));
      request.send().then((response) async {
        print('=============');
        print(response.statusCode);
        if (response.statusCode == 200) {
          // Map user = server_response['user'].toString();
          setState(() {
            processing = 0;
          });
          descriptionController.text = '';
          identityController.text = '';

          Component().success_toast('Saved successfully');
          Navigator.pop(context);

        } else {
          Component().error_toast('Select a file');
          setState(() {
            avatar_uploading = false;
          });
          throw Exception('Failed to load activities from API');
        }
      });
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