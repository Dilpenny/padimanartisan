import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Component{
  String API = "https://padiman.erate.me/public/";
  String RTC_SERVER_API = "https://testing.erate.me/Tools-master/DynamicKey/AgoraDynamicKey/php/sample/RaedaExpress.php";
  String SMALL_EXHAUSTED_WARNING = "Memories created in cambleu are safe and will always be online. This means you can still manage, share and access your memories even without a subscription.";
  String session_name = 'Padiman';

  Color primaryColor = const Color.fromRGBO(10, 93, 113, 1);
  void success_toast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromRGBO(40, 167, 69, 1),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  void success_toast_shorti(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightGreen,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void error_toast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(249, 70, 135, 1),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void default_toast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  String getRandom(int length){
    var r = Random();
    return String.fromCharCodes(List.generate(length, (index) => r.nextInt(33) + 89));
  }

  int getRandomi(){
    return DateTime.now().millisecondsSinceEpoch;
  }

  int getRandomInt(){
    return new DateTime.now().microsecondsSinceEpoch;
  }

  // Future<void> saveData(List parameters, List values) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   for(int i = 0; i < parameters.length; i++){
  //     await prefs.setString(parameters[i], values[i]);
  //   }
  // }
  //
  // Future<void> saveDatai(String parameter, String values) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString(parameter, values);
  // }

  Center show_error(){
    return Center(
      child: SizedBox(
          width: double.infinity,
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Icon(Icons.cloud_off_rounded),
              Text(' Check your internet of refresh')
            ],
          )
      ),
    );
  }

  Widget leadingWidget(String title){
    if(title.contains('elete') == true){
      return Image.asset("graphics/delete.png", width: 40,);
    }
    else if(title.toLowerCase().contains('like') == true){
      return Icon(Icons.thumb_up_rounded, size: 40, color: Colors.green,);
    }
    else if(title.toLowerCase().contains('comment') == true){
      return Icon(Icons.comment_rounded, size: 40, color: Colors.green,);
    }
    else if(title.toLowerCase().contains('new') == true){
      return Icon(Icons.photo_camera_back, size: 40, color: Colors.green,);
    }
    else if(title.toLowerCase().contains('share') == true){
      return Icon(Icons.share_sharp, size: 40, color: Colors.green,);
    }
    else if(title.toLowerCase().contains('edit') == true){
      return Icon(Icons.edit_outlined, size: 40, color: Colors.green,);
    }
    else{
      return Icon(Icons.compare_outlined, size: 40, color: Colors.green,);
    }
  }

  Center loading(){
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Image.asset("graphics/load.gif", width: 100,),
      ),
    );
  }

  Center line_loading(){
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: LinearProgressIndicator(
          backgroundColor: Color.fromRGBO(10, 93, 113, 1),
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightGreen),
        ),
      ),
    );
  }

  Widget subLeadingWidget(String title){
    if(title.contains('remium') == true){
      return Image.asset("graphics/diamond.png", width: 40,);
    }
    else if(title.toLowerCase().contains('deluxe') == true){
      return Image.asset("graphics/crown.png", width: 40,);
    }
    else{
      return Image.asset("graphics/star.png", width: 40,);
    }
  }
}