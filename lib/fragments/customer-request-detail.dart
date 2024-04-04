//import 'dart:html';

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/artisan.dart';
import '../helpers/components.dart';
import '../helpers/customer-request.dart';
import '../helpers/session.dart';
import 'customer-hire-artisan.dart';

class CustomerRequestDetailPage extends StatefulWidget {
  final requestObj;

  const CustomerRequestDetailPage({super.key, required this.requestObj});
  @override
  CustomerRequestDetailPageWidget createState() => CustomerRequestDetailPageWidget(requestObj);
}

class CustomerRequestDetailPageWidget extends State<CustomerRequestDetailPage> {
  final CustomerRequest requestObj;
  int processing = 1;
  int logged_in = 41900000;
  int user_id = 0;
  late Artisan artisanObj;
  late StateSetter _setState;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();

  CustomerRequestDetailPageWidget(this.requestObj);

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
                    // await deleteAsset();
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
          title: Text("Request detail", style: GoogleFonts.quicksand(),),
          actions: [
            PopupMenuButton<int>(
              onSelected: (item){
                if(item == 419){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(  // You need this, notice the parameters below:
                          builder: (BuildContext context, StateSetter setState)
                          {
                            _setState = setState;
                            return AlertDialog(
                              title: Wrap(
                                children: [
                                  Text('Delete this asset?'.toUpperCase(), textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red))
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: deleteAssetView(context),
                              ),
                            );
                          }
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 2, child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.green,),
                    Text(' Edit', style: TextStyle(color: Colors.green),)
                  ],
                )),
                PopupMenuItem<int>(value: 419, child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red,),
                    Text(' Delete', style: TextStyle(color: Colors.red),)
                  ],
                )),
              ],
            ),
          ]
      ),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 10),
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
            children: [
              slide(),
              const SizedBox(height: 20,),
              actions('Request ID:', requestObj.slug!, ''),
              actions('Asset Caption:', requestObj.asset_name!, ''),
              actions('Artisan:', requestObj.artisan!, ''),
              actions('Service:', requestObj.service!, ''),
              actions('Current Status:', requestObj.status!, requestObj.statusx_color!),
              actions('Date:', requestObj.time_ago!, ''),
              actions('Amount:', '₦'+requestObj.amount!, ''),
              (requestObj.status_code == "1" || requestObj.status_code == "0" || requestObj.status_code == "9" || requestObj.status_code == "10") ? SizedBox(
                width: 200,
                child: (processing == 1) ? Component().line_loading() : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      primary: Colors.yellow,
                      padding: const EdgeInsets.all(15)
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => HireArtisanPage(from: 'request-detail', artisanObj: artisanObj, requestObj: requestObj,),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('CONTINUE ', style: TextStyle(color: Color.fromRGBO(7, 84, 40, 1), fontWeight: FontWeight.bold),),
                      Icon(Icons.arrow_forward, color: Color.fromRGBO(7, 84, 40, 1), size: 20,)
                    ],
                  ),
                ),
              ) : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget slide(){
    int slideSize = 1;
    return
      CarouselSlider.builder(
        itemCount: slideSize,
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
        ),
        itemBuilder: (context, index, realIdx) {
          return Container(
            child: Center(
                child: GestureDetector(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(  // You need this, notice the parameters below:
                            builder: (BuildContext context, StateSetter setState)
                            {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Image.network(requestObj.asset_img!, fit: BoxFit.cover, width: 1000),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      Image.network(requestObj.asset_img!, fit: BoxFit.cover, width: 1000),
                    ],
                  ),
                )
            ),
          );
        },
      );
  }

  Widget actions(String? title, String value, String color){
    if(value.isEmpty || value == 'null'){
      return const SizedBox();
    }
    Color kolor = Colors.black;
    if(color.isNotEmpty){
      if(color == 'blue'){
        kolor = Colors.blue;
      }else if(color == 'orange'){
        kolor = Colors.orange;
      }else if(color == 'red'){
        kolor = Colors.red;
      }else if(color == 'green'){
        kolor = Colors.green;
      }
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
                    style: GoogleFonts.quicksand(color: Colors.black54, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                ],
              ),
              const Spacer(),
              Text(value,style: GoogleFonts.quicksand(color: kolor, fontSize: 20))
            ],
          ),
        ),
        const SizedBox(height: 20,),
        // const Divider(height: 0.5, color: Colors.black26,),
        const SizedBox(height: 20,),
      ],
    );
  }

  Future<void> getArtisan() async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/request/get/artisan');
      var response = await http.post(url, body: {
        'artisan_id': requestObj.artisan_id,
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
        _setState(() {
          processing = 0;
        });
        return;
      }
      print('-=====================-');
      print(server_response['artisan']);
      var obj = server_response['artisan'];
      Component().success_toast(message);
      setState(() {
        processing = 0;
        artisanObj = Artisan(
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
      });

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
    getArtisan();
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