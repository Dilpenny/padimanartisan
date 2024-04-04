//import 'dart:html';

import 'dart:convert';
import 'package:focus_detector/focus_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/map/.env.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../browser.dart';
import 'add_asset.dart';
import 'asset-detail.dart';
import 'car_for_hire_detail.dart';
import '../helpers/car_hire.dart';
import '../fragments/reply_message.dart';
import '../helpers/components.dart';
import '../helpers/customer.dart';
import '../helpers/session.dart';

class CarHirePage extends StatefulWidget {
  const CarHirePage({Key? key}) : super(key: key);
  @override
  CarHirePageWidget createState() => CarHirePageWidget();
}

class CarHirePageWidget extends State<CarHirePage> {
  int page = 1;
  int processing = 0;
  int total = 0;
  int logged_in = 41900000;
  int current_total = 20;
  int stage = 1;
  int user_id = 0;
  String pageTitle = 'Hire';
  String searching = '';
  String selectedCategory = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
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
                Text(' ${holdingObj?.model!}' ?? '', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                const SizedBox(width: 20,),
                Text('Equipment ID:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.id! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(height: 1,),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Location:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.country! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
                (holdingObj?.state != null) ? Text(' ${holdingObj?.state}' ?? '', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),) : SizedBox(),
                Text(' ${holdingObj?.area!}' ?? '', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Plate number:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.plate_number! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Chassis number:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.chassis_number! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 10,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text('Price:', style: GoogleFonts.quicksand(fontSize: 14, color: mutedColor),),
                Text(holdingObj?.price_per_day! ?? '', style: GoogleFonts.quicksand(fontSize: 14),),
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
                        String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return MyBrowser(title: 'Chat With Agent', link: url,);
                        }));
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

  CarHire? holdingObj;

  Widget equipmentDetail(){
    return SlidingUpPanel(
      minHeight: 0,
      controller: detailed_pc,
      panel: detailedScreen(),
      onPanelClosed: (){
        // detailed_pc.hide();
      },
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Find a suitable item for your usage',
                  style: GoogleFonts.quicksand(fontSize: 18), textAlign: TextAlign.center,)
              ],
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    stage = 1;
                    pageTitle = 'Hire';
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.keyboard_arrow_left, color: secondaryColor),
                    Text('All Categories', style: TextStyle(color: secondaryColor),)
                  ],
                )
            ),
            Container(
                padding: const EdgeInsets.all(20),
                child: searchBar()
            ),
            FutureBuilder<List<CarHire>>(
              future: (page == 1) ? allCars : null,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<CarHire>? data = snapshot.data;
                  if(data!.isEmpty){
                    return Center(child: Chip(label: Text('No $selectedCategory found',)));
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

                                List<CarHire> lists = jsonResponse.map((job) => CarHire.fromJson(job)).toList();
                                // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                                // Activities value = new Activities.fromJson(values);
                                for(int i = 0; i < lists.length; i++){
                                  // data.add(lists);
                                  CarHire activity = CarHire(
                                    chassis_number:lists[i].chassis_number,
                                    plate_number: lists[i].plate_number,
                                    name: lists[i].name,
                                    country: lists[i].country,
                                    model: lists[i].model,
                                    photo:lists[i].photo,
                                    price_per_day:lists[i].price_per_day,
                                    price_per_hour:lists[i].price_per_hour,
                                    price_per_month:lists[i].price_per_month,
                                    price_per_week:lists[i].price_per_week,
                                    price_with_driver:lists[i].price_with_driver,
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
      ),
      borderRadius: radius,
    );
  }

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
        setState(() {
          stage = 1;
        });
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
          title: Text(pageTitle),
        ),

        backgroundColor: whiteColor,
        body: Container(
            color: whiteColor,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10),
            height: screen_height,
            child: (stage == 1) ? ListView(
              children: [
                for(int counter = 0; counter < HIRE_CATEGORIES.length; counter++)  category(HIRE_CATEGORIES[counter]),
              ],
            ) : equipmentDetail()
        ),
      ),
    );
  }

  Widget category(String title){
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 20),),
      trailing: Icon(Icons.chevron_right),
      onTap: (){
        setState(() {
          stage = 2;
          selectedCategory = title;
          pageTitle = 'All '+title;
        });
        allCars = _fetchJobs(title.toLowerCase());
      },
    );
  }

  late Future<List<CarHire>> allCars;

  @override
  void initState() {
    // TODO: implement initState
    firstThings();
    // detailed_pc.close();
    super.initState();
  }

  Future<List<CarHire>> _fetchJobs(String type) async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/available_cars?type=$type';

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
        jsonResponse = jsonResponses['cars']['data'];
        setState(() {
          total = int.parse(jsonResponses['cars']['total'].toString());
        });
        return jsonResponse.map((job) => CarHire.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

  GestureDetector eachAsset(CarHire carObj){
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
            child: Image.network(carObj.photo!,),
          ),
          Text(carObj.name!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
          const SizedBox(height: 5,),
          Text.rich(
              TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '(${carObj.model!})',
                      style: const TextStyle(color: Color.fromRGBO(71, 196, 78, 1), fontSize: 12),
                    )
                  ]
              )
          )
        ],
      ),
      onTap: (){
        setState(() {
          holdingObj = carObj;
        });
        detailed_pc.show();
        detailed_pc.open();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => CarForHireDetailPage(
        //       carObj: carObj,
        //     ),
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
            allCars = _fetchJobs(selectedCategory);
          },
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.grey.shade900),
            prefixIcon: Icon(Icons.search,color: Colors.grey.shade900, size: 20,),
            filled: true,
            fillColor: Colors.grey.shade300,
            contentPadding: const EdgeInsets.all(8),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
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