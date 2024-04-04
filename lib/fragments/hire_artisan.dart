//import 'dart:html';

import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/rate_user.dart';
import 'package:padimanartisan/home_page.dart';
import '../browser.dart';
import '../helpers/artisan.dart';
import '../helpers/customer.dart';
import '../helpers/components.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/session.dart';
import '../map/.env.dart';
import 'chat_detail_page.dart';
import 'maps.dart';


class HireArtisanPage extends StatefulWidget {
  final customerObj;
  final requestObj;
  final String from;

  const HireArtisanPage({Key? key, this.customerObj, required this.from, this.requestObj}) : super(key: key);
  @override
  HireArtisanPageWidget createState() => HireArtisanPageWidget(customerObj, from, requestObj);
}


class HireArtisanPageWidget extends State<HireArtisanPage> {
  final Customer customerObj;
  final requestObj;
  final String from;
  int processing = 1;
  int logged_in = 41900000;
  int user_id = 0;

  HireArtisanPageWidget(this.customerObj, this.from, this.requestObj);

  final _formKey = GlobalKey<FormState>();
  bool hasCall = false;
  String incomingCallChannel = '';
  String requestSlug = '';
  String createdRequestId = '';
  String token = "";
  var calleeImg;
  var calleeName;
  bool canceledRequest = false;
  late FirebaseMessaging _firebaseMessaging;

