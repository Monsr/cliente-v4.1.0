import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/restaurant.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as sett;

class MapController extends ControllerMVC {
  Order currentOrder;
  Marker customerMarker;
  Restaurant currentRestaurant;
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  Address currentAddress;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  MapsUtil mapsUtil = new MapsUtil();
  Completer<GoogleMapController> mapController = Completer();

  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
    stream.listen((Restaurant _restaurant) {
      setState(() {
        topRestaurants.add(_restaurant);
      });
      Helper.getMarker(_restaurant.toMap()).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    }, onError: (a) {}, onDone: () {});
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.deliveryAddress.value;
      setState(() {
        if (currentAddress.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(19.390519, -99.4238198),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress.latitude, currentAddress.longitude),
            zoom: 14.4746,
          );
        }
      });
      if (!currentAddress.isUnknown()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void getRestaurantLocation() async {
    try {
      currentAddress = await sett.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(currentRestaurant.latitude), double.parse(currentRestaurant.longitude)),
          zoom: 14.4746,
        );
      });
      Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  // NUEVA FUNCIONALIDAD AGREGADA


  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((_currentAddress) {
      setState(() {
        print("Set current location map controller");
        print(_currentAddress);
        sett.deliveryAddress.value = _currentAddress;
        currentAddress = _currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
        zoom: 14.4746,
      )));
    });
  }

 
  Future<LatLng> getLocationOrder() async {
    // final GoogleMapController controller = await mapController.future;

    // sett.setCurrentLocation().then((_currentAddress) {
    //   setState(() {
    //     sett.deliveryAddress.value = _currentAddress;
    //     currentAddress = _currentAddress;
    //   });
    //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //     target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
    //     zoom: 14.4746,
    //   )));
    // });
    LatLng orderLocation;
        return orderLocation;
  }

  void getRestaurantsOfArea() async {
    setState(() {
      topRestaurants = <Restaurant>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearRestaurants(currentAddress, areaAddress);
      } else {
        listenForNearRestaurants(currentAddress, currentAddress);
      }
    });
  }

  void getDirectionSteps() async {
    currentAddress = await sett.getCurrentLocation();
    mapsUtil
        .get("origin=" +
            currentAddress.latitude.toString() +
            "," +
            currentAddress.longitude.toString() +
            "&destination=" +
            currentRestaurant.latitude +
            "," +
            currentRestaurant.longitude +
            "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
          if (res != null) {
            List<LatLng> _latLng = res as List<LatLng>;
            _latLng?.insert(0, new LatLng(currentAddress.latitude, currentAddress.longitude));
            setState(() {
              polylines.add(new Polyline(
                  visible: true, polylineId: new PolylineId(currentAddress.hashCode.toString()), points: _latLng, color: config.Colors().mainColor(0.8), width: 6));
            });
          }
        });
  }

  Future refreshMap() async {
    setState(() {
      topRestaurants = <Restaurant>[];
    });
    listenForNearRestaurants(currentAddress, currentAddress);
  }

  void getCustomerMarker(latitude, longitude) async {
     await Helper.getMyPositionMarker(latitude,longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
            customerMarker = marker; 
          });
        });
  }

  //  void getOrderLocation() async {
  //   try {
  //     currentAddress = sett.myAddress.value;
  //     setState(() {
  //       cameraPosition = CameraPosition(
  //         target: LatLng(currentOrder.deliveryAddress.latitude, currentOrder.deliveryAddress.longitude),
  //         zoom: 14.4746,
  //       );
  //     });
  //     if (!currentAddress.isUnknown()) {
  //       Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
  //         setState(() {

  //           allMarkers.add(marker);
  //         });
  //       });
  //     }
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       print('Permission denied');
  //     }
  //   }
  // }

  void getDirectionStepsCustomer(lat, lng) async {
    //currentAddress = sett.myAddress.value;
    mapsUtil
        .get("origin=" +
            lat.toString() +
            "," +
            lng.toString() +
            "&destination=" +
            currentOrder.deliveryAddress.latitude.toString() +
            "," +
            currentOrder.deliveryAddress.longitude.toString() +
            "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
          if (res != null) {
            List<LatLng> _latLng = res as List<LatLng>;
            _latLng?.insert(0, new LatLng(lat, lng));
            setState(() {
              polylines.add(new Polyline(
                  visible: true, 
                  //polylineId: new PolylineId(currentAddress.hashCode.toString()),
                  polylineId: new PolylineId(currentOrder.id), 
                  points: _latLng, 
                  color: config.Colors().mainColor(0.8), 
                  width: 6));
            });
          }
        });
  }

}
