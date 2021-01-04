import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:flutter_pusher_client/flutter_pusher.dart';
import 'package:http/http.dart' as http;





class PusherService{

  List<String> _logs = new List();
  Echo echo;
  bool isConnected = false;
  String channelType = 'public';
  String channelName = '';
  String event;
  FlutterPusher pusherClient;

  void onConnectionStateChange(ConnectionStateChange event) {
    if (event.currentState == 'CONNECTED') {
      log('connected');
      isConnected = true;
    } else if (event.currentState == 'DISCONNECTED') {
      log('disconnected');
      isConnected = false;
    }
  }

  FlutterPusher getPusherClient() {
    PusherOptions options = PusherOptions(
      cluster: "us2"
      //host: '10.0.2.2',
      //port: 6001,
      //encrypted: false,
    );
    return FlutterPusher('63523b0c07b780be7572', options, lazyConnect: true);
  }

  void connect() {
    pusherClient.connect(onConnectionStateChange: this.onConnectionStateChange);
  }

  void initPusher() {
    pusherClient = getPusherClient();

    echo = new Echo({
      'broadcaster': 'pusher',
      //'key': '63523b0c07b780be7572',
      'client': pusherClient,
      'auth': {
        'headers': {
          'Authorization':
              'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjFkNTcxYzcyMTcwZmFmNDRmM2JkYjdkZTE2NmVmNTMzZTMwYjYwNjI2MjA5NjJlNWFhMmNkNTkyOTgwMzNlZmVlMjMyNzI2YTczMTY2NGZiIn0.eyJhdWQiOiIxIiwianRpIjoiMWQ1NzFjNzIxNzBmYWY0NGYzYmRiN2RlMTY2ZWY1MzNlMzBiNjA2MjYyMDk2MmU1YWEyY2Q1OTI5ODAzM2VmZWUyMzI3MjZhNzMxNjY0ZmIiLCJpYXQiOjE1NTAyNTE4MzIsIm5iZiI6MTU1MDI1MTgzMiwiZXhwIjoxNTgxNzg3ODMyLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.Yhmzofhp8q32gcFmzQDAmm48cwmxqrZAi4Mfsbzp6pyzjzWziEM8isDrNqyQZANXUJP40LGJroK9LkVddHyqWtPQqTNXPv-Azx3tVy_YOkI-BhJhttKaiN7DTPD9gYiuUpINUjrqTVuzxzDHzXNmTemOVqVBABo4f6m9ZoWkdyNKyirPZHagofs4Lp1YR0--AgItZVCPl3DYrLdMY78a687edQaYA1q3HKWPggtxayN35BPoeOm08uxmE_YzYXRTzi6OxGLNcQnrC61NvWqTCZ5Ze4fvUuVRtASqybV1Y4oxcgs2kZYg1rxm5idHUrGwQE4fLmaGgDclBR7Ax-NbiN-VN1gJpB2D7eVYxigCVsCVBnoA5DtjKewg0axckthTXyxcTWJBnbarbbnPuI9ZWrxaZWcp4kWwosw9_pr7Ee_5Q-Uxr_ksZg6qZ3gVrqR9ZY0zZoQl4qEsbUGfLXLGrKj_NjeESOcUsPY6fACIy_Okttxto_a3y9wQwPMDJY-jxdLdZ1TdusZUJG8d5KJxfOUprqsCzju-TVnLZxpA-f15mI9zIcjtA-2PFYnUuukIxBw-FXzBWssrMLyTXxHl9Sux3WH5mtXDW_wbwoJj6aaLHBw28jgokbdlKx3QRWdTvAsALJM6nmDN4BWu2pIn05i5wpcUnxHIvcdOgoh3hn0'
        }
      }
    });
  }

  log(String event) {
    var now = new DateTime.now();
    String formatted =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _logs.insert(0, "$formatted $event");
  }

