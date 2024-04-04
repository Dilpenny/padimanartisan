
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:padimanartisan/map/.env.dart';
import '../auth/forgot.dart';
import '../auth/login.dart';
import '../browser.dart';
import '../helpers/components.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;

import '../helpers/session.dart';

class RegisterPage extends StatefulWidget {
  final type;
  const RegisterPage({Key? key, this.type}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterState(type);
}

class _RegisterState extends State<RegisterPage> {
  final type;
  final _formKey = GlobalKey<FormState>();
  final _formKeyArtisanCompleteProfile = GlobalKey<FormState>();
  final _formKeyPhone = GlobalKey<FormState>();
  final _formEntryKeyPhone = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyEntryEmail = GlobalKey<FormState>();

  int processing = 0;
  String email = '';
  String password = '';
  int view_password = 0;
  int c_view_password = 0;
  // FirebaseAuth auth = FirebaseAuth.instance; // FIREBASE AUTH
  bool canProceed = false;
  bool canVerify = false;
  bool hasVerified = false;

  Text artisanWelcomeMessage = Text.rich(
      TextSpan(
          text: 'Register your account as an',
          children: <InlineSpan>[
            TextSpan(
              text: ' Artisan ',
              style: TextStyle(color: secondaryColor),
            ),
            TextSpan(
              text: ' with us',
              style: TextStyle(),
            )
          ]
      )
  );
  Text userWelcomeMessage = Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: 'Open an account with us with just a few steps',
            style: TextStyle(),
          )
        ]
    )
  );

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController stateController = new TextEditingController();
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController refererController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  String smsCode = '';
  final TextEditingController codeController = TextEditingController();
  late StateSetter _setState;

  _RegisterState(this.type);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Max Size
          Container(
            alignment: Alignment.bottomRight,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      height: 90,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50,),
                          // Image.asset('graphics/logo.jpeg', width: 300,),
                          SizedBox(height: 20,),
                        ],
                      ),
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     image: AssetImage("graphics/head2.png"),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),
                    // SizedBox(height: 300,),
                    phone_entry(),
                    phone_otp_entry(),
                    email_entry(),
                    email_otp_entry(),
                    complete_profile_setup(),
                    my_form(),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   color: Colors.yellow,
          // )
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bool shouldEnterPhone = false;
  bool shouldEnterEmail = false;
  bool canGetOTP = false;
  bool shouldEnterPhoneOTP = false;
  bool shouldEnterEmailOTP = false;
  bool canVerifyPhoneOTP = false;
  OtpFieldController phoneOtpController = OtpFieldController();
  OtpFieldController emailOtpController = OtpFieldController();

  String selectedCountryCode = '+234';
  String selectedPhoneNumber = '';
  Widget phone_entry(){
    if(!shouldEnterPhone){
      return SizedBox();
    }
    return Form(
      key: _formEntryKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/otp.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'OTP Verification',
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('We will send a One Time Passcode to this mobile number',
                textAlign: TextAlign.center,)
            ],
          ),
          SizedBox(height: 40,),
          Text('Enter Mobile Number'),
          SizedBox(height: 10,),
          Container(
            color: mutedColorx,
            child: Row(
              children: [
                CountryCodePicker(
                  onChanged: (newCountryCode){
                    Component().success_toast(newCountryCode.dialCode!);
                    setState(() {
                      selectedCountryCode = newCountryCode.dialCode!;
                    });
                  },
                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                  initialSelection: 'Ng',
                  favorite: ['+233','Ng'],
                  // optional. Shows only country name and flag
                  showCountryOnly: true,
                  // optional. Shows only country name and flag when popup is closed.
                  showOnlyCountryWhenClosed: false,
                  // optional. aligns the flag and the Text left
                  alignLeft: false,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 150,
                  height: 50,
                  child: TextFormField(
                    readOnly: (hasVerified) ? true : false,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    onChanged: (typedPhone){
                      if(typedPhone.length > 9){
                        setState(() {
                          canGetOTP = true;
                          phone = typedPhone;
                        });
                      }else{
                        setState(() {
                          canGetOTP = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: mutedColorx,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mutedColorx, width: 2),
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
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (canGetOTP) ? const Color.fromRGBO(7, 84, 40, 1) : disabledColor,
                      shape: const StadiumBorder(),

                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formEntryKeyPhone.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      setState(() {
                        processing = 1;
                        selectedPhoneNumber = selectedCountryCode + phoneController.text;
                      });
                      await verify_phone();
                      setState(() {
                        shouldEnterPhone = false;
                        shouldEnterPhoneOTP = true;
                      });
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get OTP  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String emailOTP = '';
  String phoneOTP = '';

  Widget phone_otp_entry(){
    if(!shouldEnterPhoneOTP){
      return SizedBox();
    }
    return Form(
      key: _formKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/otp.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'OTP Verification (Mobile)',
              style: TextStyle(fontSize: 25),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Center(
                child: Text('Enter the OTP sent to ${selectedPhoneNumber}',
                  textAlign: TextAlign.center,),
              )
            ],
          ),
          SizedBox(height: 40,),
          Center(
            child: OTPTextField(
                controller: phoneOtpController,
                length: 5,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 45,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                style: TextStyle(fontSize: 17),
                onChanged: (pin) {
                  print("Changed: " + pin);
                  setState(() {
                    phoneOTP = pin;
                  });
                },
                onCompleted: (pin) {
                  setState(() {
                    canVerifyPhoneOTP = true;
                  });
                  print("Completed: " + pin);
                }),
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: () async {
              setState(() {
                canVerifyPhoneOTP = false;

              });
              phoneOtpController.clear();
              await verify_phone();
            },
            child: Center(
              child: Text.rich(
                  TextSpan(
                      text: 'Didn’t receive the OTP?  ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Resend code',
                          style: TextStyle(color: errorColor),
                        )
                      ]
                  )
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (canVerifyPhoneOTP) ? const Color.fromRGBO(7, 84, 40, 1) : disabledColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyPhone.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      setState(() {
                        processing = 1;
                      });
                      await verify_phone_otp();
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify & Proceed  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget complete_profile_setup(){
    if(!artisanCanSubmitSignup){
      return SizedBox();
    }
    return Form(
      key: _formKeyArtisanCompleteProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 200,
              child: Image.asset('graphics/workman.png'),
            ),
          ),
          SizedBox(height: 20,),
          Text('Complete profile set up', style: TextStyle(fontSize: 30),),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Fill in the final pieces of information',
                textAlign: TextAlign.center,)
            ],
          ),
          SizedBox(height: 40,),
          Text('Skillset (S)(Maximum of 3 skills)'),
          SizedBox(height: 10,),
          BsSelectBox(
            hintTextLabel: 'Select',
            controller: _select2,
            serverSide: selectApi,
          ),
          SizedBox(height: 40,),
          Text('Duration of practice (min. 2 years)'),
          SizedBox(height: 10,),
          BsSelectBox(
            hintTextLabel: 'Select',
            controller: _select1,
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
                      shape: const StadiumBorder(),

                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyArtisanCompleteProfile.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      //await register();
                      if(_select2.getSelectedAsString().length < 5){
                        return Component().error_toast('Please select your skillset');
                      }
                      setState(() {
                        artisanCanSubmitSignup = false;
                        shouldEnterPhone = true;
                      });
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Proceed to OTP verification  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget email_entry(){
    if(!shouldEnterEmail){
      return SizedBox();
    }
    return Form(
      key: _formKeyEntryEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/otp.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'Email Verification',
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('We will send a One Time Passcode to this email address',
                textAlign: TextAlign.center,)
            ],
          ),
          SizedBox(height: 40,),
          Text('Enter Email Address'),
          SizedBox(height: 10,),
          TextFormField(
            controller: emailController,
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
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter email';
              }
              return null;
            },
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (canGetOTP) ? const Color.fromRGBO(7, 84, 40, 1) : disabledColor,
                      shape: const StadiumBorder(),

                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyEntryEmail.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      setState(() {
                        processing = 1;
                      });
                      await verify_email();
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get OTP  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool canVerifyEmailOTP = false;
  Widget email_otp_entry(){
    if(!shouldEnterEmailOTP){
      return SizedBox();
    }
    return Form(
      key: _formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              child: Image.asset('graphics/otp.png'),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: Text(
              'OTP Verification (Email)',
              style: TextStyle(fontSize: 25),
            ),
          ),
          SizedBox(height: 10,),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Center(
                child: Text('Enter the OTP sent to ${emailController.text}',
                  textAlign: TextAlign.center,),
              )
            ],
          ),
          SizedBox(height: 40,),
          Center(
            child: OTPTextField(
                controller: emailOtpController,
                length: 5,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 45,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                style: TextStyle(fontSize: 17),
                onChanged: (pin) {
                  print("Changed: " + pin);
                  setState(() {
                    emailOTP = pin;
                  });
                },
                onCompleted: (pin) {
                  setState(() {
                    canVerifyEmailOTP = true;
                  });
                  print("Completed: " + pin);
                }),
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: () async {
              setState(() {
                canVerifyEmailOTP = false;

              });
              emailOtpController.clear();
              await verify_email();
            },
            child: Center(
              child: Text.rich(
                  TextSpan(
                      text: 'Didn’t receive the OTP?  ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Resend code',
                          style: TextStyle(color: errorColor),
                        )
                      ]
                  )
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (canVerifyEmailOTP) ? const Color.fromRGBO(7, 84, 40, 1) : disabledColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    if (_formKeyEmail.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      // setState(() {
                      //   firstname = nameController.text;
                      //   phone = phoneController.text;
                      //   email = emailController.text;
                      //   confirm_password = confirmPasswordController.text;
                      //   processing = 1;
                      //   password = passwordController.text;
                      // });
                      //await register();
                      if(!canVerifyEmailOTP){
                        return Component().error_toast('Please enter the OTP sent ');
                      }
                      setState(() {
                        processing = 1;
                      });
                      await verify_email_otp();
                    }
                  },
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify & Proceed  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    items.addAll(ARTISAN_CATEGORIES);
    super.initState();
  }

  static List<Shadow> outlinedText({double strokeWidth = 2, Color strokeColor = Colors.black, int precision = 5}) {
    Set<Shadow> result = HashSet();
    for (int x = 1; x < strokeWidth + precision; x++) {
      for(int y = 1; y < strokeWidth + precision; y++) {
        double offsetX = x.toDouble();
        double offsetY = y.toDouble();
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      }
    }
    return result.toList();
  }

  // List of items in our dropdown menu
  var items = [
    'Who are you?',
  ];

  Widget my_form(){
    if(shouldEnterPhone || shouldEnterPhoneOTP || shouldEnterEmail || shouldEnterEmailOTP || artisanCanSubmitSignup){
      return SizedBox();
    }
    return Form(
      key: _formKey,
      child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  // image: const DecorationImage(
                  //   image: AssetImage("graphics/dashboard-bg.png"),
                  //   fit: BoxFit.cover,
                  // ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                // padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(fontSize: 30),
                        ),
                        SizedBox(height: 10,),
                        Wrap(
                          children: [
                                (type == 'user')
                                    ?
                                userWelcomeMessage
                                    :
                                artisanWelcomeMessage
                          ],
                        ),
                        SizedBox(height: 10,),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    SizedBox(height: 30,),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: DropdownButton(
                    //     value: artisan_scope,// Down Arrow Icon
                    //     icon: const Icon(Icons.keyboard_arrow_down),
                    //     items: items.map((String items) {
                    //       return DropdownMenuItem(
                    //         value: items,
                    //         child: Text(items,
                    //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String? newValue) {
                    //       setState(() {
                    //         artisan_scope = newValue!;
                    //         artisan_scope = artisan_scope.replaceAll(' ', '-');
                    //       });
                    //     },
                    //   ),
                    // ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Full Name'),
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: nameController,
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
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0,),
                          const Text('Username'),
                          const SizedBox(height: 2,),
                          TextFormField(
                            controller: usernameController,
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
                              prefixIcon: Icon(Icons.switch_account),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0,),
                          const Text('Referral Code(optional)'),
                          const SizedBox(height: 2,),
                          TextFormField(
                            controller: refererController,
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
                              prefixIcon: const Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 20.0,),
                          Text('Password'),
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: passwordController,
                            obscureText: (view_password == 0) ? true : false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
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
                              suffixIcon: IconButton(icon: (view_password == 0) ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                onPressed: () {
                                  if(view_password == 1){
                                    setState(() {
                                      view_password = 0;
                                    });
                                  }else{
                                    setState(() {
                                      view_password = 1;
                                    });
                                  }
                                },),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                            },
                          ),
                          const SizedBox(height: 20.0,),
                          Text('Confirm Password'),
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: (c_view_password == 0) ? true : false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
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
                              suffixIcon: IconButton(icon: (c_view_password == 0) ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                                onPressed: () {
                                  if(c_view_password == 1){
                                    setState(() {
                                      c_view_password = 0;
                                    });
                                  }else{
                                    setState(() {
                                      c_view_password = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Text.rich(
                          TextSpan(
                              text: 'By signing up you’re agreeing to our ',
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(color: basicColor, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyle(color: mutedColor, fontWeight: FontWeight.bold),
                                ),

                                TextSpan(
                                  text: ' Privacy Policy ',
                                  style: TextStyle(color: basicColor, fontWeight: FontWeight.bold),
                                ),
                              ]
                          )
                      ),
                      onTap: (){
                        String url = 'https://raedaexpress.com/blog/category/Terms%20and%20Condition';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyBrowser(title: 'Term and Conditions', link: url,),
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                // primary: (canProceed) ? const Color.fromRGBO(7, 84, 40, 1) : const Color.fromRGBO(7, 84, 40, 0.3),
                                primary: const Color.fromRGBO(7, 84, 40, 1),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.all(15)
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a Snackbar.
                                // if(artisan_scope.toLowerCase() == 'who are you?' || artisan_scope.length < 1){
                                //   Component().error_toast('Please select who you are');
                                //   return;
                                // }
                                // if(!canProceed){
                                //   Component().error_toast('Please make sure you have verified your PHONE NUMBER');
                                //   return;
                                // }
                                // setState(() {
                                //   firstname = nameController.text;
                                //   phone = phoneController.text;
                                //   email = emailController.text;
                                //   confirm_password = confirmPasswordController.text;
                                //   processing = 1;
                                //   password = passwordController.text;
                                // });
                                setState(() {
                                  processing = 1;
                                });
                                await check_register_possibility();
                              }
                            },
                            child:
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                (processing == 1) ? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text.rich(
                            TextSpan(
                                text: 'Already have an account? ',
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(color: Color.fromRGBO(71, 196, 78, 1),fontWeight: FontWeight.bold),
                                  )
                                ]
                            )
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(

                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  bool artisanCanSubmitSignup = false;

  String firstname = '';
  String phone = '';
  String confirm_password = '';
  String artisan_scope = 'Who are you?';

  Future<void> register() async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/signup?type=artisan');
      var response = await http.post(url, body: {
        'name': nameController.text,
        'phone': selectedPhoneNumber,
        'referer': refererController.text,
        'email': emailController.text,
        'username': usernameController.text,
        'confirm_password': confirmPasswordController.text,
        'password': passwordController.text,
        'art_scope': _select2.getSelectedAsString(),
        'type': type,
        // 'business_name': businessNameController.text,
        'years_of_experience': _select1.getSelectedAsString(),
      });
      var server_response = jsonDecode(response.body.toString());
      print('==============='+server_response['status']);
      String status = server_response['status'].toString();
      status = status.replaceAll('[', '');
      status = status.replaceAll(']', '');
      String message = server_response['message'].toString();
      message = message.replaceAll('[', '');
      message = message.replaceAll(']', '');
      if (status == 'error') {
        Component().error_toast(message);
        setState(() {
          processing = 0;
        });
        return;
      }
      Component().success_toast(message);
      // Map user = server_response['user'].toString();

      emailController.text = '';
      passwordController.text = '';
      nameController.text = '';
      phoneController.text = '';
      confirmPasswordController.text = '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );

      setState(() {
        processing = 0;
        // account_message = message;
      });

      Component().success_toast(message);

      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }


  Future<void> check_register_possibility() async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/check/signup');
      var response = await http.post(url, body: {
        'name': nameController.text,
        'username': usernameController.text,
        'confirm_password': confirmPasswordController.text,
        'password': passwordController.text,
      });
      var server_response = jsonDecode(response.body.toString());
      print('==============='+server_response['status']);
      String status = server_response['status'].toString();
      status = status.replaceAll('[', '');
      status = status.replaceAll(']', '');
      String message = server_response['message'].toString();
      message = message.replaceAll('[', '');
      message = message.replaceAll(']', '');
      if (status == 'error') {
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
        // account_message = message;
      });

      Component().success_toast(message);
      if(type == 'artisan'){
        setState(() {
          artisanCanSubmitSignup = true;
        });
        return;
      }
      setState(() {
        shouldEnterPhone = true;
      });

      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> verify_email_otp() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/otp/email');
      var response = await http.post(url, body: {
        'email': emailController.text,
        'token': emailOTP,
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
      // START REGISTRATION
      await register();
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> verify_phone_otp() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/otp/phone');
      var response = await http.post(url, body: {
        'phone': selectedPhoneNumber,
        'token': phoneOTP,
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
      // START REGISTRATION
      setState(() {
        processing = 0;
        shouldEnterPhone = false;
        shouldEnterPhoneOTP = false;
        shouldEnterEmail = true;
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> verify_email() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/email');
      var response = await http.post(url, body: {
        'email': emailController.text,
      });
      print(response.body.toString());
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
        // account_message = message;
        // spage = 0;
        // emailOtpEnabled = true;
        shouldEnterEmail = false;
        shouldEnterEmailOTP = true;
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future<void> verify_phone() async {
    Component().success_toast('Sending .... ');
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/verify/phone');
      var response = await http.post(url, body: {
        'phone': selectedPhoneNumber,
      });
      print(response.body.toString());
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
        // account_message = message;
        // spage = 0;
        // emailOtpEnabled = true;
        shouldEnterEmail = false;
        shouldEnterEmailOTP = true;
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }
}
