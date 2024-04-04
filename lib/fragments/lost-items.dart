//import 'dart:html';

import 'dart:convert';
import 'package:focus_detector/focus_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/add-lost-item.dart';
import 'package:padimanartisan/fragments/lost-detail.dart';
import 'package:padimanartisan/models/lost-found.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../browser.dart';
import '../map/.env.dart';
import 'add_asset.dart';
import 'asset-detail.dart';
import '../fragments/reply_message.dart';
import '../helpers/components.dart';
import '../helpers/customer.dart';
import '../helpers/session.dart';

class LostItemsPage extends StatefulWidget {
  const LostItemsPage({Key? key}) : super(key: key);
  @override
  LostItemsPageWidget createState() => LostItemsPageWidget();
}

class LostItemsPageWidget extends State<LostItemsPage> {
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
        lostItems = _fetchJobs();
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
          title: const Text('Lost & Found'),
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
                        builder: (BuildContext context) => const AddLostItemPage(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add, color: darkColor,
                  ),
                )
            ),
          ],
        ),
        backgroundColor: whiteColor,
        body: equipmentDetail(),
      ),
    );
  }

  late Future<List<LostItem>> lostItems;

  @override
  void initState() {
    // TODO: implement initState
    lostItems = _fetchJobs();
    firstThings();
    super.initState();
  }

  Future<List<LostItem>> _fetchJobs() async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/lost/items';
      // String basicUrl = '${Component().API}mobile/lost/items?user_id=$userId';

      if(searching.isNotEmpty){
        basicUrl = '$basicUrl?search=$searching';
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
        jsonResponse = jsonResponses['items']['data'];
        setState(() {
          total = int.parse(jsonResponses['items']['total'].toString());
        });
        return jsonResponse.map((job) => LostItem.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

  GestureDetector eachAsset(LostItem assetObj){
    String model = assetObj.type!;
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: whiteColor,
          boxShadow: [
            BoxShadow(color: defaultColor, spreadRadius: 3,),
          ],
        ),
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
              child: Image.network(assetObj.photo!,),
            ),
            Text(model.substring(0, 1).toUpperCase()+model.substring(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
            const SizedBox(height: 5,),
            Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 12),
                  text: "${assetObj.identity!} ",
                )
            )
          ],
        ),
      ),
      onTap: (){
        setState(() {
          holdingObj = assetObj;
        });
        detailed_pc.show();
        detailed_pc.open();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => LostItemDetailPage(lostItemObj: assetObj),
        //   ),
        // );
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
            lostItems = _fetchJobs();
          },
          decoration: InputDecoration(
            hintText: "Search IMEI, Chassis, etc..",
            hintStyle: TextStyle(color: Colors.grey.shade900),
            suffixIcon: const Material(
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
            filled: true,
            fillColor: Colors.grey.shade300,
            // contentPadding: const EdgeInsets.all(8),
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

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  PanelController detailed_pc = PanelController();

  Widget detailedScreen(){
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: CircleAvatar(
                    radius: 48, // Image radius
                    backgroundImage: NetworkImage(holdingObj?.photo! ?? ''),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 30,
                  child: Image.asset('graphics/call-hire-equipment.png'),
                ),
                SizedBox(width: 10,),
                OutlinedButton(
                  child: Text('Contact center',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: secondaryColor),),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    side: BorderSide(color: secondaryColor, width: 2),
                  ),
                  onPressed: () {
                    String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return MyBrowser(title: 'Chat With Agent', link: url,);
                    }));
                  },
                ),
                SizedBox(width: 30,),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text(holdingObj?.name! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
                Text(' ${holdingObj?.description!}' ?? '', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                const SizedBox(width: 20,),
                Text('Item ID:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.id! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(height: 1,),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Date:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.date! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Identity:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.identity! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Type:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.type! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                      child: Text('Cancel',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: secondaryColor),),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(40))),
                        side: BorderSide(color: secondaryColor, width: 2),
                      ),
                      onPressed: () {
                        setState(() {
                          holdingObj = null;
                        });
                        // detailed_pc.show();
                        detailed_pc.close();
                      },
                    )
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {

                    },
                    child: Text('Confirm', style:
                    GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.w600),),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  LostItem? holdingObj;

  Widget equipmentDetail(){
    return SlidingUpPanel(
      minHeight: 0,
      controller: detailed_pc,
      panel: detailedScreen(),
      onPanelClosed: (){
        // detailed_pc.hide();
      },
      body: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10),
          // height: screen_height,
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
                    padding: const EdgeInsets.all(20),
                    child: searchBar()
                ),
                FutureBuilder<List<LostItem>>(
                  future: (page == 1) ? lostItems : null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<LostItem>? data = snapshot.data;
                      if(data!.isEmpty){
                        return  const Center(child: Chip(label: Text('No item yet',)));
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

                                    List<LostItem> lists = jsonResponse.map((job) => LostItem.fromJson(job)).toList();
                                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                                    // Activities value = new Activities.fromJson(values);
                                    for(int i = 0; i < lists.length; i++){
                                      // data.add(lists);
                                      LostItem activity = LostItem(
                                        type:lists[i].type,
                                        photo: lists[i].photo,
                                        date: lists[i].date,
                                        description:lists[i].description,
                                        name:lists[i].name,
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
      borderRadius: radius,
    );
  }

  GridView _jobsListView(data, BuildContext context) {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: total,
      itemBuilder: (ctx, index) {
        return eachAsset(data[index]);
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