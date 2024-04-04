//import 'dart:html';

import 'dart:convert';
import 'package:focus_detector/focus_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/profile.dart';
import 'package:padimanartisan/map/.env.dart';
import 'add_asset.dart';
import 'asset-detail.dart';
import '../fragments/reply_message.dart';
import '../helpers/components.dart';
import '../helpers/asset.dart';
import '../helpers/customer.dart';
import '../helpers/session.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({Key? key}) : super(key: key);
  @override
  AssetsPageWidget createState() => AssetsPageWidget();
}

class AssetsPageWidget extends State<AssetsPage> {
  int page = 1;
  int processing = 0;
  int total = 0;
  int logged_in = 41900000;
  int current_total = 20;
  int user_id = 0;
  String searching = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height - 100;
    return FocusDetector(
        onFocusLost: () {

        },
        onFocusGained: () {
          setState(() {

          });
        },
        onVisibilityLost: () {

        },
        onVisibilityGained: () {
          allAssets = _fetchJobs();
        },
        onForegroundLost: () {

        },
        onForegroundGained: () {

        },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor : whiteColor,
          foregroundColor : darkColor,
          elevation: 0,
          title: Text('My assets', style: GoogleFonts.quicksand()),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    int userId = 0;
                    // var session = FlutterSession();
                    // userId = await session.getInt('id');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const AddAssetPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add, color: darkColor, size: 20,
                      ),
                      Text('Add asset', style: GoogleFonts.quicksand(),)
                    ],
                  ),
                )
            ),
          ],
        ),
        backgroundColor: whiteColor,
        body: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Wrap(
                    children: [
                      Text('Keep up with requests from users on this page',
                        style: GoogleFonts.quicksand(),)
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(20),
                    child: searchBar()
                ),
                FutureBuilder<List<CustomerAsset>>(
                  future: (page == 1) ? allAssets : null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<CustomerAsset>? data = snapshot.data;
                      if(data!.isEmpty){
                        return  Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  child: Image.asset('graphics/no-asset.png'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40, right: 40),
                                  child: Text(
                                    'Simply out fill out a little information to add assets of your choice.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(),
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                SizedBox(
                                  width: 200,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        backgroundColor: secondaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(40),
                                        ),
                                      ),
                                      onPressed: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text('Get started ', style:
                                          GoogleFonts.quicksand(color: whiteColor),),
                                          Icon(Icons.arrow_forward, color: whiteColor, size: 15,)
                                        ],
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                      )
                                  ),
                                )
                              ],
                            )
                        );
                      }
                      return Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
                          child: Column(
                            children: [
                              _jobsListView(data, context),
                              (current_total < total) ? TextButton(
                                onPressed: () async {
                                  Component().default_toast("Please wait...");
                                  setState(() {
                                    page = page + 1;
                                  });
                                  var session = FlutterSession();
                                  int userId = await session.getInt('id');
                                  var url = Uri.parse('${Component().API}mobile/api/riders?rider_id=$userId');
                                  final response = await http.get(url);

                                  if (response.statusCode == 200) {
                                    var jsonResponses = json.decode(response.body);
                                    if(jsonResponses == null){
                                      // return [];
                                      // return Center(child: Chip(label: Text('No data found',)));
                                    }
                                    List jsonResponse = jsonResponses['riders']['data'];

                                    List<CustomerAsset> lists = jsonResponse.map((job) => CustomerAsset.fromJson(job)).toList();
                                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                                    // Activities value = new Activities.fromJson(values);
                                    for(int i = 0; i < lists.length; i++){
                                      // data.add(lists);
                                      CustomerAsset activity = CustomerAsset(
                                        chassis_number:lists[i].chassis_number,
                                        plate_number: lists[i].plate_number,
                                        model: lists[i].model,
                                        year:lists[i].year,
                                        color:lists[i].color,
                                        photo3:lists[i].photo3,
                                        photo1:lists[i].photo1,
                                        photo2:lists[i].photo2,
                                        id:lists[i].id,
                                        slug:lists[i].slug,
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
                          )
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return const Center(child: Chip(label: Text('No or Bad internet connection',)));
                    }
                    return Center(
                        child:Component().line_loading()
                    );
                  },
                )
              ],
            ),
          )
        ),
      ),
      );
  }

  late Future<List<CustomerAsset>> allAssets;

  @override
  void initState() {
    // TODO: implement initState
    allAssets = _fetchJobs();
    firstThings();
    super.initState();
  }

  Future<List<CustomerAsset>> _fetchJobs() async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/my/assets?user_id=$userId';

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
        print(jsonResponses.toString());
        List jsonResponse;
        jsonResponse = jsonResponses['assets']['data'];
        setState(() {
          total = int.parse(jsonResponses['assets']['total'].toString());
        });
        return jsonResponse.map((job) => CustomerAsset.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

  GestureDetector eachAsset(CustomerAsset assetObj){
    String model = assetObj.model!;
    return GestureDetector(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 88.0,
            margin: const EdgeInsets.only(
              // top: 24.0,
              // left: 20,
              bottom: 10.0,
            ),
            // clipBehavior: Clip.antiAlias,
            // decoration: const BoxDecoration(
            //   color: Colors.black26,
            //   shape: BoxShape.rectangle,
            // ),
            child: Image.network(assetObj.photo1!,),
          ),
          Text(model.substring(0, 1).toUpperCase()+model.substring(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
          const SizedBox(height: 5,),
          Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                  text: "${assetObj.year!} ",
                  children: <InlineSpan>[
                    TextSpan(
                      text: '(${assetObj.plate_number!})',
                      style: const TextStyle(color: Color.fromRGBO(71, 196, 78, 1), fontSize: 12),
                    )
                  ]
              )
          )
        ],
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AssetDetailPage(
              assetObj: assetObj,
            ),
          ),
        );
      },
    );
  }

  Form searchBar(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 16,left: 0,right: 0),
        child: TextFormField(
          controller: searchController,
          onChanged: (String search){
            setState(() {
              searching = search;
            });
            allAssets = _fetchJobs();
          },
          decoration: InputDecoration(
            hintText: "Type in name of the car....",
            hintStyle: TextStyle(color: Colors.grey.shade900),
            prefixIcon: Icon(Icons.search,color: Colors.grey.shade900, size: 20,),
            filled: true,
            fillColor: Colors.grey.shade300,suffixIcon: const Material(
              elevation: 5.0,
              color: secondaryColor,
              shadowColor: secondaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
              child: Icon(Icons.search, color: Colors.white),
            ),
            contentPadding:
            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                    color: Colors.grey.shade100
                )
            ),
          ),
        ),
      ),
    );
  }

  GridView _jobsListView(data, BuildContext context) {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: total,
      itemBuilder: (ctx, index) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: eachAsset(data[index]),
        );
      }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: 0.0,
      mainAxisSpacing: 2,
      mainAxisExtent: 154,
    ),
    );
  }

  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    setState(() {
      user_id = user_id;
    });
  }

}