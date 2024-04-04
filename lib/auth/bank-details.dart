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

class BankDataPage extends StatefulWidget {

  @override
  BankDataPageWidget createState() => BankDataPageWidget();
}


class BankDataPageWidget extends State<BankDataPage> {
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = new TextEditingController();
  final TextEditingController accountNumberController = new TextEditingController();
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
        title: Text("Bank details", style: GoogleFonts.quicksand(),),
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
                        child: Image.asset('graphics/bank-info.png'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Please confirm the information you provide. We will not be liable for any issues.',
                            style: GoogleFonts.quicksand(),),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Account Name", style: GoogleFonts.quicksand(), textAlign: TextAlign.left,),
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
                          const SizedBox(height: 40,),
                          Text('Select Bank', style: GoogleFonts.quicksand(),),
                          Text('$selected_bank_name (selected)', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),),
                          const SizedBox(height: 10,),
                          BsSelectBox(
                            serverSide: selectApi,
                            hintTextLabel: 'Select',
                            controller: _select1,
                          ),
                          const SizedBox(height: 40,),
                          Text('Account Number', style: GoogleFonts.quicksand(),),
                          const SizedBox(height: 10,),
                          TextFormField(
                            controller: accountNumberController,
                            keyboardType: TextInputType.number,
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
                          const SizedBox(height: 40,),
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
                                    confirmPassword = accountNumberController.text;
                                  });
                                  await save_bank();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Save  '.toUpperCase(), style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold),),
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

    Uri url = Uri.https('padiman.erate.me', '/public/mobile/all/banks', params);
    Response response = await http.get(url);
    print('--------------- ================ 12345 ');
    print(response);
    if(response.statusCode == 200) {
      List json = convert.jsonDecode(response.body)['banks'];
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

  Future<void> save_bank() async {

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
      var url = Uri.parse('${Component().API}mobile/save/bank');
      var response = await http.post(url, body: {
        'bank_name': _select1.getSelectedAsString(),
        'account_name': businessNameController.text,
        'account_number': accountNumberController.text,
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
        selected_bank_name = _select1.getSelectedAsString();
        processing = 0;
      });
      Component().success_toast(message);

      Navigator.pop(context);
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

  String art_scope = '';
  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    imgurl = await session.get('img');
    fullname = await session.get('fullname');
    art_scope = await session.get('art_scope');
    await getBankDetails();
    setState(() {
      fullname = fullname;
      art_scope = art_scope;
      imgurl = imgurl;
      user_id = user_id;
    });
    // List<BsSelectBoxOption> scopel = [
    //   BsSelectBoxOption(value: '1-5 years', text: Text('1-5 years'))
    // ];
    // // art_scope.split(',');
    // _select2.setSelectedAll(scopel);
  }

  String selected_bank_name = '';

  Future getBankDetails() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    var url = Uri.parse('${Component().API}mobile/my/bank?user_id=$user_id');
    var response = await http.post(url, body: {
      'user_id': user_id.toString(),
    });
    var jsonResponses = json.decode(response.body.toString());
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
        // page = 0;
      });
      return;
    }
    if(server_response['bank'] != null){
      businessNameController.text = server_response['bank']['account_name'].toString();
      accountNumberController.text = server_response['bank']['account_number'].toString();
      setState(() {
        selected_bank_name = server_response['bank']['bank_name'].toString();
      });
    }

    return server_response['profile'];

  }

}