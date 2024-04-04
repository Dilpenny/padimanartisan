//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/browser.dart';
import '../map/.env.dart';
import 'assets.dart';
import 'edit_asset.dart';
import 'locator.dart';
import '../helpers/asset.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/car_hire.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class CarForHireDetailPage extends StatefulWidget {
  final carObj;

  const CarForHireDetailPage({super.key, required this.carObj});
  @override
  CarForHireDetailPageWidget createState() => CarForHireDetailPageWidget(carObj);
}

class CarForHireDetailPageWidget extends State<CarForHireDetailPage> {
  final CarHire carObj;
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  late StateSetter _setState;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();

  CarForHireDetailPageWidget(this.carObj);

  Column deleteAssetView(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: TextButton(
              onPressed: () {
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
                    padding: const EdgeInsets.only(left: 20,right: 8,top: 2,bottom: 2),
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.red,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Yes delete  ", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.white),),
                        (processing == 1) ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white,),) : const Icon(Icons.delete,color: Colors.white,size: 15,),
                      ],
                    ),
                  ),
                  onTap: () async {
                    await deleteAsset();
                  },
                )
            ),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return Scaffold(
      appBar: AppBar(
          foregroundColor: darkColor,
          backgroundColor: whiteColor,
          elevation: 0,
          title: const Text("Hire information"),
      ),
      backgroundColor: whiteColor,
      body: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 10),
        height: screen_height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white,
        ),
        child:
        SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Find a suitable item for your usage',
                    style: GoogleFonts.quicksand(fontSize: 18), textAlign: TextAlign.center,)
                ],
              ),
              Image.network(carObj.photo!),
              const SizedBox(height: 20,),
              actions('Car:', carObj.name!),
              actions('Country:', carObj.country!),
              actions('Model:', carObj.model!),
              actions('Price/hr:', '₦'+carObj.price_per_hour!),
              actions('Price/day:', '₦'+carObj.price_per_day!),
              actions('Price/week:', '₦'+carObj.price_per_week!),
              actions('Price/month:', '₦'+carObj.price_per_month!),
              actions('Price with driver:', '₦'+carObj.price_with_driver!),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () async {
                            var url = 'tel:+2347067403973';
                            Uri _url = Uri.parse(url);
                            if(await canLaunchUrl(_url)){
                              await launchUrl(_url, webOnlyWindowName: 'Padiman');  //forceWebView is true now
                            }else {
                              throw 'Could not call $url';
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.phone, color: Color.fromRGBO(7, 84, 40, 1),),
                                const Text('Call now', style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1)),)
                              ],
                            ),
                          )
                      )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                      child: OutlinedButton(
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
                                Icon(Icons.chevron_right, color: Color.fromRGBO(7, 84, 40, 1),),
                                const Text('Chat With Agent', style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1)),)
                              ],
                            ),
                          )
                      )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget actions(String? title, String value){
    if(value.isEmpty || value == 'null'){
      return const SizedBox();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){

          },
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!.substring(0, 1).toUpperCase()+title.substring(1),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                ],
              ),
              const Spacer(),
              Text(value,style: const TextStyle(color: Colors.black, fontSize: 20))
            ],
          ),
        ),
        const SizedBox(height: 10,),
        const Divider(height: 0.5, color: Colors.black26,),
        const SizedBox(height: 10,),
      ],
    );
  }

  Future<void> deleteAsset() async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/trash/asset');
      var response = await http.post(url, body: {
        'asset_id': carObj.id,
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
        _setState(() {
          processing = 0;
        });
        return;
      }
      Component().success_toast(message);
      setState(() {
        processing = 0;
      });
      _setState(() {
        processing = 0;
      });
      Navigator.pop(context);
      Navigator.pop(context);

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
    setState(() {
      user_id = user_id;
    });
  }

}