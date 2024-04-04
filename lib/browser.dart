import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:padimanartisan/map/.env.dart';
import 'package:permission_handler/permission_handler.dart';
import 'helpers/components.dart';

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Permission.camera.request();
//   await Permission.microphone.request(); // if you need microphone permission
//   runApp(MyBrowser());
// }

class MyBrowser extends StatefulWidget {
  final String? title;
  final String? link;

  const MyBrowser({Key? key, this.title, this.link}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState(this.title, this.link);
}

class _MyAppState extends State<MyBrowser> {
  final String? title;
  final String? link;

  String? _deviceId;

  int initializedo = 0;

  int processing = 0;
  bool isLoading=true;
  bool downloading=false;
  bool isDownloaded = false;
  bool isError = false;
  String progress = '';
  int so_far = 0;

  late InAppWebViewController _webViewController;

  _MyAppState(this.title, this.link);
  //
  Future initiatePermission()async{
    WidgetsFlutterBinding.ensureInitialized();
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  void initState() {
    initiatePermission();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: secondaryColor,
          title: Text(title!),
          actions: [

          ],
        ),
        body: Column(
            children: <Widget>[
              isError ? SizedBox(child: Component().show_error(), width: double.infinity,) : const SizedBox(),
              isLoading ? SizedBox(child: Component().line_loading(), width: double.infinity,) : const SizedBox(),
              Visibility(
                visible: (isError) ? false : true,
                child: Container(
                  width: double.infinity,
                  // height: MediaQuery.of(context).size.height - 80,
                  height: (isLoading) ? MediaQuery.of(context).size.height - 120 : MediaQuery.of(context).size.height - 120,
                  child:Container(
                      child: Column(children: <Widget>[
                        Expanded(
                            child: InAppWebView(
                              initialUrlRequest: URLRequest(

                                  url: Uri.parse(link!.toString())
                              ),
                              onLoadResource: (InAppWebViewController controller, LoadedResource loaded){
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              onLoadError: (InAppWebViewController controller, Uri? url, int value, String message){
                                setState(() {
                                  isError = true;
                                  isLoading = false;
                                });
                              },
                              initialOptions: InAppWebViewGroupOptions(
                                  crossPlatform: InAppWebViewOptions(
                                      javaScriptEnabled: true,
                                      mediaPlaybackRequiresUserGesture: true,
                                      cacheEnabled: true,
                                      clearCache: true,
                                      allowUniversalAccessFromFileURLs: true,
                                      allowFileAccessFromFileURLs: true,
                                      javaScriptCanOpenWindowsAutomatically: true,
                                      useOnLoadResource: true,
                                      useShouldInterceptFetchRequest: true,
                                      useShouldOverrideUrlLoading: true,
                                      useOnDownloadStart: true
                                  ), android: AndroidInAppWebViewOptions(
                                // on Android you need to set supportMultipleWindows to true,
                                // otherwise the onCreateWindow event won't be called
                                supportMultipleWindows: true,
                                allowContentAccess: true,
                                blockNetworkImage: false,
                                hardwareAcceleration: true,
                                blockNetworkLoads: false,
                                loadsImagesAutomatically: true,
                                thirdPartyCookiesEnabled: true,
                                allowFileAccess: true,
                                databaseEnabled: true,
                                domStorageEnabled: true,
                                saveFormData: true,

                              )
                              ),
                              onConsoleMessage: (InAppWebViewController controller, ConsoleMessage message){
                                print('=======================');
                                print(message);
                                print('=========================================');
                              },
                              onUpdateVisitedHistory:(InAppWebViewController controller, Uri? url, bool? yes) {
                                _webViewController = controller;
                              },
                              onWebViewCreated: (InAppWebViewController controller) {
                                _webViewController = controller;
                              },
                            ))
                      ])),
                ),
              )
            ]
        )
    );
  }


}