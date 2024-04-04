import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:padimanartisan/fragments/help.dart';
import 'package:padimanartisan/map/.env.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'auth/bank-details.dart';
import 'fragments/CarForHire.dart';
import 'fragments/account_log.dart';
import 'fragments/hire_artisan.dart';
import 'fragments/my_location.dart';
import 'fragments/receive_request.dart';
import 'fragments/requests.dart';
import 'fragments/assets.dart';
import 'fragments/wallet_history.dart';
import 'fragments/withdraw.dart';
import 'helpers/banner.dart';
import 'drawer/drawer.dart';
import 'helpers/components.dart';
import 'helpers/customer.dart';
import 'helpers/request.dart';
import 'helpers/session.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

AudioPlayer player = AudioPlayer();

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
  print("Home page ********************************** message recieved!!!!!!!!!!!!: "+message.notification!.title.toString());
  String audioasset = "audio/1.mpeg";

  if(message.data['new_request'] != null) {
    try{
      ReceivePort receiver = ReceivePort();
      IsolateNameServer.registerPortWithName(receiver.sendPort, 'myUniquePortName');
      receiver.listen((message) async {
        if (message == "stop") {
          await FlutterRingtonePlayer.stop();
        }
      });
      FlutterRingtonePlayer.play(fromAsset: "audio/1.mpeg");

      CallEvent callEvent = CallEvent(
          sessionId: message.data['request_id'].toString(),
          callType: 2,
          callerId: 25,
          callerName: message.data['name'],
          opponentsIds: {24},
          userInfo: {
            "new_request_customer_id": message.data['user_id'].toString(),
            "new_request_NAME": message.data['name'].toString(),
            "new_request_ID": message.data['request_id'].toString(),
            "new_request_IMG": message.data['sender_avatar'].toString(),
          }
        );
      ConnectycubeFlutterCallKit.showCallNotification(callEvent);
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
    }catch(error){
      Component().success_toast(error.toString());
      print('************************ '+error.toString());
    }
  }
}

void onStart(ServiceInstance service){
  // Only available for flutter 3.0.0 and later
  print('Service started....');
  DartPluginRegistrant.ensureInitialized();
  final _HomeScreenState home_screen = new _HomeScreenState();
  home_screen.update_last_seen();
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();

}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   notificationChannelId, // id
  //   'MY FOREGROUND SERVICE', // title
  //   description:
  //   'This channel is used for important notifications.', // description
  //   importance: Importance.low, // importance must be at low or higher level
  // );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      // notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
      // initialNotificationTitle: 'AWESOME SERVICE',
      // initialNotificationContent: 'Initializing',
      // foregroundServiceNotificationId: notificationId,
    ), iosConfiguration: IosConfiguration(
    // auto start service
    autoStart: true,

    // this will be executed when app is in foreground in separated isolate
    // onForeground: onStart,

    // you have to enable background fetch capability on xcode project
    // onBackground: onIosBackground,
  ),
  );
}


