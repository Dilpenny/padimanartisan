import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:padimanartisan/browser.dart';
import 'package:padimanartisan/fragments/withdraw.dart';
import '../auth/bank-details.dart';
import '../helpers/wallet_history.dart';

import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

class WalletHistoryPage extends StatefulWidget {
  @override
  _WalletHistoryPageState createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late StateSetter _setState;
  static const MINIMUM_FUND_AMOUNT = 5;
  bool canSeeBalance = false;

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
    double screen_height = MediaQuery.of(context).size.height - 250;
    return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              elevation: 0,
              foregroundColor: darkColor,
              title: Text("My Wallet", style: GoogleFonts.quicksand(),),
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 0, right: 20, left: 20),
                      child: Row(
                        children: [
                          Text('Your Balance', style: GoogleFonts.quicksand(),),
                          Spacer(),
                          TextButton(
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => BankDataPage(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text('Add Bank ', style: GoogleFonts.quicksand(color: darkColor)),
                                  Icon(Icons.add_circle_outlined, color: disabledColor,)
                                ],
                              )
                          )
                        ],
                      ),
                    ),
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
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Wrap(
                                children: [
                                  Text(fullname, style:
                                  GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),)
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(  // You need this, notice the parameters below:
                                      builder: (BuildContext context, StateSetter setState)
                                      {
                                        _setState = setState;
                                        return AlertDialog(
                                          title: Text('Fund wallet'.toUpperCase(), textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                                  color: secondaryColor)),
                                          content: SingleChildScrollView(
                                            child: fundWalletView(context),
                                          ),
                                        );
                                      }
                                  );
                                },
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: mutedColorx,
                                  radius: 20,
                                  child: Icon(Icons.account_balance_wallet, size: 20, color: mutedColor,),
                                ),
                                const SizedBox(height: 6,),
                                Text('Add funds ', style: GoogleFonts.quicksand(color: darkColor)),
                              ],
                            )
                        ),
                        const SizedBox(width: 20,),
                        TextButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => WithdrawPage(),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: mutedColorx,
                                  radius: 20,
                                  child: Icon(Icons.print_rounded, size: 20, color: mutedColor,),
                                ),
                                SizedBox(height: 6,),
                                Text('Withdraw ', style: GoogleFonts.quicksand(color: darkColor)),
                              ],
                            )
                        )
                      ],
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Text('Transaction History', style: GoogleFonts.quicksand(fontSize: 20), textAlign: TextAlign.start,),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: const DecorationImage(
                          image: AssetImage("graphics/dashboard-bg.png"),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white,
                      ),
                      height: screen_height,
                      child: RefreshIndicator(
                        displacement: 50,
                        backgroundColor: secondaryColor,
                        color: whiteColor,
                        strokeWidth: 3,
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        onRefresh: () async {
                          history = _fetchJobs();
                        },
                        child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // searchBar(),
                            projectWidget(),
                          ],
                        ),
                      ),
                      )
                    )
                  ],
                ),
              ),
            )
        );
  }

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
                    SizedBox(
                      child: Image.asset('graphics/fund-wallet.png'),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: titleController,
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
                        prefixText: '₦',
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
                          String amount = titleController.text;
                          if(amount.isEmpty){
                            return Component().error_toast('Please enter an amount');
                          }
                          // if(int.parse(amount) < 500){
                          //   return Component().error_toast('Amount should be greater then 500');
                          // }
                          _setState(() {
                            processing = 1;
                          });
                          var session = FlutterSession();
                          user_id = await session.getInt('id');
                          String new_userid = user_id.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyBrowser(
                                title: 'Fund Wallet',
                                link: '${Component().API}pay/paystack/$amount/$new_userid',
                              ),
                            ),
                          );
                          _setState(() {
                            processing = 0;
                          });
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
                          type:lists[i].type,
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
    Icon flow = Icon(Icons.arrow_upward_outlined, color: secondaryColor, size: 15,);
    Color statusColor = Colors.purpleAccent;
    if(obj.type.toString().contains('out')){
      statusColor = Colors.red;
    }else if(obj.type.toString().contains('ithdraw')){
      statusColor = Colors.orange;
    }else if(obj.type.toString().contains('in')){
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
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: defaultColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
          child: ListTile(
              dense:true,
              contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              leading: SizedBox(
                width: 25,
                child: (obj.type.toString().contains('ithdraw'))
                    ?
                Image.asset('graphics/withdraw.png')
                    :
                Image.asset('graphics/salary.png'),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      Text(obj.description, style: GoogleFonts.quicksand(fontSize: 15,color: darkColor),),
                    ],
                  ),
                  const SizedBox(height: 6,),
                  Text(obj.time_ago!, style: GoogleFonts.quicksand(fontSize: 10, color: Colors.black38),),
                ],
              ),
              trailing: Container(
                // color: statusBgColor, statusx_status
                padding: const EdgeInsets.all(5),
                child: Text('₦'+obj.money, style: GoogleFonts.quicksand(color: statusColor, fontSize: 16, fontStyle: FontStyle.italic),),
              )
          )

      )
    );
  }

  late Future<List<WalletHistory>> history;
  int user_id = 0;
  String searching = '';
  String walletBalance = '';
  int total = 20;

  var publicKey = 'pk_live_61b86e6cf64dc77d47d86fdcabc709f6ff3ae6ad';

  String fullname = '';
  @override
  void initState() {
    // plugin.initialize(publicKey: publicKey);
    firstThings();
    // TODO: implement initState
    super.initState();
  }

  void firstThings() async {
    history = _fetchJobs();
    var session = FlutterSession();
    user_id = await session.getInt('id');
    // gender = await session.get('gender');
    fullname = await session.get('fullname');
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
      print('===============================4${response.statusCode}');
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