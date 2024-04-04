//import 'dart:html';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/home_page.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/customer.dart';
import '../helpers/components.dart';
import '../helpers/request.dart';
import '../helpers/session.dart';
import 'hire_artisan.dart';

class ReceiveRequestPage extends StatefulWidget {
  final createdRequestId;
  final customer;
  final noNeedForNewSound;

  const ReceiveRequestPage({super.key, this.createdRequestId, this.customer, this.noNeedForNewSound});
  @override
  ReceiveRequestPageWidget createState() => ReceiveRequestPageWidget(createdRequestId, customer, noNeedForNewSound);
}


class ReceiveRequestPageWidget extends State<ReceiveRequestPage> {
  final createdRequestId;
  final customer;
  final noNeedForNewSound;
  int processing = 0;
  int decline_processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late Customer artisanObj;
  late CustomerRequest requestObj;
  double waitingProgressLabel = 0;
  double waitingProgress = 0;
  bool request_waiting = false;

  AudioPlayer player = AudioPlayer();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController reviewController = TextEditingController();
  String review = '';
  String selectedRating = '';

  ReceiveRequestPageWidget(this.createdRequestId, this.customer, this.noNeedForNewSound);

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    double screen_height = MediaQuery.of(context).size.height - 200;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(7, 84, 40, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          Text('New\nService Request', textAlign: TextAlign.center, style: TextStyle(color: primaryColor, fontSize: 30),),
          Container(
              width: double.infinity,
              height: screen_height,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  CircleAvatar(
                    backgroundColor: Colors.yellow[400],
                    radius: 30,
                    child: Image.network(customer['img'], width: 50, height: 50,), //Text
                  ),
                  const SizedBox(height: 30,),
                  Text(customer['name'], style: TextStyle(fontSize: 20, color: secondaryColor),),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                backgroundColor: Colors.red[500],
                                shape: const StadiumBorder()
                              ),
                              onPressed: () async {
                                setState(() {
                                  decline_processing = 1;
                                  request_waiting = true;
                                });
                                print('....................... stopped!!');
                                player.stop();
                                await declineRequest();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Decline ', style: TextStyle(color: Colors.white, fontSize: 20),),
                                  (decline_processing == 1) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor,),) : const Icon(Icons.close, color: Colors.white,)
                                ],
                              )
                          )
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  padding: EdgeInsets.all(20),
                                  shape: StadiumBorder()
                              ),
                              onPressed: () async {
                                setState(() {
                                  processing = 1;
                                  request_waiting = true;
                                });
                                player.stop();
                                await getRequestAndArtisan();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Accept ', style: TextStyle(color: primaryColor, fontSize: 20),),
                                  (processing == 1) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor,),) : Icon(Icons.check_circle, color: primaryColor,)
                                ],
                              )
                          )
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  LinearProgressIndicator(
                    value: waitingProgress,
                    minHeight: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    backgroundColor: secondaryColor,
                    color: Colors.white,
                  ),
                  Text('You\'re loosing time...')
                ],
              )
          )
        ],
      ),
    );
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

    // if(noNeedForNewSound == false){
      String audioasset = "audio/1.mpeg";
      ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
      Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      int result = await player.playBytes(soundbytes);
      if(result == 1){ //play success
        print("Sound playing successful.");
      }else{
        print("Error while playing sound.");
      }

    // }

    double count = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // debugPrint(timer.tick.toString());
      count++;
      if(request_waiting){
        timer.cancel();
      }
      setState(() {
        // waitingProgress += timer.tick / 100;
        waitingProgressLabel++;
        waitingProgressLabel = count * 5;
        waitingProgress = count / 20;
      });
      if(timer.tick == 19){
        timer.cancel();
        if(request_waiting == false){
          if(!mounted){
            return;
          }
          Component().default_toast('You seem not to be available.');
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return HomeScreen();
          }));
        }
      }
    });
  }

  Future<void> getRequestAndArtisan() async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/get/request/and/artisan');
      var response = await http.post(url, body: {
        'user_id': customer['user_id'],
        'request_id': createdRequestId.toString(),
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
      print('-=====================-');
      print(server_response['artisan']);
      var obj = server_response['artisan'];
      var customer_request_obj = server_response['request'];
      Component().success_toast(message);
      setState(() {
        processing = 0;
        artisanObj = Customer(
          name: obj['name'],
          img: obj['img'],
          phone: obj['phone'],
          device_token: obj['device_token'],
          id: obj['id'].toString(),
          latitude: obj['latitude'],
          longitude: obj['longitude'],
          img_sm: obj['img_sm'],
          rating: obj['rating'],
          slug: obj['slug'],
          email: obj['email'],
          country: obj['country'],
          art_scope: obj['art_scope'],
          area: obj['area'],
          state: obj['state'],
        );

        requestObj = CustomerRequest(
          artisan_id: customer_request_obj['artisan_id'].toString(),
          user_id: customer_request_obj['user_id'].toString(),
          amount: customer_request_obj['amount'].toString(),
          asset_img: customer_request_obj['asset_img'],
          id: customer_request_obj['id'].toString(),
          asset_name: customer_request_obj['asset_name'],
          asset_slug: customer_request_obj['asset_slug'],
          status_code: customer_request_obj['status'].toString(),
          service: customer_request_obj['service'],
          slug: customer_request_obj['slug'],
          statusx_color: customer_request_obj['statusx_color'],
          status: customer_request_obj['status'].toString(),
          time_ago: customer_request_obj['time_ago'],
        );
      });
      print('HERE -------------------------');
      print(requestObj.status_code);
      print(requestObj.status);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HireArtisanPage(from: 'request-detail', customerObj: artisanObj, requestObj: requestObj,),
        ),
      );

    } finally {
      client.close();
    }
    setState(() {
      processing = 0;
    });
  }

  Future declineRequest() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/decline/request');
      var response = await http.post(url, body: {
        'reason': 'I just feel like..',
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
        });
        return [];
      }
      Component().success_toast(message);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );

    } finally {
      client.close();
    }
    setState(() {
      decline_processing = 0;
    });
  }

}