import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';
import '../map/.env.dart';
import '../models/chat_message_model.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' as foundation;

class ChatDetailPage extends StatefulWidget{
  final chatee_name, chatee_img, chatee_id, request_id;

  const ChatDetailPage({Key? key, this.chatee_name, this.chatee_img, this.chatee_id, this.request_id}) : super(key: key);
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState(chatee_name, chatee_img, chatee_id, request_id);
}

class _ChatDetailPageState extends State<ChatDetailPage> with WidgetsBindingObserver{
  final TextEditingController messageBoxController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  final String chatee_name, chatee_img, chatee_id, request_id;

  String auth_id = '0';

  _ChatDetailPageState(this.chatee_name, this.chatee_img, this.chatee_id, this.request_id);
  double mySelectedFontSize = 12;
  bool viewOptions = false;

  Widget imageInMessage(String path){
    return Column(
      children: [
        Stack(
          children: [
            Align(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur( sigmaY: 4,sigmaX: 4),
                child: Image.asset(path,),
              ),
              alignment: Alignment.topCenter,
            ),
            Align(
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: (){},
                child: CircularProgressIndicator(color: Colors.green,),
              ),
              alignment: Alignment.bottomRight,
            ),
          ],
        ),
        const SizedBox(height: 5,)
      ],
    );
  }

  ListView chat_message(){
    var screenWidth;
    double screenHeight = MediaQuery.of(context).size.height;
    return  ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index){
        String chatid = messages[index].id;
        if(messages[index].photoObj != null){
          screenWidth = MediaQuery.of(context).size.width - 90;
        }else{
          screenWidth = null;
        }
        return GestureDetector(
          onTap: (){
            if(messages[index].viewingOption){
              setState(() {
                messages[index].viewingOption = false;
              });
            }else{
              setState(() {
                messages[index].viewingOption = true;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
            child: Align(
                alignment: (messages[index].messageType == "receiver" ? Alignment.topLeft:Alignment.topRight),
                child: Column(
                  children: [
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].messageType  == "receiver" ? Colors.grey.shade200 : Colors.green[50]),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (messages[index].photoObj != null) ? messages[index].photoObj! : const SizedBox(),
                          Text(messages[index].messageContent, style: GoogleFonts.quicksand(fontSize: mySelectedFontSize),),
                        ],
                      ),
                    ),
                    (messages[index].viewingOption) ?
                    IconButton(
                        splashColor: Colors.orange,
                        onPressed: () async {
                          setState((){
                            messages.removeAt(index);
                          });
                          await deleteMessage(chatid);
                        },
                        icon: Icon(Icons.delete, color: secondaryColor,)
                    )
                        : const SizedBox()
                  ],
                )
            ),
          ),
        );
      },
    );
  }

  Future deleteMessage(String chatId) async {
    String authUserId = '';
    var session = FlutterSession();
    authUserId = await session.get('user_id') ;

    var url = Uri.parse('${Component().API}delete/message');
    var response = await http.post(url, body: {
      'chat_id': chatId,
      'user_id': authUserId,
    });
    // final jsonResponse = json.decode();
    // print(response.statusCode.toString());
    var serverResponse = jsonDecode(response.body.toString());
    String status = serverResponse['status'].toString();
    status = status.replaceAll('[', '');
    status = status.replaceAll(']', '');
    String message = serverResponse['message'].toString();
    message = message.replaceAll('[', '');
    message = message.replaceAll(']', '');
    setState(() {
      // payForViewGalleryProcessing = 0;
    });
    if(status == 'error'){
      Component().error_toast(message);
      return;
    }
    setState(() {
      // noAccess = false;
      // canViewProfile = true;
    });
    print('======== ok =========');
    Component().success_toast(message);
    // galleryLoading = 1;
    // _fetchGallery();
  }

  List<ChatMessage> messages = [];

  int fetching_messages = 1;

  bool addAttachment = false;
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
    bottomLeft: Radius.circular(24.0),
    bottomRight: Radius.circular(24.0),
  );

  Stack body(){
    attachOptions = [
      documentPanelButton(),
      galleryPanelButton(),
      contactPanelButton(),
    ];
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 50),
          child: chat_message(),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.only(left: 0,bottom: 10,top: 10),
            height: 60,
            width: double.infinity,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 5,),
                Container(
                  width: 298,
                  padding: const EdgeInsets.only(right: 10, left: 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageBoxController,
                          onChanged: (text){
                            if(text.length > 0){
                              setState(() {
                                imTyping = true;
                              });
                            }else{
                              setState(() {
                                imTyping = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              hintText: "Message...",
                              hintStyle: GoogleFonts.quicksand(color: Colors.black54),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                sendButton()
              ],

            ),
          ),
        ),
      ],
    );
  }

  bool imTyping = false;

  void initializer() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Widget sendButton(){
    return FloatingActionButton(
      onPressed: () async {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
        Widget uploadProgressBar = const SizedBox();
        // if(photoObj.toString().isNotEmpty && photoObj != null){
        //   uploadProgressBar = imageInMessage(File(photoObj).path);
        uploadProgressBar = imageInMessage('graphics/button4.jpg');
        // }
        var new_outbox = ChatMessage(
            messageContent: messageBoxController.text,
            messageType: "sender",
            viewingOption: false,
            id: '1100000',
        );
        String message = messageBoxController.text;
        setState(() {
          messages.add(new_outbox);
          messageBoxController.text = '';
        });
        // START FILE UPLOAD
        await send_message(0, message);
        scrollToBottom();
      },
      backgroundColor: secondaryColor,
      elevation: 0,
      child: const Icon(Icons.send,color: Colors.white,size: 25,),
    );
  }

  Widget documentPanelButton(){
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () async {
            // await List<Contact> contacts = await ContactsService.getContacts();
          },
          backgroundColor: Colors.orange,
          elevation: 0,
          child: const Icon(Icons.file_present_rounded,color: Colors.white,size: 25,),
        ),
        const SizedBox(height: 4,),
        Text('Document', style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black54),)
      ],
    );
  }

  Widget contactPanelButton(){
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () async {
            // await List<Contact> contacts = await ContactsService.getContacts();
          },
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          child: const ImageIcon(AssetImage('graphics/account.png'), size: 25, color: Colors.white,),
        ),
        const SizedBox(height: 4,),
        Text('Contact', style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black54),)
      ],
    );
  }

  late List<Widget> attachOptions;

  Widget galleryPanelButton(){
    return
      Column(
          children: [
            FloatingActionButton(
              onPressed: () async {
                // await List<Contact> contacts = await ContactsService.getContacts();
              },
              backgroundColor: Colors.red,
              elevation: 0,
              child: const Icon(Icons.image,color: Colors.white,size: 25,),
            ),
            const SizedBox(height: 4,),
            Text('Gallery', style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black54),)
          ]
      );
  }

  bool emojiShowing = false;
  final TextEditingController emojiSearchController = TextEditingController();

  // Widget emojiPanel(){
  //   return Align(
  //     alignment: Alignment.bottomLeft,
  //     child: SlidingUpPanel(
  //       minHeight: 0,
  //       maxHeight: 200,
  //       defaultPanelState: PanelState.CLOSED,
  //       margin: const EdgeInsets.only(bottom: 52),
  //       controller: panelController2,
  //       color: Colors.transparent,
  //       panel: EmojiPicker(
  //         onEmojiSelected: (category, Emoji emoji) {
  //           // Do something when emoji is tapped (optional)
  //           messageBoxController.text = messageBoxController.text + emoji.emoji.toString();
  //         },
  //         onBackspacePressed: () {
  //           // Do something when the user taps the backspace button (optional)
  //         },
  //         textEditingController: emojiSearchController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
  //         config: Config(
  //           columns: 9,
  //           emojiSizeMax: 22 * (Platform.isIOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
  //           verticalSpacing: 0,
  //           horizontalSpacing: 0,
  //           gridPadding: EdgeInsets.zero,
  //           initCategory: Category.RECENT,
  //           bgColor: Color(0xFFF2F2F2),
  //           indicatorColor: const Color.fromRGBO(149, 119, 149, 1),
  //           iconColor: Colors.grey,
  //           iconColorSelected: const Color.fromRGBO(149, 119, 149, 1),
  //           backspaceColor: const Color.fromRGBO(149, 119, 149, 1),
  //           skinToneDialogBgColor: Colors.white,
  //           skinToneIndicatorColor: Colors.grey,
  //           enableSkinTones: true,
  //           showRecentsTab: true,
  //           recentsLimit: 28,
  //           noRecents: const Text(
  //             'No Recent',
  //             style: TextStyle(fontSize: 20, color: Colors.black26),
  //             textAlign: TextAlign.center,
  //           ), // Needs to be const Widget
  //           loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
  //           tabIndicatorAnimDuration: kTabScrollDuration,
  //           categoryIcons: const CategoryIcons(),
  //           buttonMode: ButtonMode.MATERIAL,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          foregroundColor: darkColor,
          automaticallyImplyLeading: false,
          backgroundColor: whiteColor,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: darkColor,),
                  ),
                  const SizedBox(width: 2,),
                  CircleAvatar(
                    backgroundImage: NetworkImage(chatee_img),
                    maxRadius: 20,
                  ),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(chatee_name,style: GoogleFonts.quicksand( fontSize: 16 ,fontWeight: FontWeight.w600, color: secondaryColor),),
                        const SizedBox(height: 6,),
                        Text("Online",style: GoogleFonts.quicksand(color: darkColor, fontSize: 13),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: (fetching_messages == 1) ? Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: primaryColor,
              child: const Text('All messages are MONITORED for the security of all our users.'),
            ),
            Component().line_loading()
          ],
        ) : body()
    );
  }

  var videoObj = '';
  var photoObj = '';

  Future<void> send_message(int is_room, String message) async {
    var client = http.Client();
    try {
      int user_id = 0;
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse('${Component().API}mobile/send/new/message');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'request_id': request_id,
        'receiver_id': chatee_id,
        'message': message,
      });
      print('===============================================');
      print(response.body.toString());
      print(response.statusCode);

    } finally {
      client.close();
    }
  }

  Future<void> load_messages() async {
    // var session = FlutterSession();
    // messages = [];
    // print('...... . . ...'+await session.get('chat_font_size'));
    // mySelectedFontSize = double.parse('${await session.get('chat_font_size')}');
    mySelectedFontSize = 14;

    var client = http.Client();
    try {
      int user_id = 0;
      var session = FlutterSession();
      user_id = await session.getInt('id');
      setState(() {
        auth_id = user_id.toString();
      });
      var url = Uri.parse(Component().API+'mobile/get/messages');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'receiver_id': chatee_id,
        'request_id': request_id,
      });
      var server_response = jsonDecode(response.body.toString());
      setState(() {
        fetching_messages= 0;
      });
      print(chatee_id+' '+user_id.toString()+'==============================================='+server_response['messages'].toString());
      List data = server_response['messages']['data'];
      print(user_id.toString()+'==============================================='+server_response['messages'].toString());
      for(int i = 0; i < data.length; i++){
        String type = "receiver";
        if(int.parse(data[i]['sender_id'].toString()) == int.parse(user_id.toString())){
          type = 'sender';
        }
        // print(data[i]['sender_id']);
        // print('------------------');
        messages.add(ChatMessage(messageContent: data[i]['message'], messageType: type, viewingOption: false, id: data[i]['id'].toString()));
      }
      scrollToBottom();
      // print('Response status: ${response.statusCode}');
    } finally {
      client.close();
    }
  }

  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    load_messages();
    _firebaseMessaging = FirebaseMessaging.instance;
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      // event.notification.bodyLocArgs
      print(event.notification!.body);
      if(event.data['chat'] != null && request_id == event.data['request_id']) {
        SystemSound.play(SystemSoundType.alert);
        // if (int.parse(sender_info['sender_id'].toString()) == int.parse(chatee_id)) {
          // I'M CHATTING WITH RECEIVER
          receive_message(event.notification!.body.toString());
        // } else {
          // RUN DEVICE NOTIFICATION BAR
        // }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load_messages();
  }

  void scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_scrollController.hasClients){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void receive_message(String message){
    var new_inbox = ChatMessage(messageContent: message, messageType: "receiver", viewingOption: false, id: '100000');
    setState(() {
      messages.add(new_inbox);
    });
    scrollToBottom();
  }
}