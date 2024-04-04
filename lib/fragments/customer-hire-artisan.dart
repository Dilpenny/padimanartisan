//import 'dart:html';

import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/rate_user.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../browser.dart';
import '../helpers/artisan.dart';
import '../helpers/components.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/session.dart';
import '../home_page.dart';
import '../map/.env.dart';
import 'chat_detail_page.dart';
import 'maps.dart';


class HireArtisanPage extends StatefulWidget {
  final artisanObj;
  final requestObj;
  final String from;

  const HireArtisanPage({Key? key, this.artisanObj, required this.from, this.requestObj}) : super(key: key);
  @override
  HireArtisanPageWidget createState() => HireArtisanPageWidget(artisanObj, from, requestObj);
}


class HireArtisanPageWidget extends State<HireArtisanPage> {
  final Artisan artisanObj;
  final requestObj;
  final String from;
  int processing = 1;
  int logged_in = 41900000;
  int user_id = 0;

  HireArtisanPageWidget(this.artisanObj, this.from, this.requestObj);

  final _formKey = GlobalKey<FormState>();
  bool hasCall = false;
  String incomingCallChannel = '';
  String requestSlug = '';
  String createdRequestId = '';
  late StateSetter _setState;
  String token = "";
  var calleeImg;
  var calleeName;
  late FirebaseMessaging _firebaseMessaging;

