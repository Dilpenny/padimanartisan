//import 'dart:html';

import 'dart:convert';
import 'package:focus_detector/focus_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:padimanartisan/fragments/profile.dart';
import 'package:padimanartisan/fragments/sent-requests.dart';
import 'package:padimanartisan/map/.env.dart';
import 'add_asset.dart';
import 'asset-detail.dart';
import 'request-details.dart';
import '../helpers/request.dart';
import '../fragments/reply_message.dart';
import '../helpers/components.dart';
import '../helpers/asset.dart';
import '../helpers/customer.dart';
import '../helpers/session.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key, this.tag}) : super(key: key);
  final tag; // fetch only this slug
  @override
  RequestsPageWidget createState() => RequestsPageWidget(tag);
}

class RequestsPageWidget extends State<RequestsPage> {
  final tag; // fetch only this slug
  int page = 1;
  int processing = 0;
  int total = 0;
  int logged_in = 41900000;
  int current_total = 20;
  int user_id = 0;
  String searching = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();

  RequestsPageWidget(this.tag);

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
        allRequests = _fetchJobs();
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
          actions: [
            (isArtisan == '1')
                ?
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SentRequestsPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Sent Requests ', style: GoogleFonts.quicksand(color: darkColor, fontSize: 14),
                    ),
                    Icon(Icons.arrow_circle_right, color: mutedColor,)
                  ],
                ),
              ),
            )
                :
            SizedBox()
          ],
          title: Text('My requests', style: GoogleFonts.quicksand()),
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
                    padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                    child: searchBar()
                ),
                FutureBuilder<List<CustomerRequest>>(
                  future: (page == 1) ? allRequests : null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<CustomerRequest>? data = snapshot.data;
                      if(data!.isEmpty){
                        return Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  child: Image.asset('graphics/no-request.png'),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 40, right: 40),
                                  child: Text(
                                    suggestHowToGetRequests,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(),
                                  ),
                                ),
                                SizedBox(height: 10,),
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

                                    List<CustomerRequest> lists = jsonResponse.map((job) => CustomerRequest.fromJson(job)).toList();
                                    // Map<String, dynamic> values = jsonResponse.map((job) => new Activities.fromJson(job)).toList();
                                    // Activities value = new Activities.fromJson(values);
                                    for(int i = 0; i < lists.length; i++){
                                      // data.add(lists);
                                      CustomerRequest activity = CustomerRequest(
                                        asset_img:lists[i].asset_img,
                                        asset_slug:lists[i].asset_slug,
                                        asset_name:lists[i].asset_name,
                                        customer: lists[i].customer,
                                        artisan_id: lists[i].artisan_id,
                                        status:lists[i].status,
                                        status_code:lists[i].status_code,
                                        service:lists[i].service,
                                        user_id:lists[i].user_id,
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
        ),
      ),
    );
  }

  Widget list(CustomerRequest obj){
    String amount = '0.00';
    bool canOpen = false;
    String asset_name = obj.asset_name!.toUpperCase().substring(0, 1)+obj.asset_name!.substring(1);
    String service = obj.service!.toUpperCase().substring(0, 1)+obj.service!.substring(1);
    Color statusColor = Colors.purpleAccent;
    Color statusBgColor = Colors.purpleAccent;
    if(obj.statusx_color == 'red'){
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
      canOpen = false;
    }else if(obj.statusx_color == 'orange'){
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
      canOpen = false;
    }else if(obj.statusx_color == 'blue'){
      canOpen = true;
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    }else if(obj.statusx_color == 'green'){
      canOpen = true;
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
    }else if(obj.statusx_color == 'yellow'){
      canOpen = false;
      statusColor = Colors.yellow;
      statusBgColor = Colors.yellow.shade50;
    }
    if(obj.amount! != 'null' && obj.amount! != null){
      amount = obj.amount!;
    }
    return GestureDetector(
      onTap: (){
        if(!canOpen){
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RequestDetailPage(requestObj: obj),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: ListTile(
          dense:true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          leading: SizedBox(
            width: 25,
            child: Image.asset('graphics/avatar.png'),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Text('${obj.customer!}',style: TextStyle(fontSize: 15,color: Colors.grey.shade600),),
                  Text('($service)',style: TextStyle(fontSize: 12,color: mutedColor),),
                ],
              ),
              const SizedBox(height: 6,),
              Text(obj.time_ago!, style: const TextStyle(fontSize: 10, color: Colors.black38),),
            ],
          ),
          trailing: Container(
            color: statusBgColor,
            padding: const EdgeInsets.all(5),
            child: Text(obj.status!, style: TextStyle(color: statusColor, fontSize: 10, fontStyle: FontStyle.italic),),
          )
        )

      ),
    );
  }

  late Future<List<CustomerRequest>> allRequests;

  @override
  void initState() {
    // TODO: implement initState
    allRequests = _fetchJobs();
    firstThings();
    super.initState();
  }

  Future<List<CustomerRequest>> _fetchJobs() async {
    try{
      var session = FlutterSession();
      int userId = await session.getInt('id');
      String basicUrl = '${Component().API}mobile/my/requests?artisan_id=$userId';

      if(tag != null && tag.isNotEmpty){
        basicUrl = '$basicUrl&tag=$tag';
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
        jsonResponse = jsonResponses['requests']['data'];
        setState(() {
          total = int.parse(jsonResponses['requests']['total'].toString());
        });
        return jsonResponse.map((job) => CustomerRequest.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load assets from API');
      }
    }on Exception{
      return [];
    }
  }

  Form searchBar(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 16,left: 0,right: 0),
        child: TextFormField(
          readOnly: (tag != null && !tag.isNotEmpty) ? false : true,
          controller: searchController,
          onChanged: (String search){
            setState(() {
              searching = search;
            });
            allRequests = _fetchJobs();
          },
          decoration: InputDecoration(
            hintText: "Type in a specific request...",
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
  String isArtisan = '0';
  void firstThings() async {
    var session = FlutterSession();
    user_id = await session.getInt('id');
    isArtisan = await session.get('isArtisan');
    setState(() {
      isArtisan = isArtisan;
      user_id = user_id;
    });

    if(tag != null && tag.isNotEmpty){
      searchController.text = tag;
    }
  }

}