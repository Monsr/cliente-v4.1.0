import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_pusher_client/flutter_pusher.dart';
import 'package:laravel_echo/laravel_echo.dart';

//import '../helpers/pusher.dart';

import '../controllers/map_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';





class CurrentMapWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  CurrentMapWidget({Key key, this.routeArgument, this.parentScaffoldKey}) : super(key: key);

  @override
  _CurrentMapWidgetState createState() => _CurrentMapWidgetState();
}

class _CurrentMapWidgetState extends StateMVC<CurrentMapWidget> {

  //Maps
  MapController _con;
  StreamSubscription _locationSubscription;
  Marker deliveryBoyMarker;
  Circle circle;
  GoogleMapController _controller;
  LatLng orderOnWay;
  //PusherService _pusher;

  //Pusher
  List<String> _logs = new List();
  Echo echo;
  bool isConnected = false;
  String channelType = 'public';
  String channelName = '';
  String event;
  FlutterPusher pusherClient;


  _CurrentMapWidgetState() : super(MapController()) {
    _con = controller;
  }
  
  @override
  
  void initState() {
    _con.currentOrder = widget.routeArgument?.param as Order;
    if (_con.currentOrder?.deliveryAddress?.latitude != null) {
      _con.getCustomerMarker(_con.currentOrder.deliveryAddress.latitude, _con.currentOrder.deliveryAddress.longitude);
      //_con.getOrderLocation();
    } else {
      _con.getCurrentLocation();
    }

    super.initState();
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(19.293607, -99.703592),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/img/bike_icon.png");
    return byteData.buffer.asUint8List();
  }

  //Pusher

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

  void listenToChannel(String name, String event, Uint8List imageData) {
    dynamic channel; 
    channel = echo.channel(name);
    channel.listen(event, (e) {

      //Get DATA in strings
      String data = e.toString();

      data = data.trim();
      
      //int indexOrderIdStart = data.lastIndexOf("order") + 7; 
      //int indexOrderIdEnd = data.lastIndexOf("lat") - 2 ;
      //String orderId =data.substring(indexOrderIdStart, indexOrderIdEnd);

      int indexLatStart = data.lastIndexOf("lat") + 5; 
      int indexLatEnd = data.lastIndexOf("lng") - 2 ;
      String lat =data.substring(indexLatStart, indexLatEnd);
      
      int indexLngStart = data.lastIndexOf("lng") + 5; 
      int indexLngEnd = data.lastIndexOf("rotation") - 2 ;
      String lng = data.substring(indexLngStart, indexLngEnd);

      int indexRotStart = data.lastIndexOf("rotation") + 10; 
      int indexRotEnd = data.lastIndexOf("accuracy") - 2;
      String rot = data.substring(indexRotStart, indexRotEnd);

      int indexAccuStart = data.lastIndexOf("accuracy") + 10; 
      int indexAccuEnd = data.lastIndexOf("}") ;
      String accu = data.substring(indexAccuStart, indexAccuEnd);
      //print(data);
      var latitude = double.parse(lat);
      var longitude = double.parse(lng);
      var rotation = double.parse(rot);
      var accuracy = double.parse(accu);

      orderOnWay = new LatLng(latitude,longitude);

      if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(orderOnWay.latitude, orderOnWay.longitude),
              tilt: 0.0,
              zoom: 18.00)));
          updateMarkerAndCircle(orderOnWay, imageData, rotation, accuracy);
        }
      
      print('message: $e');

    });
  }
  //Maps
  void updateMarkerAndCircle(LatLng latlng, Uint8List imageData, double rotation, double accuracy) {
    
    this.setState(() {
      _con.getDirectionStepsCustomer(latlng.latitude, latlng.longitude);
      deliveryBoyMarker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: rotation,
          draggable: true,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
          circle = Circle(
            circleId: CircleId("car"),
            radius: accuracy,
            zIndex: 1,
            strokeColor: Colors.blue,
            center: latlng,
            fillColor: Colors.blue.withAlpha(70)
          );
    });
  }

  void getCurrentLocation() async {
    //pusher connection
    connect();
    try {
      Uint8List imageData = await getMarker();
      var i = _con.currentOrder.id;
      listenToChannel("changed.location.$i", "ChangedLocation", imageData);

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    //desconect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_con.customerMarker == null) ?
        CircularLoadingWidget(height: 400)
        : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(_con.currentOrder.deliveryAddress.latitude, _con.currentOrder.deliveryAddress.longitude),
              zoom: 14.4746,
            ),
            markers: Set.of((deliveryBoyMarker != null) ? [deliveryBoyMarker, _con.customerMarker] : [_con.customerMarker] ),
            circles: Set.of((circle != null) ? [circle] : []),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            polylines: _con.customerMarker != null ? _con.polylines : null

          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.motorcycle),
              onPressed: () {
                initPusher();
                getCurrentLocation();
              }
          ),
    );
  }
}