class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  late FirebaseMessaging _firebaseMessaging;
  late AndroidNotificationChannel channel;
  late CustomerRequest requestObj;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initPlatformState() async {
    // Get microphone permission
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone].request();
    }

  }

  String createdRequestId = '';
  String customer_id = '';
  String newCustomerImg = '';
  late StateSetter _setState;
  bool meOnline = false;
  bool hasCheckOnlineStatus = false;
  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;
  // P2PCallSession incomingCall; // the call received somewhere

  @override
  Widget build(BuildContext context) {
    if(hasCall){
      return ReceiveRequestPage(createdRequestId: createdRequestId, customer: {
        'user_id': customer_id, 'name' : newCustomerName, 'img' : newCustomerImg
      },);
    }

    return AdvancedDrawer(
      backdropColor: whiteColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: navigationDrawer(),
      child: RefreshIndicator(
          displacement: 50,
          backgroundColor: secondaryColor,
          color: whiteColor,
          strokeWidth: 3,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async {
            _fetchJobs();
          },
          child: Scaffold(

          appBar: AppBar(
            elevation: 0,
            backgroundColor: whiteColor,
            title: Text('Dashboard', style: GoogleFonts.quicksand(color: darkColor),),
            actions: [
              SizedBox(
                width: 40,
                child: FloatingActionButton(
                  heroTag: 'op1',
                    backgroundColor: mutedColorx,
                    elevation: 0,
                    onPressed: () async {
                      int userId = 0;
                      var session = FlutterSession();
                      userId = await session.getInt('id');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ActivitiesPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.notifications, color: darkColor,
                    ),
                  )
              ),
              (isArtisan == '1')
                  ?
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        processingOnlineOffline = false;
                      });
                      int userId = 0;
                      var session = FlutterSession();
                      userId = await session.getInt('id');
                      setState(() {
                        processingOnlineOffline = false;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(  // You need this, notice the parameters below:
                              builder: (BuildContext context, StateSetter setState)
                              {
                                _setState = setState;
                                return AlertDialog(
                                  title: Text('Large opportunities'.toUpperCase(), textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, //fontWeight: FontWeight.bold,
                                          color: secondaryColor)),
                                  content: SingleChildScrollView(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(
                                            image: AssetImage("graphics/dashboard-bg.png"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white,
                                        ),
                                      child: Column(
                                        children: [
                                          (processingOnlineOffline) ? SizedBox(height: 30,) : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: StadiumBorder(),
                                                  padding: EdgeInsets.all(20),
                                                  backgroundColor: (meOnline) ? Colors.green : Colors.red
                                              ),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: Text((meOnline) ? 'Stay Online' : 'Stay Offline')
                                          ),
                                          const SizedBox(height: 20,),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: StadiumBorder(),
                                                  padding: EdgeInsets.all(20),
                                                  backgroundColor: (!meOnline) ? Colors.green : Colors.red
                                              ),
                                              onPressed: () async {
                                                _setState(() {
                                                  processingOnlineOffline = true;
                                                });
                                                setState(() {
                                                  processingOnlineOffline = true;
                                                });
                                                if(meOnline){
                                                  await go_offline_online('0');
                                                }else{
                                                  await go_offline_online('1');
                                                }

                                              },
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text((!meOnline) ? 'Go Online ' : 'Go Offline '),
                                                  (processingOnlineOffline) ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: whiteColor,),) : SizedBox()
                                                ],
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Text((!hasCheckOnlineStatus) ? 'Please wait...' : (meOnline) ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: secondaryColor),),
                      ],
                    ),
                  )
              )
                  :
              const SizedBox(width: 20,),
            ],
            leading: SizedBox(
              width: 40,
              child: FloatingActionButton(
                heroTag: 'op2',
                elevation: 0,
                backgroundColor: mutedColorx,
                onPressed: _handleMenuButtonPressed,
                child: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _advancedDrawerController,
                  builder: (_, value, __) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        value.visible ? Icons.clear : Icons.menu,
                        key: ValueKey<bool>(value.visible),
                        color: secondaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          backgroundColor: whiteColor,
          body: body(),
          floatingActionButton: FloatingActionButton(
            heroTag: 'op3',
            child: Icon(Icons.help, size: 45,),
            backgroundColor: darkColor,
            foregroundColor: whiteColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen(),
                ),
              );
            },
          ),
        ),
      )
    );
  }

  bool canSeeBalance = false;

  String firstname = 'John Doe';
  List<String> titles = ['Wallet Balance','Total Deliveries', 'Pending Deliveries', 'Completed Deliveries'];
  List<String> values = ['', '', '', ''];
  List<String> img = ['card', 'truck', 'loss', 'car'];
  Widget body(){
    double screen_height = MediaQuery.of(context).size.height - 100;
    double wallet_holder_width = 100;
    if(wallet_balance.length > 13){
      wallet_holder_width = 120;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20,),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            (my_country == '---' || my_country.isEmpty || my_country == 'null') ? Container(
              color: mutedColorx,
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Text('Recommended $my_country', style: GoogleFonts.quicksand(fontSize: 16, color: darkColor),),
                  const SizedBox(height: 5,),
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyLocationPage(),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (isArtisan == '1')
                              ?
                          Text('Set location to start getting requests ', style: GoogleFonts.quicksand(fontSize: 14, color: errorColor),)
                              :
                          Text('Set location to start making requests ', style: GoogleFonts.quicksand(fontSize: 14, color: errorColor),),
                          Icon(Icons.chevron_right, color: errorColor,)
                        ],
                      )
                  )
                ],
              ),
            ) : const SizedBox(),
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 0, right: 20, left: 20),
              child: Row(
                children: [
                  Text('Your Balance', style: GoogleFonts.quicksand(),),
                  Spacer(),
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => BankDataPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text('Add Bank ', style: GoogleFonts.quicksand(color: darkColor)),
                          Icon(Icons.add_circle_outlined, color: disabledColor,)
                        ],
                      )
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("graphics/dashboard.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.only(bottom: 20, top: 20, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Total balance ', style: TextStyle(fontSize: 15, color: whiteColor, //fontWeight: FontWeight.bold
                      ),),
                      IconButton(
                        onPressed: (){
                          if(canSeeBalance){
                            setState(() {
                              canSeeBalance = false;
                            });
                          }else{
                            setState(() {
                              canSeeBalance = true;
                            });
                          }
                        },
                        icon: Icon((canSeeBalance) ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined, color: whiteColor, size: 20,),
                      ),
                      const Spacer(),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.rss_feed, color: whiteColor,),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  (canSeeBalance) ? Text('₦$wallet_balance', style: TextStyle(
                    color: whiteColor, fontSize: 30,
                    //fontWeight: FontWeight.bold
                  ),
                  ) : Row(
                    children: [
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                      Icon(Icons.emergency_rounded, color: whiteColor,),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        children: [
                          Text(firstname, style:
                          GoogleFonts.quicksand(color: whiteColor, fontSize: 20),)
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => WalletHistoryPage(),
                        ),
                      );
                    },
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: mutedColorx,
                          radius: 20,
                          child: Icon(Icons.account_balance_wallet, size: 20, color: mutedColor,),
                        ),
                        const SizedBox(height: 6,),
                        Text('Add funds ', style: GoogleFonts.quicksand(color: darkColor)),
                      ],
                    )
                ),
                const SizedBox(width: 20,),
                TextButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => WithdrawPage(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: mutedColorx,
                          radius: 20,
                          child: Icon(Icons.print_rounded, size: 20, color: mutedColor,),
                        ),
                        SizedBox(height: 6,),
                        Text('Withdraw ', style: GoogleFonts.quicksand(color: darkColor)),
                      ],
                    )
                )
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 0, right: 0, top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.only(bottom: 10, top: 10, left: 0, right: 0),
              child: Column(
                children: [
                  (imgList.length > 0) ? slider() : const SizedBox(),
                  
                  // const SizedBox(height: 10,),
                  const Text('Hire cars instantly', style: TextStyle(fontSize: 20, color: Colors.white, //fontWeight: FontWeight.bold
                  ),),
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => CarHirePage(),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Hire cars, buses, trucks etc for your usage', style: GoogleFonts.quicksand(fontSize: 15, color: basicColor),),
                          Icon(Icons.keyboard_arrow_right, color: basicColor, size: 20,)
                        ],
                      )
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
                height: screen_height,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("graphics/dashboard-bg.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Text('Welcome $firstname', style: GoogleFonts.abel(fontSize: 16,
                    //   fontWeight: FontWeight.bold, color: Colors.black54,),),
                    (fetchingDashboard == 1) ? Component().line_loading() :
                    Column(
                      children: [
                        heading('Activity', 1),
                        (requests.length == 0) ? Center(
                          child: Text('No requests found', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black45),),
                        ) :
                        Column(
                          children: [
                            for(int i = 0; i < requests.length; i++)
                              actions(null, requests[i]['service']+'(By ${requests[i]['user']['name']})',
                                  '${requests[i]['time_ago']}', 1, requests[i]),
                          ],
                        )
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: defaultColor,
                      ),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Image.asset('graphics/request.png', width: 25,),
                          SizedBox(width: 20,),
                          Text.rich(
                              TextSpan(
                                  text: 'Recent Requests',
                                  style: GoogleFonts.quicksand(color: mutedColor),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '  (11)',
                                      style: TextStyle(color: darkColor),
                                    )
                                  ]
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget slider(){
    return CarouselSlider.builder(
      itemCount: imgList.length,
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

                },
                child: Stack(
                  children: [
                    (imgList[index] == null || imgList[index] == 'null') ? SizedBox() : ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(imgList[index], fit: BoxFit.cover, width: 1000),
                    ),
                  ],
                ),
              )
          ),
        );
      },
    );
  }

  Widget heading(String title, int hasAll){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20,),
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 20, color: Colors.black, //fontWeight: FontWeight.bold
            ),),
            const Spacer(),
            TextButton(
                onPressed: (){
                  if(title.contains('ssets')){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => AssetsPage(),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => RequestsPage(),
                    ),
                  );
                },
                child: Text('View all'.toUpperCase(),
                  style: const TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 12, color: Color.fromRGBO(71, 196, 78, 1),
                  )
                )
            )
          ],
        ),
        const SizedBox(height: 10,),
      ],
    );
  }

  Widget actions(page, String? title, String description, int isRequest, var obj){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){
            return;
          },
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!.substring(0, 1).toUpperCase()+title.substring(1)),
                  const SizedBox(height: 2,),
                  (description.isEmpty) ? const SizedBox() : Text(description, style: const TextStyle(fontSize: 10, color: Colors.black54),),
                ],
              ),
              const Spacer(),
              const Icon(Icons.keyboard_double_arrow_right_outlined, color: Color.fromRGBO(71, 196, 78, 0.4),)
            ],
          ),
        ),
        const SizedBox(height: 10,),
        const Divider(height: 0.5, color: Colors.black26,),
        const SizedBox(height: 10,),
      ],
    );
  }

  int user_id = 0;
  late Future<List<Banners>> app_banners;
  int total = 0;
  int fetchingDashboard = 1;
  int totalArtisans = 0;
  String walletBalance = '0.00';
  int total_deliveries = 0;
  int completed_deliveries = 0;
  int pending_deliveries = 0;
  String wallet_balance = '0.00';

  List<String> imgList = [];
  List<String> imgCaptions = [
    'Welcome to Raeda Express'
  ];
  late List assets;
  late List requests;

  Future _fetchJobs() async {
    try{
      Future<void> _onCallAccepted(CallEvent callEvent) async {
        IsolateNameServer.lookupPortByName(portName)?.send("stop");
        Component().success_toast('Request Accepted!!');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Connecting...',
              style: TextStyle(color: secondaryColor),),
            content: Row(
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: secondaryColor,),),
                const Text(' Please hold on...')
              ],
            ),
            actions: <Widget>[
            ],
          ),
        );
        await getRequestAndArtisan(callEvent.userInfo!['new_request_customer_id'], callEvent.userInfo!['new_request_ID']);
      }

      Future<void> _onCallRejected(CallEvent callEvent) async {
        IsolateNameServer.lookupPortByName(portName)?.send("stop");
        Component().success_toast('Request Rejected!!');
        declineRequest();
      }

      ConnectycubeFlutterCallKit.instance.init(
        onCallAccepted: _onCallAccepted,
        onCallRejected: _onCallRejected,
      );

      var session = FlutterSession();
      user_id = await session.getInt('id');

      var url = Uri.parse('${Component().API}mobile/artisan/dashboard?artisan_id=$user_id');
      final response = await http.get(url);
      print('$user_id=============================== homepage');
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('.......................................1');
        var jsonResponses = json.decode(response.body);
        if(jsonResponses == null){
          // return [];
          // return Center(child: Chip(label: Text('No data found',)));
        }
        print('.......................................2');
        List jsonResponse = jsonResponses['cars'];
        imgCaptions.clear();
        imgList.clear();
        if(mounted){
          setState(() {
            if(jsonResponses['user'] != null){
              wallet_balance = jsonResponses['user']['money'];
            }
            requests = jsonResponses['recent_requests']['data'];
            // totalArtisans = int.parse(jsonResponses['artisans'].toString());
            fetchingDashboard = 0;
          });
        }
        print('.......................................3');
        for(int i = 0; i < jsonResponse.length; i++){
          imgList.add(jsonResponse[i].toString());
        }
        print('.......................................4');
      } else {
        throw Exception('Failed to load activities from API');
      }
    }on Exception{
      return [];
    }
  }

  String calleeName = '';
  String incomingCallChannel = '';
  bool hasCall = false;
  bool noNeedForNewSound = false;
  String newCustomerName = '';
  //
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  final String portName = 'myUniquePortName';
  Future<void> stopAudio() async {
    IsolateNameServer.lookupPortByName(portName)?.send("stop");
    await FlutterRingtonePlayer.stop();
  }

  @override
  void initState() {
    // _requestPermissions();
    firstThings();
    _fetchJobs();
    // TODO: implement initState
    super.initState();
  }

  String slug = '';

  Future<void> save_devicetoken(String device_token) async {
    var client = http.Client();
    try {
      int user_id = 0;
      var session = FlutterSession();
      user_id = await session.getInt('id') ;
      var url = Uri.parse(Component().API+'save-push-notification-token?user_id='+user_id.toString()+"&token="+device_token);
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'token': device_token,
      });
      print(user_id.toString()+'==============================================='+device_token);

      // print('Response status: ${response.statusCode}');
    } finally {
      client.close();
    }
  }

  bool processingOnlineOffline = false;

  late Customer artisanObj;

  Future<void> getRequestAndArtisan(String? customer_id, String? new_request_id) async {
    var client = http.Client();
    try {
      var url = Uri.parse('${Component().API}mobile/get/request/and/artisan');
      var response = await http.post(url, body: {
        'user_id': customer_id,
        'request_id': new_request_id,
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
        Navigator.pop(context);
        Component().error_toast(message);
        setState(() {
          // processing = 0;
        });
        return;
      }
      print('-=====================-'+createdRequestId.toString());
      print(server_response['artisan']);
      var obj = server_response['artisan'];
      var customer_request_obj = server_response['request'];
      Component().success_toast(message);
      setState(() {
        // processing = 0;
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
          amount: customer_request_obj['amount'],
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
      // processing = 0;
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
      // decline_processing = 0;
    });
  }

  Future<void> update_last_seen() async {
    try{
      print('Updating Service started....');
      var session = FlutterSession();
      user_id = await session.getInt('id');

      var url = Uri.parse('${Component().API}mobile/update/last/seen?user_id=$user_id');
      final response = await http.get(url);
      print('$user_id===============================');
      print(hasCheckOnlineStatus.toString());
      if (response.statusCode == 200) {
        var jsonResponses = json.decode(response.body);
        print(jsonResponses);
        if(!hasCheckOnlineStatus){
          if (mounted) {
            setState(() {
              hasCheckOnlineStatus = true;
            });
            if(jsonResponses['is_online'] == '0'){
              setState(() {
                meOnline = false;
              });
            }else{
              setState(() {
                meOnline = true;
              });
            }
          };
      }

      } else {
        throw Exception('Failed to load activities from API');
      }
    }on Exception{

    }
  }

  Future<void> go_offline_online(String is_online) async {
    try{
      if(isArtisan == '0'){
        return;
      }
      var session = FlutterSession();
      user_id = await session.getInt('id');

      var url = Uri.parse('${Component().API}mobile/user/go/offline_online');
      var response = await http.post(url, body: {
        'is_online': is_online,
        'user_id': user_id.toString(),
      });
      var server_response = jsonDecode(response.body.toString());
      String status = server_response['status'].toString();
      print(server_response);
      if(is_online == "1"){
        setState(() {
          meOnline = true;
        });
        _setState(() {
          meOnline = true;
        });
        print('yes===============================');
        Component().success_toast('You are now ONLINE!');
      }else{
        setState(() {
          meOnline = false;
        });
        _setState(() {
          meOnline = false;
        });
        Component().success_toast('Ooops! You are now OFFLINE!');
        print('no===============================');
      }
      Navigator.pop(context);
      if (response.statusCode == 200) {
        var jsonResponses = json.decode(response.body);

        if(jsonResponses == null){
          // return [];
          // return Center(child: Chip(label: Text('No data found',)));
        }

      } else {
        throw Exception('Failed to load activities from API');
      }
    }on Exception{

    }
  }

  void firstThings() async {
    await initializeService();
    var session2 = FlutterSession();
    String has_new_message = await session2.get('has_new_message');
    if(has_new_message == 'true'){
      String new_request_customer_id = await session2.get('new_request_customer_id');
      String new_request_ID = await session2.get('new_request_ID');
      String new_request_IMG = await session2.get('new_request_IMG');
      String new_request_NAME = await session2.get('new_request_NAME');
      customer_id = new_request_customer_id;
      setState(() {
        createdRequestId = new_request_ID;
        newCustomerImg = new_request_IMG;
        newCustomerName = new_request_NAME;
        hasCall = true;
      });
    }
    /// request overlay permission
    /// it will open the overlay settings page and return `true` once the permission granted.
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((value){
      print('Token: '+value.toString());
      save_devicetoken(value.toString()); // SAVE DEVICE TOKEN
    });
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("Home page ============ +++++++++++++++++ received");
      String notificationTitle = event.notification!.title.toString();
      print(event.data);
      print("Home page ============ -----------------");
      if(event.data['new_request'] != null){
        customer_id = event.data['user_id'].toString();
        if (!mounted) return;
        setState(() {
          createdRequestId = event.data['request_id'].toString();
          newCustomerImg = event.data['sender_avatar'].toString();
          newCustomerName = event.data['name'];
          hasCall = true;
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
      print('HOMEPAGE ********************************** Message clicked!');
      String notificationTitle = message.notification!.title.toString();
      String notificationMessage = message.notification!.body.toString();
      await player.stop();
      if(message.data['new_request'] != null){
        customer_id = message.data['user_id'].toString();
        setState((){
          createdRequestId = message.data['request_id'].toString();
          newCustomerImg = message.data['sender_avatar'].toString();
          newCustomerName = message.data['name'];
          hasCall = true;
          noNeedForNewSound = true;
        });
      }
      if(notificationMessage.toLowerCase().contains('customer has accepted your stated price')){
        // notificationTitle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RequestsPage(tag: notificationTitle,),
          ),
        );
      }
    });

    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "flutter_background example app",
      notificationText: "Background notification for keeping the example app running in the background",
      notificationImportance: AndroidNotificationImportance.High,
      notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);

    _fetchJobs();
    var session = FlutterSession();
    firstname = await session.get('fullname');
    slug = await session.get('slug');
    user_id = await session.getInt('id');
    isArtisan = await session.get('isArtisan');
    my_country = await session.get('country');
    if(!mounted){
      return;
    }
    setState(() {
      isArtisan = isArtisan;
      my_country = my_country;
      firstname = firstname;
      user_id = user_id;
    });

    Timer.periodic(const Duration(seconds: 15), (timer) {
      // debugPrint(timer.tick.toString());
      update_last_seen();
    });
  }
  String isArtisan = '0';
  String my_country = '---';
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}