  bool canStartService = false;
  bool creatingRequest = true;
  String artisanPrice = '';
  String requestStatus = '0';
  bool requestAccepted = false;
  bool requestStarted = false;
  bool requestCanceled = false;
  bool acceptingRequest = false;
  bool deletingRequest = false;
  bool cancelingRequest = false;
  bool confirmingRequest = false;
  bool confirmedRequest = false;
  int chatNotifications = 0;
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 280;
    return WillPopScope(
      onWillPop: () async {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
          title: Text('Exiting this screen would cancel this request!',
            style: GoogleFonts.quicksand(color: Colors.red),),
          content: const Text('Do you want to Cancel?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(),
                  ),
                );
              },
              child: Text('Yes', style: GoogleFonts.quicksand(color: Colors.red)),
            ),
          ],
        ),
        );
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.all(10),
              child: IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.close, color: darkColor,),
              ),
            ),
            foregroundColor: darkColor,
            backgroundColor: whiteColor,
            elevation: 0,
            title: Text('${requestObj.service!.toUpperCase()} needed', style: GoogleFonts.quicksand()),
          ),
          backgroundColor: whiteColor,
          body: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(customerObj.img!),
                            maxRadius: 30,
                          ),
                          SizedBox(height: 10, width: double.infinity,),
                          Text(customerObj.name!, style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),),
                          SizedBox(height: 5, width: double.infinity,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (requestStarted || canStartService) ?
                              (confirmedRequest) ? const SizedBox() :
                              Expanded(
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(width: 1, color: secondaryColor),
                                    ),
                                    onPressed: () async {
                                      var url = 'tel:'+customerObj.phone!;
                                      Uri _url = Uri.parse(url);
                                      if(await canLaunchUrl(_url)){
                                        await launchUrl(_url, webOnlyWindowName: 'Padiman');  //forceWebView is true now
                                      }else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Call ', style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryColor),),
                                        Icon(Icons.phone, size: 15, color: secondaryColor,)
                                      ],
                                    )
                                ),
                              ) : const SizedBox(),
                              Spacer(),
                              Expanded(
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(width: 1, color: secondaryColor),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            chatNotifications = 0;
                                          });
                                          Navigator.push(context, MaterialPageRoute(builder: (context){
                                            return ChatDetailPage(
                                              chatee_id: customerObj.id,
                                              chatee_img: customerObj.img,
                                              chatee_name: customerObj.name!+' (Customer)',
                                              request_id: createdRequestId,
                                            );
                                          }));
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Chat ', style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryColor),),
                                            (chatNotifications > 0) ? Badge(
                                              // badgeColor: primaryColor,
                                              child: Icon(Icons.message_outlined, color: whiteColor, size: 15,),
                                              // badgeContent: Text(chatNotifications.toString(), style: TextStyle(color: secondaryColor, fontSize: 12),),
                                            ) : Icon(Icons.message_outlined, size: 15, color: whiteColor,),
                                          ],
                                        )
                                    ),
                            ),
                              Spacer(),
                              Expanded(
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(width: 1, color: secondaryColor),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        chatNotifications = 0;
                                      });

                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                        return MapHomePage(
                                          destinationLatitude: double.parse(customerObj.latitude!),
                                          destinationLongitude: double.parse(customerObj.longitude!),
                                          artisanObj: Artisan(
                                            name: customerObj.name,
                                            email: customerObj.email,
                                            phone: customerObj.phone,
                                            latitude: customerObj.latitude,
                                            longitude: customerObj.longitude,
                                            art_scope: customerObj.art_scope,
                                            area: customerObj.area,
                                            country: customerObj.country,
                                            state: customerObj.state,
                                            slug: customerObj.slug,
                                            id: customerObj.id,
                                            img: customerObj.img,
                                            img_sm: customerObj.img_sm,
                                            device_token: customerObj.device_token,
                                            rating: customerObj.rating,
                                          ),
                                        );
                                      }));
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Locate ', style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryColor),),
                                        Icon(Icons.location_on_outlined, size: 15, color: secondaryColor,),
                                      ],
                                    )
                                ),
                              ),
                            ],

                          ),
                          SizedBox(height: 10, width: double.infinity,),
                        ],
                      ),
                    ),
                    Container(
                      height: screen_height,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("graphics/dashboard-bg.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: (requestCanceled) ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(requestSlug, style: TextStyle(fontSize: 30, letterSpacing: 5, color: errorColor),),
                          SizedBox(height: 15,),
                          Divider(height: 1,),
                          SizedBox(height: 10,),
                          canceledLabels()
                        ],
                      ) : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (creatingRequest) ? Component().line_loading() : (confirmedRequest) ? completedView() : hiringControls(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.chat),
            backgroundColor: Colors.yellow,
            foregroundColor: const Color.fromRGBO(7, 84, 40, 1),
            onPressed: () { 
              String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return MyBrowser(title: 'Chat With Agent', link: url,);
              }));
             },
          ),
        ),
    );
  }


  Widget canceledLabels(){
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(label: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline),
                Text(' Customer has canceled request.', textAlign: TextAlign.center,)
              ],
            ),),
            const SizedBox(height: 10,),
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen(),
                    ),
                  );
                },
                child: const Text('Close')
            )
          ],
        )
      ],
    );
  }


  Widget completedView(){
    return Column(
      children: [
        Text('Completed and done!', style: GoogleFonts.quicksand(color: secondaryColor, fontSize: 20),),
        SizedBox(height: 10,),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.yellow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Ok",
                  style: GoogleFonts.quicksand(fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(7, 84, 40, 1)
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return HomeScreen();
            }));
          },
        ),
      ],
    );
  }

  Future createRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/add/request');
      var response = await http.post(url, body: {
        'artisan_id': customerObj.id,
        'asset_id': '1',
        'service': customerObj.art_scope,
        'user_id': user_id.toString(),
      });
      print('...........................................');
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
        return [];
      }
      // Component().success_toast(message);
      setState(() {
        creatingRequest = false;
      });

      requestSlug = server_response['code'];
      createdRequestId = server_response['id'].toString();
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future acceptRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/accept/request');
      var response = await http.post(url, body: {
        'request_id': createdRequestId,
        'user_id': user_id.toString(),
        'amount': amountController.text.toString(),
      });
      print('...........................................');
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
          acceptingRequest = false;
        });
        return [];
      }
      Component().success_toast(message);
      setState(() {
        requestAccepted = true;
        acceptingRequest = false;
      });

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future cancelRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/cancel/request');
      var response = await http.post(url, body: {
        'reason': cancellationReason,
        'request_id': createdRequestId,
        'user_id': user_id.toString(),
      });
      print('...........................................');
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
          cancelingRequest = false;
        });
        return [];
      }
      Component().success_toast(message);
      Navigator.pop(context);
      setState(() {
        requestCanceled = true;
        cancelingRequest = false;
      });

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future trashRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/trash/request');
      var response = await http.post(url, body: {
        'request_id': createdRequestId,
      });
      print('...........................................');
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
          deletingRequest = false;
        });
        return [];
      }
      Component().success_toast(message);
      Navigator.pop(context);

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future confirmRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/confirm/request');
      var response = await http.post(url, body: {
        'user_id': user_id,
        'request_id': createdRequestId,
      });
      print('...........................................');
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
          confirmingRequest = false;
        });
        return [];
      }
      Component().success_toast(message);
      setState(() {
        confirmingRequest = false;
        confirmedRequest = true;
      });

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Widget pendingLabels(){
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              child: Row(children: [Expanded(child: Icon(Icons.info_outline, color: Colors.black45,),)],),
              width: 35,
            ),
            Expanded(
                child: Text('Customer is requesting your service. Enter your charge below:')
            ),
          ],
        ),
        SizedBox(height: 10,),
        TextFormField(
          keyboardType: TextInputType.number,
          controller: amountController,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              prefixText: '₦',
              hintText: 'Workmanship amount'
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Required field';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget statedLabels(){
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              child: Row(children: [Expanded(child: Icon(Icons.info_outline, color: Colors.black45,),)],),
              width: 35,
            ),
            Expanded(
                child: Text('Customer has accepted your price. You can start rending your service.')
            ),
          ],
        ),
      ],
    );
  }

  Widget acceptedLabels(){
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              child: Row(children: [Expanded(child: Icon(Icons.info_outline, color: (requestCanceled) ? Colors.red : Colors.green,),)],),
              width: 35,
            ),
            Expanded(
                child:
                (requestAccepted) ? Text('Waiting for customer to accept and start Request.', style: GoogleFonts.quicksand(color: Colors.green),) : SizedBox()
            )
          ],
        )
      ],
    );
  }

  String cancellationReason = '';

  Widget sessionButtons(){
    return Column(
        children:[
          Row(
            children: [
              (requestCanceled)
                  ?
              Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(" DELETE ",
                                style: GoogleFonts.quicksand(fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              (deletingRequest) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : Icon(Icons.delete, size: 20, color: Colors.white,)
                            ],
                          ),
                        ),
                        onTap: () async {
                          // LOOK FOR A WAY TO PROVIDE REASON
                          if (await confirm(
                            context,
                            title: const Text('Permanently Delete?'),
                            content: const Text('This can not be undone. You want to go ahead?'),
                            textOK: const Text('Yes'),
                            textCancel: const Text('No'),)
                          ) {
                            setState(() {
                              deletingRequest = true;
                            });
                            await trashRequest();
                            return print('pressedOK');
                          }
                          return print('pressedCancel');
                        },
                      ),
                    ),
                  ])
                  :
              Visibility(visible: true,child: Expanded(
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 80),
                    padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.red,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(" CANCEL SERVICE ",
                          style: GoogleFonts.quicksand(fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        (cancelingRequest) ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : Icon(Icons.close, size: 20, color: Colors.white,)
                      ],
                    ),
                  ),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Reason for cancellation',
                              style: GoogleFonts.quicksand(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                            const SizedBox(height: 5,),
                            Text('Your reason will not be shared with the customer.',
                              style: GoogleFonts.quicksand(color: mutedColor, fontSize: 12),)
                          ],
                        ),
                        content: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: CANCEL_REASONS.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Column(
                                children: [
                                  ListTile(
                                    title: Text(CANCEL_REASONS[index], style: GoogleFonts.quicksand(fontSize: 13),),
                                    onTap: () async {
                                      if (await confirm(
                                        context,
                                        title: Text('Cancel service?', style: GoogleFonts.quicksand(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                                        content: Column(
                                          children: [
                                            Text('This can not be undone. You want to go ahead?',
                                              style: GoogleFonts.quicksand(fontSize: 12),),
                                            SizedBox(height: 5,),
                                            const Text('Reason being:'),
                                            SizedBox(height: 5,),
                                            Text("\"${CANCEL_REASONS[index]}\"", style: GoogleFonts.quicksand(color: mutedColor),),
                                          ],
                                        ),
                                        textOK: Text('Yes, cancel', style: GoogleFonts.quicksand(color: errorColor),),
                                        textCancel: const Text('No'),)
                                      ) {
                                        if(cancelingRequest){
                                          return;
                                        }
                                        setState(() {
                                          cancellationReason = CANCEL_REASONS[index];
                                          cancelingRequest = true;
                                        });
                                        await cancelRequest();
                                      }
                                    },
                                  ),
                                  Divider(height: 1, color: mutedColor,),
                                ],
                              )
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                    // LOOK FOR A WAY TO PROVIDE REASON

                  },
                ),
              ),),

            ],
          )
        ]
    );
  }

  Widget hiringControls(){
    return Column(
      children: [
        Text(requestSlug, style: GoogleFonts.quicksand(fontSize: 30, letterSpacing: 5, color: const Color.fromRGBO(7, 84, 40, 1)),),
        (canceledRequest) ? Column(
            children:[
              SizedBox(height: 10,),
              Text('CANCELED!', style: GoogleFonts.quicksand(color: Colors.red, fontSize: 20),),
              SizedBox(height: 10,),
              Row(
                children: [
                  SizedBox(
                    child: Row(children: [Expanded(child: Icon(Icons.info_outline, color: Colors.red,),)],),
                    width: 35,
                  ),
                  Expanded(
                      child: Text('Request has been canceled. If you have any cause for '
                          'complaints pls an Admin is available to chat with you.')
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.yellow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Close ",
                              style: GoogleFonts.quicksand(fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor
                              ),
                            ),
                            Icon(Icons.close, color: secondaryColor)
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return HomeScreen();
                        }));
                      },
                    ),
                  ),
                ],
              )
            ]
        ) :
        Column(
          children: [
            SizedBox(height: 15,),
            Divider(height: 1,),
            SizedBox(height: 10,),
            (requestAccepted) ? acceptedLabels() : (requestStarted) ? statedLabels() : pendingLabels(),
            SizedBox(height: 10,),
            (artisanPrice.length < 1) ? SizedBox() : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('₦'+artisanPrice, style: GoogleFonts.quicksand(fontSize: 35, color: const Color.fromRGBO(7, 84, 40, 1), fontWeight: FontWeight.bold),),
                    (requestAccepted) ? Icon(Icons.thumb_up, color: const Color.fromRGBO(7, 84, 40, 1),) : SizedBox()
                  ],
                ),
                SizedBox(height: 10,)
              ],
            ),
            (requestAccepted) ? sessionButtons() :
            (requestStarted) ? SizedBox(
              child: Text('YOU CAN START WORK NOW.', style: GoogleFonts.quicksand(fontSize: 20),),
            ) : Column(
                children:[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.yellow,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(" ACCEPT WITH PRICE ",
                                  style: GoogleFonts.quicksand(fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(7, 84, 40, 1)
                                  ),
                                ),
                                (acceptingRequest) ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color.fromRGBO(7, 84, 40, 1),),) : Icon(Icons.check_circle, size: 20, color: const Color.fromRGBO(7, 84, 40, 1),)
                              ],
                            ),
                          ),
                          onTap: () async {
                            if(cancelingRequest){
                              Component().error_toast('Access denied: Canceling request');
                              return;
                            }
                            artisanPrice = amountController.text;
                            if(artisanPrice.isEmpty){
                              Component().error_toast('Please enter an amount');
                              return;
                            }
                            if(double.parse(artisanPrice) < 1){
                              Component().error_toast('Please enter an amount');
                              return;
                            }
                            if (await confirm(
                              context,
                              title: Text('Accept service?'.toString().toUpperCase(), style: GoogleFonts.quicksand(color: const Color.fromRGBO(7, 84, 40, 1)),),
                              content: Text('₦${artisanPrice} is what you are charging.'),
                              textOK: Text('Yes', style: GoogleFonts.quicksand(),),
                              textCancel: Text('No', style: GoogleFonts.quicksand(),),)
                            ) {
                              setState(() {
                                acceptingRequest = true;
                              });
                              // START SERVICE
                              setState(() {
                                artisanPrice = artisanPrice;
                              });
                              await acceptRequest();
                              return;
                            }
                            return print('pressedCancel');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 80),
                        padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.red,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(" CANCEL SERVICE ",
                              style: GoogleFonts.quicksand(fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            ),
                            (cancelingRequest) ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : Icon(Icons.close, size: 20, color: Colors.white,)
                          ],
                        ),
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Reason for cancellation',
                                  style: GoogleFonts.quicksand(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                                SizedBox(height: 5,),
                                Text('Your reason will not be shared with the customer.',
                                  style: GoogleFonts.quicksand(color: mutedColor, fontSize: 12),)
                              ],
                            ),
                            content: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: CANCEL_REASONS.length,
                              itemBuilder: (context, index) => Column(
                                children: [
                                  Column(
                                    children: [
                                      ListTile(
                                        title: Text(CANCEL_REASONS[index], style: GoogleFonts.quicksand(fontSize: 13),),
                                        onTap: () async {
                                          if (await confirm(
                                            context,
                                            title: Text('Cancel service?', style: GoogleFonts.quicksand(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                                            content: Column(
                                              children: [
                                                Text('This can not be undone. You want to go ahead?',
                                                  style: GoogleFonts.quicksand(fontSize: 12),),
                                                SizedBox(height: 5,),
                                                const Text('Reason being:'),
                                                SizedBox(height: 5,),
                                                Text("\"${CANCEL_REASONS[index]}\"", style: GoogleFonts.quicksand(color: mutedColor),),
                                              ],
                                            ),
                                            textOK: Text('Yes, cancel', style: GoogleFonts.quicksand(color: errorColor),),
                                            textCancel: const Text('No'),)
                                          ) {
                                            if(cancelingRequest){
                                              return;
                                            }
                                            setState(() {
                                              cancellationReason = CANCEL_REASONS[index];
                                              cancelingRequest = true;
                                            });
                                            await cancelRequest();
                                          }
                                        },
                                      ),
                                      Divider(height: 1, color: mutedColor,),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                        // LOOK FOR A WAY TO PROVIDE REASON

                      },
                    ),
                  ),
                ]
            )
          ],
        )
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    // get_profile();
    super.initState();

    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((value){
      print('Token: '+value.toString());
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print(event.notification!.body);
      String notificationTitle = event.notification!.title.toString();
      String notificationMessage = event.notification!.body.toString();
      if(event.data['chat'] != null && createdRequestId == event.data['request_id']) {
        chatNotifications++;
        setState(() {
          chatNotifications = chatNotifications;
        });
      }

      
      if(event.data['start_request'] != null && createdRequestId == event.data['request_id']){
        setState(() {
          requestStarted = true;
          acceptingRequest = false;
          requestAccepted = false;
        });
      }
      if(event.data['cancel_request'] != null && createdRequestId == event.data['request_id']){
        setState(() {
          canceledRequest = true;
        });
      }
      if(event.data['confirmed_request'] != null && createdRequestId == event.data['request_id']){
        setState(() {
          confirmedRequest = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RateUserPage(artisanObj: customerObj),
          ),
        );
      }

    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('********************************** Message clicked!');
      String notificationTitle = message.notification!.title.toString();
      String notificationMessage = message.notification!.body.toString();
      if(notificationMessage.toLowerCase().contains('customer has accepted your stated price')){
        // notificationTitle
        requestStarted = true;
        acceptingRequest = false;
        requestAccepted = false;
      }
    });
    firstThings();
  }

  void firstThings(){

    if(from.contains('request-detail')){
      setState(() {
        creatingRequest = false;
      });
      requestStatus = requestObj.status_code;
      if(requestStatus == '1'){
        //  ACCEPTED
        setState(() {
          requestSlug = requestObj.slug;
          createdRequestId = requestObj.id.toString();
          requestAccepted = true;
          acceptingRequest = false;
        });
      }else if(requestStatus == '10'){
        // STARTED
        setState(() {
          requestStarted = true;
          acceptingRequest = false;
          requestAccepted = false;
        });
      }else if(requestStatus == '0'){
        // PENDING
        setState(() {
          requestSlug = requestObj.slug;
          createdRequestId = requestObj.id.toString();
        });
      }else if(requestStatus == '9'){
        // PENDING
        setState(() {
          requestSlug = requestObj.slug;
          createdRequestId = requestObj.id.toString();
        });
      }else if(requestStatus == '419'){
        // PENDING
        setState(() {
          requestSlug = requestObj.slug;
          canceledRequest = true;
        });
      }
    }else{
      createRequest();
    }
  }

}