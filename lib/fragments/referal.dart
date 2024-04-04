import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padimanartisan/fragments/my_location.dart';
import 'package:padimanartisan/helpers/components.dart';
import '../auth/change-password.dart';
import '../helpers/affiliates.dart';
import '../helpers/session.dart';
import '../map/.env.dart';
import 'package:http/http.dart' as http;

class ReferalScreen extends StatefulWidget {
  final referalCode;

  const ReferalScreen({super.key, required this.referalCode});
  @override
  ReferalScreenState createState() => ReferalScreenState(referalCode);
}

class ReferalScreenState extends State<ReferalScreen> {
  final referalCode;

  ReferalScreenState(this.referalCode);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        elevation: 0,
        backgroundColor: whiteColor,
        title: Text('Referral program', style: GoogleFonts.quicksand(color: darkColor),),
      ),
      backgroundColor: whiteColor,
      body: body(),
    );
  }

  Widget body(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("graphics/dashboard-bg.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Referral Link:'.toUpperCase()),
            Chip(label: Text('${Component().API}/register/'+referalCode)),
            Row(
              children: [
                Wrap(
                  children: [
                    Text('Used for web signups',
                      style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),)
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 40,
                  child: TextButton(
                      onPressed: (){

                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(5),
                      ),
                      child: Row(
                        children: [
                          Text('Copy', style: TextStyle(color: secondaryColor),),
                          Icon(Icons.copy, size: 20, color: secondaryColor,)
                        ],
                      )
                  ),
                )
              ],
            ),
            Divider(height: 1,),
            Text('Referral CODE:'.toUpperCase()),
            Chip(label: Text(referalCode, style: TextStyle(fontSize: 20),)),
            Row(
              children: [
                Wrap(
                  children: [
                    Text('Used for mobile signups',
                      style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),)
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 40,
                  child: TextButton(
                      onPressed: (){

                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(5),
                      ),
                      child: Row(
                        children: [
                          Text('Copy', style: TextStyle(color: secondaryColor),),
                          Icon(Icons.copy, size: 20, color: secondaryColor,)
                        ],
                      )
                  ),
                )
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(height: 0.5,),
            const SizedBox(height: 5,),
            projectWidget()
          ],
        ),
      ),
    );
  }

  Widget projectWidget() {
    return FutureBuilder<List<Affiliate>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }else if(snapshot.hasData){
          List<Affiliate>? data = snapshot.data;
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

                  String basicUrl = '${Component().API}account/logs?user_id=$user_id&page=$page';
                  var url = Uri.parse(basicUrl);
                  final response = await http.get(url);

                  if (response.statusCode == 200) {
                    var jsonResponses = json.decode(response.body);
                    if(jsonResponses == null){
                      // return [];
                      // return Center(child: Chip(label: Text('No data found',)));
                    }
                    List jsonResponse = jsonResponses['history']['data'];

                    List<Affiliate> lists = jsonResponse.map((job) => Affiliate.fromJson(job)).toList();
                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                    // Activities value = new Activities.fromJson(values);
                    for(int i = 0; i < lists.length; i++){
                      // data.add(lists);
                      Affiliate activity = Affiliate(
                          name: lists[i].name,
                          date: lists[i].date,
                      );
                      data.add(activity);
                    }

                    setState(() {
                      current_total = data.length;
                    });
                  };
                },
                child: const Text('Load more', style: TextStyle(color: const Color.fromRGBO(7, 84, 40, 1)),),
              ) : const SizedBox(),
            ],
          );
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return const Center(child: Chip(label: Text('No or Bad internet connection',)));
        }
        return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Component().line_loading(),
            )
        );
      },
      future: (page == 1) ? history : null,
    );
  }

  int current_total = 20;
  int page = 1;

  Widget list(obj){
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: defaultColor,
        ),
        child: ListTile(
          leading: Image.asset('graphics/notification.png', width: 30,),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(obj.name,style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold),),
              Wrap(
                children: [
                  // Text(obj.date, style: GoogleFonts.quicksand(fontSize: 16),)
                ],
              )
            ],
          ),
        )
    );
  }

  late Future<List<Affiliate>> history;

  int user_id = 0;

  Future<List<Affiliate>> _fetchJobs() async {
    try{
      var session = FlutterSession();
      user_id = await session.getInt('id');
      setState(() {
        user_id = user_id;
      });
      String basicUrl = '${Component().API}mobile/fetch/affiliates?user_id=${user_id.toString()}';
      var url = Uri.parse(basicUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponses = json.decode(response.body);
        print('===============================');
        print(jsonResponses);
        print('===============================');
        if(jsonResponses == null){
          // return [];
          // return Center(child: Chip(label: Text('No data found',)));
        }
        List jsonResponse = jsonResponses['affiliates']['data'];
        setState(() {
          total = int.parse(jsonResponses['affiliates']['total'].toString());
        });

        print('===============$jsonResponse');
        return jsonResponse.map((job) => Affiliate.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load rooms from API');
      }
    }on Exception{
      return [];
    }
  }

  int total = 0;

  @override
  void initState() {
    history = _fetchJobs();
    // TODO: implement initState
    super.initState();
  }
}