  void listenToChannel(String name, String event) {
    dynamic channel; 
    channel = echo.channel(name);
    channel.listen(event, (e) {
      print("Zimba");
      print("event");
      print('channel: $name, event: $event');
      //var time = e;
      print('message: $e');

    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return CupertinoPageScaffold(
  //     child: Column(
  //       children: <Widget>[
  //         Flexible(
  //           child: Container(
  //             padding: EdgeInsets.all(15),
  //             color: Colors.grey[100],
  //             child: ListView.builder(
  //               reverse: true,
  //               itemCount: _logs.length,
  //               itemBuilder: (BuildContext context, index) {
  //                 return Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 4),
  //                   child: Text(_logs[index]),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //         Container(
  //           height: 70,
  //           decoration: BoxDecoration(
  //             border: Border(
  //               top: BorderSide(color: Colors.grey[300]),
  //             ),
  //           ),
  //           child: Center(
  //             child: ListView(
  //               scrollDirection: Axis.horizontal,
  //               children: <Widget>[
  //                 CupertinoButton(
  //                   onPressed: () {
  //                     showCupertinoModalPopup<void>(
  //                       context: context,
  //                       builder: (BuildContext context) {
  //                         return ChannelModal(
  //                           listen: true,
  //                           type: channelType,
  //                           name: channelName,
  //                           onTypeChanged: (value) {
  //                             setState(() {
  //                               channelType = value;
  //                             });
  //                           },
  //                           onNameChanged: (value) {
  //                             setState(() {
  //                               channelName = value;
  //                             });
  //                           },
  //                           onEventChanged: (value) {
  //                             setState(() {
  //                               event = value;
  //                             });
  //                           },
  //                           onSubmit: () {
  //                             log('Listening to channel: $channelName');
  //                             _listenToChannel(channelType, channelName, event);
  //                             Navigator.of(context).pop();
  //                           },
  //                         );
  //                       },
  //                     );
  //                   },
  //                   child: Text('listen to channel'),
  //                 ),
  //                 CupertinoButton(
  //                   onPressed: () {
  //                     showCupertinoModalPopup<void>(
  //                       context: context,
  //                       builder: (BuildContext context) {
  //                         return ChannelModal(
  //                           listen: false,
  //                           name: channelName,
  //                           onNameChanged: (value) {
  //                             setState(() {
  //                               channelName = value;
  //                             });
  //                           },
  //                           onSubmit: () {
  //                             log('Leaving channel: $channelName');
  //                             echo.leave(channelName);
  //                             Navigator.of(context).pop();
  //                           },
  //                         );
  //                       },
  //                     );
  //                   },
  //                   child: Text('leave channel'),
  //                 ),
  //                 Visibility(
  //                   visible: !isConnected,
  //                   child: CupertinoButton(
  //                     onPressed: () {
  //                       log('connecting');
  //                       this.connect();
  //                     },
  //                     child: Text('connect'),
  //                   ),
  //                 ),
  //                 Visibility(
  //                   visible: isConnected,
  //                   child: CupertinoButton(
  //                     onPressed: () {
  //                       log('disconnecting');
  //                       echo.disconnect();
  //                     },
  //                     child: Text('disconnect'),
  //                   ),
  //                 ),
  //                 CupertinoButton(
  //                   onPressed: () {
  //                     dynamic id = echo.sockedId();
  //                     log('socket_id: $id');
  //                   },
  //                   child: Text('get socket-id'),
  //                 ),
  //                 CupertinoButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       _logs = [];
  //                     });
  //                   },
  //                   child: Text('clear log'),
  //                 ),
  //                 CupertinoButton(
  //                   onPressed: () async {
  //                     //192.168.0.14
  //                     var url = 'http://10.0.2.2:8000/chat/greet/2';
  //                     var response = await http.post(url);
  //                     print(response.body);
  //                   },
  //                   child: Text('Saludar a Mossi'),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}