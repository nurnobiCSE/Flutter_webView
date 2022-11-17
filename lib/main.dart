import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/platform_interface.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

import 'check_internet.dart';

void main() async{
  await FlutterDownloader.initialize(
      debug: false); // set true to enable printing logs to console
  await Permission.storage.request();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  var _scafoldkey = GlobalKey<ScaffoldState>();
  late WebViewController _controller;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    // TODO: implement initState
    requestPermission();
    super.initState();
  }
  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  void requestPermission()async{

    var status = await Permission.storage.status;
    if(!status.isGranted){
      await Permission.storage.request();
    }
    var status1 = await Permission.manageExternalStorage.status;
    if(!status1.isGranted){
      await Permission.manageExternalStorage.request();
    }
  }
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WebView",
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      home: Scaffold(
        key: _scafoldkey,
        appBar: AppBar(
          leading: IconButton(
              onPressed: ()async{
                if(await _controller.canGoBack()){
                  _controller.goBack();
                }
              },
              icon: Icon(Icons.arrow_back)
          ),
          title: Text("QTACADEMY"),
          actions: [
            IconButton(
                onPressed: (){
                  _controller.reload();
                },
                icon: Icon(Icons.refresh_rounded)
            )
          ],
        ),
        body: Center(
          child: WillPopScope(
            onWillPop: ()async{
              if (await _controller.canGoBack()) {
                _controller.goBack();
                return false;
              } else{
                return true;
              }
            },
              
            child: WebView(
              initialUrl: 'https://quickteamacademy.com/',
              javascriptMode: JavascriptMode.unrestricted,

              onWebViewCreated: (WebViewController webViewController){
                _controller = webViewController;
              },
            )
          ),
        ),
      ),
    );
  }
  showDialogBox() => showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('No Connection'),
        content: const Text('Please check your internet connectivity'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context, 'Cancel');
              setState(() => isAlertSet = false);
              isDeviceConnected =
              await InternetConnectionChecker().hasConnection;
              if (!isDeviceConnected && isAlertSet == false) {
                showDialogBox();
                setState(() => isAlertSet = true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      )
  );
}

