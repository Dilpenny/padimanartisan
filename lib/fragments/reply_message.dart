//import 'dart:html';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../helpers/components.dart';
import '../helpers/session.dart';

class ReplyMessagePage extends StatefulWidget {
  final messageDetails;

  const ReplyMessagePage({Key? key, this.messageDetails}) : super(key: key);
  @override
  ReplyMessagePageWidget createState() => ReplyMessagePageWidget(messageDetails);
}

class ReplyMessagePageWidget extends State<ReplyMessagePage> {
  final messageDetails;
  int processing = 0;
  int logged_in = 41900000;
  int user_id = 0;
  String password = '';
  String newPassword = '';
  String confirmPassword = '';
  ReplyMessagePageWidget(this.messageDetails);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  final TextEditingController messageController = new TextEditingController();

  String imgurl = 'https://cdn.pixabay.com/photo/2021/01/04/10/41/icon-5887126_1280.png';
  String fullname = 'John Doe';

  @override
  Widget build(BuildContext context) {
//    List<Map> details = sqLiteDbProvider.getUser();
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color.fromRGBO(10, 93, 113, 1),
        backgroundColor: const Color.fromRGBO(243, 243, 247, 1),
        elevation: 0,
        title: const Text("Reply Message"),
      ),
      backgroundColor: const Color.fromRGBO(243, 243, 247, 1),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          Text(messageDetails['subject'], style: const TextStyle(fontSize: 16),),
                          Text(messageDetails['type'], style: const TextStyle(fontSize: 10),)
                        ],
                      ),
                      Text('(Sending to '+messageDetails['name']+')', style: const TextStyle(fontSize: 12),)
                    ],
                  )
              ),
              Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(top: 0),
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.white,
                          ),
                          child:
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: messageController,
                                      obscureText: false,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: 'Reply message',
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Required field';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.all(15)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  processing = 1;
                                });
                                await sendMessage(messageController.text);
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Send  '.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                (processing == 1) ? const SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: Colors.white, ),) : SizedBox(width: 2,)
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  )
            ],
          )
      ),
    );
  }

  Future<void> sendMessage(String replyMessage) async {
    var client = http.Client();
    try {
      var session = FlutterSession();
      user_id = await session.getInt('id');
      var url = Uri.parse(Component().API+'rider/send/message/action');
      var response = await http.post(url, body: {
        'message': replyMessage,
        'subject': messageDetails['subject'],
        'receiver_id': messageDetails['replyReceiverId'],
        'reply_id': messageDetails['replyId'],
        'user_id': user_id.toString(),
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
        return;
      }
      Component().success_toast(message);
      // Map user = server_response['user'].toString();
      setState(() {
        processing = 0;
      });
      messageController.text = '';

      Component().success_toast(message);

      return null;
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
    imgurl = await session.get('img');
    fullname = await session.get('fullname');
    setState(() {
      fullname = fullname;
      imgurl = imgurl;
      user_id = user_id;
    });
  }

}