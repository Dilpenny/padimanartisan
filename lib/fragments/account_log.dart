import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padimanartisan/map/.env.dart';
import '../helpers/account_log.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../helpers/wallet_history.dart';
import 'package:http/http.dart' as http;

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late StateSetter _setState;
  static const MINIMUM_FUND_AMOUNT = 100;

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
            fillColor: const Color.fromRGBO(149, 119, 149, 1),
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
    double screen_height = MediaQuery.of(context).size.height - 120;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text("Notifications", style: GoogleFonts.karla()),
        actions: [
        ],
      ),
      backgroundColor: whiteColor,
      body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                projectWidget(),
              ],
            )
          ),
        ),
    );
  }

  bool checkedValue = false;

  Form fundWalletView(){
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
                        icon: const Icon(Icons.monetization_on_rounded),
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
                            color: Colors.pink[50],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text("Fund  ", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                              (processing == 1) ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.pink,),) : const Icon(Icons.check_circle,color: Colors.pink,size: 20,),
                            ],
                          ),
                        ),
                        onTap: () async {
                          if (_formKey2.currentState!.validate()) {
                            // If the form is valid, display a Snackbar.
                            _setState(() {
                              processing = 1;
                            });
                            // await save_room();
                          }
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
  int current_total = 20;
  int page = 1;

  Widget projectWidget() {
    return FutureBuilder<List<ActivityHistory>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }else if(snapshot.hasData){
          List<ActivityHistory>? data = snapshot.data;
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
                    List jsonResponse = jsonResponses['history']['data'];

                    List<ActivityHistory> lists = jsonResponse.map((job) => ActivityHistory.fromJson(job)).toList();
                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                    // Activities value = new Activities.fromJson(values);
                    for(int i = 0; i < lists.length; i++){
                      // data.add(lists);
                      ActivityHistory activity = ActivityHistory(
                          name: lists[i].name,
                          time_ago:lists[i].time_ago,
                          user_id:lists[i].user_id,
                          message:lists[i].message,
                          seen:lists[i].seen,
                          id: lists[i].id
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
                Text(obj.message, style: GoogleFonts.quicksand(fontSize: 16),)
              ],
            )
          ],
        ),
      )
    );
  }

  late Future<List<ActivityHistory>> history;
  int user_id = 0;
  String searching = '';
  String walletBalance = '';
  int total = 20;
  @override
  void initState() {
    firstThings();
    // TODO: implement initState
    super.initState();
  }

  void firstThings() async {
    history = _fetchJobs();
    var session = FlutterSession();
    // user_id = await session.getInt('user_id');
    // setState(() {
    //   user_id = user_id;
    // });

  }

  Future<List<ActivityHistory>> _fetchJobs() async {
    try{
      var session = FlutterSession();
      user_id = await session.getInt('id');
      setState(() {
        user_id = user_id;
      });
      String basicUrl = '${Component().API}mobile/user/logs?user_id=${user_id.toString()}';
      if(searching.isNotEmpty){
        basicUrl = '$basicUrl&search=$searching';
      }
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
        List jsonResponse = jsonResponses['notifications']['data'];
        setState(() {
          total = int.parse(jsonResponses['notifications']['total'].toString());
        });

        print('===============$jsonResponse');
        return jsonResponse.map((job) => ActivityHistory.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load rooms from API');
      }
    }on Exception{
      return [];
    }
  }
  int processing = 0;
}