import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:padimanartisan/browser.dart';
import 'package:padimanartisan/fragments/wallet_history.dart';
import '../auth/bank-details.dart';
import '../helpers/wallet_history.dart';

import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  late StateSetter _setState;
  static const MINIMUM_FUND_AMOUNT = 5;
  bool canSeeBalance = false;
  OtpFieldController emailOtpController = OtpFieldController();
  bool canWithdraw = false;

  Widget pinWidget(){
    return Center(
      child: OTPTextField(
          controller: emailOtpController,
          length: 5,
          otpFieldStyle: OtpFieldStyle(focusBorderColor: secondaryColor, backgroundColor: whiteColor),
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
              canWithdraw = true;
            });
            print("Completed: " + pin);
          }),
    );
  }

  String emailOTP = '';

  Future<void> send_withdrawal_request() async {

    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/withdraw/fund');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'amount': amountController.text,
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
      amountController.text = '';
      emailOtpController.clear();
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
        'email': email,
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
      // Component().success_toast(message);
      // SEND WITHDRAW
      await send_withdrawal_request();
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
        'email': email,
        'neglect_uniqueness': 'true',
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
          resending_code = false;
        });
        return;
      }
      Component().success_toast(message);
      // Map user = server_response['user'].toString();

      setState(() {
        processing = 0;
        resending_code = false;
      });
      return null;
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Form searchBar(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
        child: TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: searchController,
          onChanged: (String search){
            setState(() {
              searching = search;
            });
            history = _fetchJobs();
          },
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: "Filter history...",
            hintStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.search,color: Colors.white, size: 20,),
            filled: true,
            fillColor: const Color.fromRGBO(47, 111, 75, 1),
            contentPadding: const EdgeInsets.all(8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                    color: Colors.white
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                    color: Colors.white
                )
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          foregroundColor: darkColor,
          title: Text("Withdraw", style: GoogleFonts.quicksand(),),
          actions: [
            // IconButton(
            //     onPressed: (){
            //       showDialog(
            //         context: context,
            //         builder: (BuildContext context) {
            //           return StatefulBuilder(  // You need this, notice the parameters below:
            //               builder: (BuildContext context, StateSetter setState)
            //               {
            //                 _setState = setState;
            //                 return AlertDialog(
            //                   title: Text('Fund wallet'.toUpperCase(), textAlign: TextAlign.center,
            //                       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
            //                       color: secondaryColor)),
            //                   content: SingleChildScrollView(
            //                     child: fundWalletView(context),
            //                   ),
            //                 );
            //               }
            //           );
            //         },
            //       );
            //     },
            //     icon: const Icon(Icons.add)
            // )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            height: screen_height,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("graphics/dashboard.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.only(bottom: 20, top: 20, left: 30, right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Total balance ', style: TextStyle(fontSize: 15, color: whiteColor, //fontWeight: FontWeight.bold
                                ),),
                                IconButton(
                                  onPressed: (){
                                    if(canSeeBalance){
                                      setState(() {
                                        canSeeBalance = false;
                                      });
                                    }else{
                                      setState(() {
                                        canSeeBalance = true;
                                      });
                                    }
                                  },
                                  icon: Icon((canSeeBalance) ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined, color: whiteColor, size: 20,),
                                ),
                                const Spacer(),
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: Icon(Icons.rss_feed, color: whiteColor,),
                                )
                              ],
                            ),
                            const SizedBox(height: 10,),
                            (canSeeBalance) ? Text('₦$walletBalance', style: TextStyle(
                              color: whiteColor, fontSize: 30,
                              //fontWeight: FontWeight.bold
                            ),
                            ) : Row(
                              children: [
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                                Icon(Icons.emergency_rounded, color: whiteColor,),
                              ],
                            ),
                            const SizedBox(height: 40,),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,),

                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Account Name', style: GoogleFonts.quicksand(fontSize: 15), textAlign: TextAlign.start,),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: defaultColor,
                              ),
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Image.asset('graphics/request.png', width: 35,),
                                  const SizedBox(width: 20,),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => BankDataPage(),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                            TextSpan(
                                                text: selected_acc_name,
                                                style: GoogleFonts.quicksand(color: darkColor, fontSize: 16),
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: '',
                                                    style: TextStyle(color: darkColor),
                                                  )
                                                ]
                                            )
                                        ),
                                        Text(selected_acc_number, style: GoogleFonts.quicksand(fontSize: 16, color: mutedColor),)
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 30,
                                    child: Icon(Icons.check_circle, color: secondaryColor, size: 40,),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              children: [
                                Text('Amount', style: GoogleFonts.quicksand(fontSize: 15), textAlign: TextAlign.start,),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            TextFormField(
                              controller: amountController,
                              style: GoogleFonts.quicksand(fontSize: 22),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                prefixText: NAIRA,
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
                                  return 'Please enter an amount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("graphics/input-pin.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    // color: Colors.white,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Input Pin', style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold),),
                      const SizedBox(height: 5,),
                      Wrap(
                        children: [
                          Text('Enter the OTP sent to $email', style: GoogleFonts.quicksand(fontSize: 14,))
                        ],
                      ),
                      const SizedBox(height: 5,),
                      GestureDetector(
                        onTap: () async {
                          if(amountController.text.isEmpty){
                            return Component().error_toast('Enter amount!!');
                          }
                          if(int.parse(amountController.text) < MINIMUM_WITHDRAW_AMOUNT){
                            return Component().error_toast('Minimum amount is $MINIMUM_WITHDRAW_AMOUNT.text');
                          }
                          setState(() {
                            resending_code = true;
                          });
                          await verify_email();
                        },
                        child: Text((resending_code) ? 'Sending code...' : 'Resend code', style: GoogleFonts.quicksand(fontSize: 14, color: secondaryColor)),
                      ),
                      const SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: pinWidget(),
                      ),
                      const SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              backgroundColor: (canWithdraw) ? secondaryColor : disabledColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            onPressed: () async {
                              if(!canWithdraw){
                                return Component().error_toast('Please enter your PIN');
                              }
                              if(processing == 1){
                                return;
                              }
                              setState(() {
                                processing = 1;
                              });
                              await verify_email_otp();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text((processing == 1) ? 'Please wait...' : 'Withdraw ', style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold),),
                                (processing == 1) ? const SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox()
                              ],
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  bool resending_code = false;
  String _Reference = '';
  bool checkedValue = false;
  String email = '';

  Form fundWalletView(BuildContext context){
    return Form(
      key: _formKey2,
      child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        filled: true,
                        prefixText: '₦',
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade100
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid amount';
                        }
                        if (double.parse(value.toString()) < MINIMUM_FUND_AMOUNT) {
                          return 'Amount must be greater than $MINIMUM_FUND_AMOUNT';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
              const SizedBox(height:0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: TextButton(
                    onPressed: () {
                      titleController.text = '';
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
                          padding: const EdgeInsets.only(left: 20,right: 8,top: 10,bottom: 10),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.yellow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text("Fund  ", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                              (processing == 1) ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Color.fromRGBO(47, 111, 75, 1),),) : const Icon(Icons.check_circle,color: Color.fromRGBO(47, 111, 75, 1),size: 20,),
                            ],
                          ),
                        ),
                        onTap: () async {

                        },
                      )
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  Future _getReference(String amount) async {
    String platform;
    var session = FlutterSession();
    email = await session.get('email') ;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    _Reference = 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
    // var client = http.Client();
    // try {
    //   _Reference = '';
    //   var session = FlutterSession();
    //   email = await session.get('email') ;
    //   var url = Uri.parse('${Component().API}get/paystack/reference');
    //   var response = await http.post(url, body: {
    //     'email': email,
    //     'amount': amount,
    //   });
    //   var server_response = jsonDecode(response.body.toString());
    //   print('$server_response ============');
    //   if(server_response['status'] != 'success' || server_response['reference']['status'] == false){
    //     _setState(() {
    //       processing = 0;
    //     });
    //     Component().error_toast('Can not make this transaction at this time:'+server_response['reference']['message']);
    //     return '';
    //   }
    //   String reference = server_response['reference']['data']['reference'];
    //   print('$reference ============');
    //   _Reference = reference;
    //   return '';
    // } finally {
    //   client.close();
    // }
  }

  Future verifyReference(String _amount, String _reference) async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      String uid = await session.get('user_id') ;
      var url = Uri.parse('${Component().API}verify/paystack/reference/and/fund?reference=$_reference&amount=$_amount&user_id=$uid');
      final response = await http.get(url);
      var server_response = jsonDecode(response.body.toString());
      _setState(() {
        processing = 0;
      });
      if(server_response['status'] != 'success'){
        Component().error_toast(server_response['message']);
        return '';
      }
      Component().success_toast(server_response['message']);
      history = _fetchJobs();
      titleController.text = '';
      Navigator.pop(context);
    } finally {
      client.close();
    }
  }

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
      setState(() {
        selected_acc_name = server_response['bank']['account_name'].toString();
        selected_acc_number = server_response['bank']['account_number'].toString();
        selected_bank_name = server_response['bank']['bank_name'].toString();
      });
    }

    return server_response['profile'];

  }

  String selected_acc_number = '';
  String selected_bank_name = '';
  String selected_acc_name = '';

  int current_total = 20;
  int page = 1;

  Widget projectWidget() {
    return FutureBuilder<List<WalletHistory>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null || total == 0) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Center(
            child: Column(
              children: [
                SizedBox(height: 20,),
                Text('No transactions made yet...',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.black54),)
              ],
            ),
          );
        }else if(snapshot.hasData){
          List<WalletHistory>? data = snapshot.data;
          return Column(
            children: [
              ListView.builder(
                itemCount: data!.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return list(data[index]);
                },
              ),
              (current_total < total) ? TextButton(
                onPressed: () async {
                  Component().default_toast("Please wait...");
                  setState(() {
                    page = page + 1;
                  });

                  String basicUrl = '${Component().API}mobile_wallet_history?user_id=$user_id&page=$page';
                  if(searching.isNotEmpty){
                    basicUrl = '$basicUrl&search=$searching';
                  }
                  var url = Uri.parse(basicUrl);
                  final response = await http.get(url);

                  if (response.statusCode == 200) {
                    var jsonResponses = json.decode(response.body);
                    if(jsonResponses == null){
                      // return [];
                      // return Center(child: Chip(label: Text('No data found',)));
                    }
                    List jsonResponse = jsonResponses['wallet']['data'];

                    List<WalletHistory> lists = jsonResponse.map((job) => WalletHistory.fromJson(job)).toList();
                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                    // Activities value = new Activities.fromJson(values);
                    for(int i = 0; i < lists.length; i++){
                      // data.add(lists);
                      WalletHistory activity = WalletHistory(
                          amount:lists[i].amount, name: lists[i].name,
                          time_ago:lists[i].time_ago,
                          user_id:lists[i].user_id,
                          topic:lists[i].topic,
                          money:lists[i].money,
                          statusx_color:lists[i].statusx_color,
                          statusx_status:lists[i].statusx_status,
                          status:lists[i].status,
                          receiver: lists[i].receiver, id: lists[i].id
                      );
                      data.add(activity);
                    }

                    setState(() {
                      current_total = data.length;
                    });
                  };
                },
                child: const Text('Load more'),
              ) : const SizedBox(),
            ],
          );
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Center(child: Chip(label: Text('No or Bad internet connection',)));
        }
        return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Component().line_loading(),
            )
        );
      },
      future: (page == 1) ? history : null,
    );
  }

  Widget list(obj){
    Color statusColor = Colors.purpleAccent;
    if(obj.statusx_color == 'red'){
      statusColor = Colors.red;
    }else if(obj.statusx_color == 'orange'){
      statusColor = Colors.orange;
    }else if(obj.statusx_color == 'green'){
      statusColor = Colors.blueGrey;
    }
    return GestureDetector(
      onTap: (){
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         RoomInfoPage(room_obj: obj),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide( //                   <--- left side
                color: Colors.grey.shade100,
                width: 4.0,
              ),
            )
        ),
        padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('₦'+obj.money, style: const TextStyle(fontSize: 19),),
                          const SizedBox(height: 6,),
                          Text(obj.description,style: TextStyle(fontSize: 11,color: Colors.grey.shade600, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(obj.statusx_status, style: TextStyle(color: statusColor, fontSize: 12),),
                Text(obj.time_ago, style: const TextStyle(fontSize: 10, color: Colors.black38),),
              ],
            )
            // IconButton(
            //     onPressed: (){},
            //     icon: Icon(Icons.message, color: Color.fromRGBO(227, 36, 43, 1),)
            // )
          ],
        ),
      ),
    );
  }

  late Future<List<WalletHistory>> history;
  int user_id = 0;
  String searching = '';
  String walletBalance = '';
  int total = 20;

  var publicKey = 'pk_live_61b86e6cf64dc77d47d86fdcabc709f6ff3ae6ad';

  @override
  void initState() {
    // plugin.initialize(publicKey: publicKey);
    firstThings();
    // TODO: implement initState
    super.initState();
  }

  void firstThings() async {
    history = _fetchJobs();
    await getBankDetails();
    var session = FlutterSession();
    user_id = await session.getInt('id');
    email = await session.get('email');
    print('...........................--------');
    print(email);
    setState(() {
      user_id = user_id;
      email = email;
    });

  }

  Future<List<WalletHistory>> _fetchJobs() async {
    try{
      print('===============================1');
      var session = FlutterSession();
      user_id = await session.getInt('id');
      setState(() {
        user_id = user_id;
      });
      print('===============================2');
      String basicUrl = '${Component().API}mobile_wallet_history?user_id=${user_id.toString()}';
      if(searching.isNotEmpty){
        basicUrl = '$basicUrl&search=$searching';
      }
      var url = Uri.parse(basicUrl);
      print('===============================3');
      final response = await http.get(url);
      print('===============================4'+response.statusCode.toString());
      if (response.statusCode == 200) {
        var jsonResponses = json.decode(response.body);
        print('===============================');
        print(jsonResponses);
        print('===============================');
        if(jsonResponses == null){
          // return [];
          // return Center(child: Chip(label: Text('No data found',)));
        }
        List jsonResponse = jsonResponses['wallet']['data'];
        setState(() {
          total = int.parse(jsonResponses['wallet']['total'].toString());
          walletBalance = jsonResponses['user']['money'].toString();
        });

        print('===============$jsonResponse');
        return jsonResponse.map((job) => WalletHistory.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load rooms from API');
      }
    }on Exception{
      return [];
    }
  }
  int processing = 0;
}