  bool canStartService = false;
  bool creatingRequest = true;
  String artisanPrice = '';
  String requestStatus = '0';
  bool requestStarted = false;
  bool requestCanceled = false;
  bool startingRequest = false;
  bool deletingRequest = false;
  bool cancelingRequest = false;
  bool canceledRequest = false;
  bool confirmingRequest = false;
  bool confirmedRequest = false;
  bool redFlagRegistered = false;
  bool terminateProccesses = false;
  bool flaggingIssue = false;
  bool request_waiting = false;
  int chatNotifications = 0;

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit this Request?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), //<-- SEE HERE
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                terminateProccesses = true;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen(),
                ),
              );
            }, // <-- SEE HERE
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  Widget canceledView(screen_height){
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(requestSlug, style: TextStyle(fontSize: 30, letterSpacing: 5, color: errorColor),),
          SizedBox(height: 15,),
          Divider(height: 1,),
          SizedBox(height: 10,),
          canceledLabels()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 280;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: IconButton(
              onPressed: (){
                setState(() {
                  terminateProccesses = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.close, color: primaryColor,),
            ),
          ),
          foregroundColor: Colors.yellow,
          backgroundColor: Color.fromRGBO(7, 84, 40, 1),
          elevation: 0,
          title: Text('Hiring ${artisanObj.art_scope!.toUpperCase()}', style: GoogleFonts.karla()),
        ),
        backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
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
                          backgroundImage: NetworkImage(artisanObj.img!),
                          maxRadius: 30,
                        ),
                        SizedBox(height: 10, width: double.infinity,),
                        Text(artisanObj.name!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),),
                        SizedBox(height: 5, width: double.infinity,),
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(width: 1, color: primaryColor),
                                      ),
                                      onPressed: () async {
                                        var url = 'tel:'+artisanObj.phone!;
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
                                          Text('Call ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),),
                                          Icon(Icons.phone, size: 15, color: whiteColor,)
                                        ],
                                      )
                                  ),
                                ),
                                (requestStarted || canStartService) ?
                                // (redFlagRegistered) ? SizedBox() :
                                const SizedBox(width: 10,) : Spacer(),
                                Expanded(
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(width: 1, color: primaryColor),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          chatNotifications = 0;
                                        });
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return ChatDetailPage(
                                            chatee_id: artisanObj.id,
                                            chatee_img: artisanObj.img,
                                            chatee_name: artisanObj.name!+' ('+artisanObj.art_scope!+')',
                                            request_id: createdRequestId,
                                          );
                                        }));
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text('Chat ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),),
                                          // (chatNotifications > 0) ? Badge(
                                          //   badgeColor: primaryColor,
                                          //   child: Icon(Icons.message_outlined, color: whiteColor, size: 15,),
                                          //   badgeContent: Text(chatNotifications.toString(), style: TextStyle(color: secondaryColor, fontSize: 12),),
                                          // ) : Icon(Icons.message_outlined, size: 15, color: whiteColor,),
                                        ],
                                      )
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10, width: double.infinity,),
                          ],
                        )
                      ],
                    ),
                  ),
                  (requestCanceled) ? canceledView(screen_height) : Container(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (creatingRequest) ? Component().line_loading() : hiringControls(),
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

  Future createRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      String paymentMethod = await session.get('payment_method');
      var url = Uri.parse('${Component().API}mobile/add/request');
      var response = await http.post(url, body: {
        'artisan_id': artisanObj.id,
        'asset_id': '1',
        'service': artisanObj.art_scope,
        'payment_method': paymentMethod,
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
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        return [];
      }
      // Component().success_toast(message);
      setState(() {
        creatingRequest = false;
        request_waiting = true;
      });

      requestSlug = server_response['code'];
      createdRequestId = server_response['id'].toString();
      double count = 0;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        // debugPrint(timer.tick.toString());
        count++;
        setState(() {
          // waitingProgress += timer.tick / 100;
          waitingProgressLabel++;
          waitingProgressLabel = count * 5;
          waitingProgress = count / 20;
        });
        if(terminateProccesses){
          timer.cancel();
        }
        if(timer.tick == 20){
          timer.cancel();
          if(request_waiting == true){
            Component().default_toast('Workman/artisan seems not to be available.');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
              ),
            );
          }
        }
      });
    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future startRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/start/request');
      var response = await http.post(url, body: {
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
          startingRequest = false;
        });
        return [];
      }
      Component().success_toast(message);
      setState(() {
        requestStarted = true;
        startingRequest = false;
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
      Component().success_toast('Wait');
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/cancel/request');
      var response = await http.post(url, body: {
        'reason': cancellationReason,
        'by_customer': "true",
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
      Navigator.pop(context);
      Component().success_toast(message);
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

  Future registerRedFlag(String red_flag) async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/register/red/flag');
      var response = await http.post(url, body: {
        'request_id': createdRequestId,
        'red_flag': red_flag,
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
          deletingRequest = false;
        });
        return [];
      }
      setState(() {
        flaggingIssue = false;
        redFlagRegistered = true;
        confirmingRequest = false;
        confirmedRequest = true;
      });
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
        'user_id': user_id.toString(),
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
          requestObj.status_code = '100';
        });
        return [];
      }
      Component().success_toast(message);
      setState(() {
        confirmingRequest = false;
        confirmedRequest = true;
      });
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => RateUserPage(artisanObj: artisanObj),
      //   ),
      // );

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future payFromWallet() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/pay/for/request');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'request_id': requestObj.id.toString(),
        'amount': requestObj.amount,
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
          payingFromWallet = false;
        });
        return [];
      }
      Component().success_toast(message);
      Navigator.pop(context);
      setState(() {
        payingFromWallet = false;
        confirmingRequest = false;
        confirmedRequest = true;
      });
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => RateUserPage(artisanObj: artisanObj),
      //   ),
      // );

    } finally {
      client.close();
    }
  }

  bool payingFromWallet = false;

  double waitingProgress = 0;
  double waitingProgressLabel = 0;

  Widget pendingLabels(){
    return Column(
      children: [
        (request_waiting) ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Waiting for workman/artisan to accept this request.', textAlign: TextAlign.center,),
            LinearProgressIndicator(
              value: waitingProgress,
              minHeight: 10,
              valueColor: new AlwaysStoppedAnimation<Color>(secondaryColor),
              backgroundColor: primaryColor,
              color: Colors.white,
            )
          ],
        ) : Row(
          children: [
            SizedBox(
              child: Row(children: [Expanded(child: Icon(Icons.info_outline, color: Colors.black45,),)],),
              width: 35,
            ),
            Expanded(
                child: (canStartService) ? const Text('You can start service if the BELOW price is ok by YOU.') :
                Text('Waiting for ${artisanObj.name} to update request with a price. You can chat with him during this time.')
            )
          ],
        ),
      ],
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
              children: [
                Icon(Icons.info_outline),
                Text(' Artisan has canceled request.', textAlign: TextAlign.center,)
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

  Widget startedLabels(){
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
                (confirmedRequest) ? Text('Completed and settled', style: TextStyle(color: Colors.green, fontSize: 20),) :
                (requestCanceled) ?
                Text('This service has been canceled and is no longer active.', style: TextStyle(color: Colors.red),) :
                Text('Service is in progress. Do well to ensure that ${artisanObj.name} handles the job efficiently before'
                    'confirming and payments.')
            )
          ],
        )
      ],
    );
  }

  Widget sessionButtons(){
    return Column(
        children:[
          (redFlagRegistered) ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have registered an unsatisfactory issue.\nPlease hold on Admin will handle the situation.',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              Divider(height: 1,),
              SizedBox(height: 10,),
              OutlinedButton(
                  onPressed: () async {
                    String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return MyBrowser(title: 'Chat With Agent', link: url,);
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Chat with Agent', style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1)),)
                      ],
                    ),
                  )
              )
            ],
          ) : Row(
            children: [
              (requestCanceled) ? Row(
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
                                style: TextStyle(fontSize: 14,
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
                  ]) : (confirmedRequest) ? SizedBox() : Expanded(
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
                        Text(" Unsatisfied? ".toUpperCase(),
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        (cancelingRequest) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : Icon(Icons.close, size: 20, color: Colors.white,)
                      ],
                    ),
                  ),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(  // You need this, notice the parameters below:
                            builder: (BuildContext context, StateSetter setState)
                            {
                              _setState = setState;
                              return AlertDialog(
                                title: Text('What is the issue?'.toUpperCase(), textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                        color: secondaryColor)),
                                content: Container(
                                  height: 300,
                                  child: ListView(
                                    children: [
                                      for(int counter = 0; counter < RED_FLAGS.length; counter++)
                                        (RED_FLAGS[counter].isEmpty) ? const SizedBox() : ListTile(
                                          title: Text(RED_FLAGS[counter]),
                                          onTap: () async {
                                            if (await confirm(
                                              context,
                                              title: Text(RED_FLAGS[counter]+'?', style: TextStyle(color: Colors.red),),
                                              content: const Text('Are you sure?'),
                                              textOK: const Text('Yes'),
                                              textCancel: const Text('No'),)
                                            ) {
                                              setState(() {
                                                flaggingIssue = true;
                                              });
                                              await registerRedFlag(counter.toString()); // register red flagß
                                              return print('pressedOK');
                                            }
                                          },
                                          trailing: Icon(Icons.chevron_right),
                                        ),
                                      (flaggingIssue) ? Column(
                                        children: [
                                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: secondaryColor,),),
                                          Text('Please wait...')
                                        ],
                                      ) : SizedBox()
                                    ],
                                  ),
                                ),
                              );
                            }
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 10,),
              (confirmedRequest) ? SizedBox() : Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.green,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(" CONFIRMED ",
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        (confirmingRequest) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,),) : Icon(Icons.check_circle, size: 20, color: Colors.white,)
                      ],
                    ),
                  ),
                  onTap: () async {
                    _setState = setState;
                    if (await confirm(
                      context,
                      title: const Text('Confirm completion'),
                      content: Column(
                        children: [
                          const Text('Have you confirmed that the service is properly done?'),
                          const SizedBox(height: 5,),
                          Text('Make your payment', style: GoogleFonts.quicksand()),
                          const SizedBox(height: 5,),
                          SizedBox(
                            child: TextButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(secondaryColor)),
                                onPressed: () async {
                                  // setState(() {
                                  //   payingFromWallet = true;
                                  // });
                                  _setState(() {
                                    payingFromWallet = true;
                                  });
                                  await payFromWallet();
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (payingFromWallet) ? SizedBox(width: 20, child: CircularProgressIndicator(color: whiteColor,),) : Icon(Icons.wallet, color: whiteColor,),
                                    Text(' Pay from Wallet',
                                      style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold),)
                                  ],
                                )
                            ),
                            width: 200,
                          ),
                          const SizedBox(height: 5,),
                          const Divider(height: 1,),
                          const SizedBox(height: 5,),
                          Text('For Transfer, USSD, Card Payments, use PAYSTACK',
                            style: GoogleFonts.quicksand(fontSize: 14),),
                          const SizedBox(height: 5,),
                          SizedBox(
                            child: TextButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(secondaryColor)),
                                onPressed: (){
// setState(() {
                                  //   confirmingRequest = true;
                                  // });
                                  String url_request_id = requestObj.id;
                                  String url_request_amount = requestObj.amount;
                                  String url_request_user_id = user_id.toString();
                                  String urrl = "user_id=$url_request_user_id&amount=$url_request_amount&request_id=$url_request_id";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => MyBrowser(
                                        title: 'Pay for job',
                                        link: '${Component().API}online/request/payment?$urrl',
                                      ),
                                    ),
                                  );
                                  // await confirmRequest();
                                  return print('pressedOK');
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.credit_card_rounded, color: whiteColor),
                                    Text(' Use Paystack', style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold),)
                                  ],
                                )
                            ),
                            width: 200,
                          )
                        ],
                      ),
                      textOK: const Text(''),
                      textCancel: const Text('No'),)
                    ) {
// setState(() {
                      //   confirmingRequest = true;
                      // });
                      String url_request_id = requestObj.id;
                      String url_request_amount = requestObj.amount;
                      String url_request_user_id = user_id.toString();
                      String urrl = "user_id=$url_request_user_id&amount=$url_request_amount&request_id=$url_request_id";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MyBrowser(
                            title: 'Pay for job',
                            link: '${Component().API}online/request/payment?$urrl',
                          ),
                        ),
                      );
                      // await confirmRequest();
                      return print('pressedOK');
                    }
                    return print('pressedCancel');
                  },
                ),
              ),
            ],
          )
        ]
    );
  }

  String cancellationReason = '';

  Widget hiringControls(){
    return Column(
      children: [
        Text(requestSlug, style: TextStyle(fontSize: 30, letterSpacing: 5, color: const Color.fromRGBO(7, 84, 40, 1)),),
        SizedBox(height: 15,),
        Divider(height: 1,),
        SizedBox(height: 10,),
        (requestStarted) ? startedLabels() : pendingLabels(),
        SizedBox(height: 10,),
        (artisanPrice.length < 1) ? SizedBox() : Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('₦'+artisanPrice, style: TextStyle(fontSize: 35, color: const Color.fromRGBO(7, 84, 40, 1), fontWeight: FontWeight.bold),),
                (requestStarted) ? Icon(Icons.thumb_up, color: const Color.fromRGBO(7, 84, 40, 1),) : SizedBox()
              ],
            ),
            SizedBox(height: 10,)
          ],
        ),
        (requestStarted) ? sessionButtons() :
        (request_waiting) ? Chip(label: SizedBox(child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_bottom, color: secondaryColor,),
            Text('Waiting...${waitingProgressLabel.ceil()}%')
          ],
        ),)) : Column(
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
                          color: (canStartService) ? Colors.yellow : Colors.yellow[100],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(" START SERVICE ",
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: (canStartService) ? const Color.fromRGBO(7, 84, 40, 1) : const Color.fromRGBO(7, 84, 40, 0.5)
                              ),
                            ),
                            (startingRequest) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: const Color.fromRGBO(7, 84, 40, 1),),) : Icon(Icons.timer, size: 20, color: (canStartService) ? const Color.fromRGBO(7, 84, 40, 1) : const Color.fromRGBO(7, 84, 40, 0.5),)
                          ],
                        ),
                      ),
                      onTap: () async {
                        if(!canStartService){
                          Component().error_toast('Please hold on fr workman to set price.');
                          return;
                        }
                        String message = '₦${artisanPrice} will be deducted from your \nwallet AUTOMATICALLY.';
                        if(requestObj.payment_method.toString().toLowerCase().contains('cash')){
                          message = 'You will be paying ₦${artisanPrice} for this service, '
                              'please make sure the physical cash is AVAILABLE';
                        }else if(requestObj.payment_method.toString().toLowerCase().contains('online')){
                          message = 'You will be paying ₦${artisanPrice} for this service via our ONLINE payment service';
                        }
                        if (await confirm(
                          context,
                          title: Text('Start this service?'.toString().toUpperCase(), style: TextStyle(color: const Color.fromRGBO(7, 84, 40, 1)),),
                          content: Text(message),
                          textOK: const Text('Yes'),
                          textCancel: const Text('No'),)
                        ) {
                          setState(() {
                            startingRequest = true;
                          });
                          // START SERVICE
                          await startRequest();
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
                          style: TextStyle(fontSize: 14,
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
                              style: TextStyle(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                            SizedBox(height: 5,),
                            Text('Your reason will not be shared with the customer.',
                              style: TextStyle(color: mutedColor, fontSize: 12),)
                          ],
                        ),
                        content: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: RED_FLAGS.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Column(
                                children: [
                                  ListTile(
                                    title: Text(RED_FLAGS[index], style: TextStyle(fontSize: 13),),
                                    onTap: () async {
                                      if (await confirm(
                                        context,
                                        title: Text('Cancel service?', style: TextStyle(color: darkColor, fontSize: 20, fontWeight: FontWeight.w900),),
                                        content: Column(
                                          children: [
                                            Text('This can not be undone. You want to go ahead?',
                                              style: TextStyle(fontSize: 12),),
                                            SizedBox(height: 5,),
                                            const Text('Reason being:'),
                                            SizedBox(height: 5,),
                                            Text("\"${RED_FLAGS[index]}\"", style: TextStyle(color: mutedColor),),
                                          ],
                                        ),
                                        textOK: Text('Yes, cancel', style: TextStyle(color: errorColor),),
                                        textCancel: const Text('No'),)
                                      ) {
                                        if(cancelingRequest){
                                          return;
                                        }
                                        setState(() {
                                          cancellationReason = RED_FLAGS[index];
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
      print("============ 11 ........"+event.data['amount'].toString());
      print(event.data['accepted_request']);

      if(event.data['chat'] != null && createdRequestId == event.data['request_id']) {
        chatNotifications++;
        setState(() {
          chatNotifications = chatNotifications;
        });
      }

      if(event.data['accepted_request'] != null && createdRequestId == event.data['request_id']){
        setState(() {
          int amount = int.parse(event.data['amount'].toString());
          requestObj.amount = amount.toString();
          requestObj.status_code = '1';
          requestObj.id = createdRequestId;
          artisanPrice = amount.toString();
          canStartService = true;
        });
      }
      if(event.data['cancel_request'] != null && createdRequestId == event.data['request_id']){
        Component().success_toast('Request canceled');
        setState(() {
          requestCanceled = true;
        });
      }
      if(event.data['claimed_request'] != null && createdRequestId == event.data['request_id']){
        Component().success_toast('Request accepted');
        setState(() {
          request_waiting = false;
        });
      }
      if(event.data['declined_request'] != null && createdRequestId == event.data['request_id']){
        Component().error_toast('Artisan declined.');
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
        );
      }


    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('********************************** Message clicked!');
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
          canStartService = true;
        });
      }else if(requestStatus == '10'){
        // STARTED
        setState(() {
          requestStarted = true;
          startingRequest = false;
        });
      }else if(requestStatus == '419'){
        // STARTED
        setState(() {
          requestCanceled = true;
          startingRequest = false;
        });
      }else if(requestStatus == '0'){
        // PENDING
        setState(() {
          requestSlug = requestObj.slug;
          createdRequestId = requestObj.id.toString();
        });
      }
    }else{
      createRequest();
    }
  }

}