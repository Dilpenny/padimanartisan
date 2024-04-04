//import 'dart:html';

import 'dart:convert';
import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;

class WorkmanApplicationPage extends StatefulWidget {

  @override
  WorkmanApplicationPageWidget createState() => WorkmanApplicationPageWidget();
}


class WorkmanApplicationPageWidget extends State<WorkmanApplicationPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  WorkmanApplicationPageWidget();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  final TextEditingController businessNameController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';
  int view_password = 0;
  bool view_npassword = false;
  bool view_ncpassword = false;
  bool use_bn = false;

  String selected_art_scope = '';

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text("Become a workman", style: GoogleFonts.quicksand(),),
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child:
                Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: Image.asset('graphics/workman.png'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('The information you provide will be scrutinized before approval',
                            style: GoogleFonts.quicksand(),),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Business Name", style: GoogleFonts.quicksand(), textAlign: TextAlign.left,),
                            ],
                          ),
                          CheckboxListTile(
                            title: Text('Use profile name',
                              style: GoogleFonts.quicksand(color: mutedColor, fontSize: 14),),
                            // subtitle: Text('sub demo mode'),
                            value: use_bn,
                            onChanged: (value) {
                              setState(() {
                                use_bn = value!;
                              });
                              if(value!){
                                businessNameController.text = fullname;
                              }else{
                                businessNameController.text = '';
                              }
                            },
                          ),
                          // SizedBox(height: 10,),
                          TextFormField(
                            controller: businessNameController,
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
                          SizedBox(height: 40,),
                          Text('Skillset(S)(Maximum of 3 skills)'),
                          SizedBox(height: 10,),
                          BsSelectBox(
                            alwaysUpdate: false,
                            hintTextLabel: 'Select',
                            controller: _select2,
                            validators: [
                              BsSelectValidators.required
                            ],
                            serverSide: selectApi,
                          ),
                          SizedBox(height: 40,),
                          Text('Duration of practice (min. 2 years)'),
                          SizedBox(height: 10,),
                          BsSelectBox(
                            hintTextLabel: 'Select',
                            controller: _select1,
                          ),
                          SizedBox(height: 40,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: const Color.fromRGBO(7, 84, 40, 1)
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    processing = 1;
                                    password = businessNameController.text;
                                    newPassword = newPasswordController.text;
                                    confirmPassword = confirmPasswordController.text;
                                  });
                                  await become_a_wormkman();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Apply  '.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
          )
      ),
    );
  }

  BsSelectBoxController _select2 = BsSelectBoxController(
      multiple: true,
      options: [
        BsSelectBoxOption(value: 1, text: Text('Plumber')),
        BsSelectBoxOption(value: 2, text: Text('Carpenter')),
        BsSelectBoxOption(value: 3, text: Text('Car Wash')),
        BsSelectBoxOption(value: 4, text: Text('Driver')),
        BsSelectBoxOption(value: 5, text: Text('Mechanic')),
        BsSelectBoxOption(value: 6, text: Text('Smoker')),
      ]
  );

  Future<BsSelectBoxResponse> selectApi(Map<String, String> params) async {

    Uri url = Uri.https('padiman.erate.me', '/public/mobile/fetch/services', params);
    Response response = await http.get(url);
    print('--------------- ================ 12345 ');
    print(response);
    if(response.statusCode == 200) {
      List json = convert.jsonDecode(response.body)['services']['data'];
      print('--------------- ================ ');
      print(response);
      print(json);
      return BsSelectBoxResponse.createFromJson(json);
    }

    return BsSelectBoxResponse(options: []);
  }
  BsSelectBoxController _select1 = BsSelectBoxController(
      options: [
        BsSelectBoxOption(value: '1-5 years', text: Text('1-5 years')),
        BsSelectBoxOption(value: '6-10 years', text: Text('6-10 years')),
        BsSelectBoxOption(value: '10 years and above', text: Text('10 years and above')),
      ]
  );

  Future<void> become_a_wormkman() async {

    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      String use_business_name = '';
      if(use_bn){
        use_business_name = '1';
      }else{
        use_business_name = '0';
      }
      var url = Uri.parse(Component().API+'mobile/apply/artisan');
      var response = await http.post(url, body: {
        'art_scope': _select2.getSelectedAsString(),
        'business_name': businessNameController.text,
        'years_of_experience': _select1.getSelectedAsString(),
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
      setState(() {
        processing = 0;
      });
      Component().success_toast(message);
      // Map user = server_response['user'].toString();

      businessNameController.text = '';
      _select2.clear();
      _select1.clear();

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