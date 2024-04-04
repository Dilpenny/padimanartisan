import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/change-password.dart';
import '../auth/change-pin.dart';
import '../browser.dart';
import '../drawer/drawer.dart';
import '../helpers/session.dart';
import '../map/.env.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: darkColor,
        elevation: 0,
        backgroundColor: whiteColor,
        title: Text('Contact Us', style: TextStyle(color: darkColor),),
      ),
      backgroundColor: Color.fromRGBO(243, 243, 247, 1),
      body: body(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        backgroundColor: Colors.yellow,
        foregroundColor: const Color.fromRGBO(7, 84, 40, 1),
        onPressed: () {
          String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return MyBrowser(title: 'Chat With Agent', link: url,);
          }));
        },
      ),
    );
  }

  Widget eachContact(String title, String value){
    return ListTile(
      title: Text(title),
      trailing: Text(value),
    );
  }

  Widget body(){
    return Container(
      color: whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('You can reach us via the following ways',
                  style: GoogleFonts.quicksand(fontSize: 18), textAlign: TextAlign.center,)
              ],
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                        TextSpan(
                            text: 'Phone Number',
                            style: GoogleFonts.quicksand(color: mutedColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                    const SizedBox(height: 5,),
                    Text(ADMIN_PHONE, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 18),),
                    const SizedBox(height: 5,),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () async {
                          var url = 'tel:$ADMIN_PHONE';
                          Uri _url = Uri.parse(url);
                          if(await canLaunchUrl(_url)){
                          await launchUrl(_url, webOnlyWindowName: 'Call Padiman');  //forceWebView is true now
                          }else {
                          throw 'Could not launch $url';
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: whiteColor, size: 13,),
                            Text(' Call now', style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold, fontSize: 12),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                var session = FlutterSession();
                String referalCode = await session.get('referal_code');

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ReferalScreen(referalCode: referalCode,),
                //   ),
                // );
              },
            ),
            const SizedBox(height: 40,),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                        TextSpan(
                            text: 'Email',
                            style: GoogleFonts.quicksand(color: mutedColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                    const SizedBox(height: 5,),
                    Text(ADMIN_EMAIL, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 18),),
                    const SizedBox(height: 5,),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () async {
                          var url = 'mailto:'+ADMIN_EMAIL;
                          Uri _url = Uri.parse(url);
                          if(await canLaunchUrl(_url)){
                          await launchUrl(_url, webOnlyWindowName: 'Email Padiman');  //forceWebView is true now
                          }else {
                          throw 'Could not launch $url';
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email_outlined, color: whiteColor, size: 13,),
                            Text(' Email us', style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold, fontSize: 12),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                var session = FlutterSession();
                String referalCode = await session.get('referal_code');

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ReferalScreen(referalCode: referalCode,),
                //   ),
                // );
              },
            ),
            const SizedBox(height: 40,),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: defaultColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                        TextSpan(
                            text: 'Live Chat with us',
                            style: GoogleFonts.quicksand(color: mutedColor),
                            children: <InlineSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: darkColor),
                              )
                            ]
                        )
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () {
                          String url = 'https://tawk.to/chat/63baeb6647425128790c500e/1gm92f375';
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return MyBrowser(title: 'Chat With Agent', link: url,);
                          }));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment, color: whiteColor, size: 13,),
                            Text(' Send message', style: GoogleFonts.quicksand(color: whiteColor, fontWeight: FontWeight.bold, fontSize: 12),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {

              },
            ),
          ],
        ),
      ),
    );
  }

}