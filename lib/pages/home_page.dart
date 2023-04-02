import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swiftresponse/pages/accountPage.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:camera/camera.dart';
import 'package:swiftresponse/pages/create_report_page.dart';
import 'package:swiftresponse/pages/history_page.dart';
import 'package:swiftresponse/utils/colors.dart';

import '../utils/dimensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _currentAddress;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(position);
      print(_currentPosition);
      print(_currentAddress);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = place.street.toString() +
            place.subLocality.toString() +
            place.subAdministrativeArea.toString() +
            place.postalCode.toString();
        print(place.street.toString() +
            place.subLocality.toString() +
            place.subAdministrativeArea.toString() +
            place.postalCode.toString());
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ListView(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (Container) => AccountPage()));
          },
          child: Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Icon(Icons.people)]),
          ),
        ),
        Center(
          child: Container(
            width: double.maxFinite,
            height: Dimensions.homePageScreenHeight,
            decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                image: DecorationImage(
                    image: AssetImage(
                        "assets/images/listing_main_car_crash_clipart-800x800__1_.png"))),
            child: Column(
              children: [
                Container(
                  height: 570,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 390),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/listing_main_car_crash_clipart-800x800__1_.png"))),
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () async {
                            final image = await availableCameras()
                                .then((value) => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CameraPage(cameras: value)),
                                    ));
                          },
                          child: Container(
                            height: 50,
                            width: 200,
                            child: Center(child: Text("Report")),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.white),
                          )),
                      const Gap(15),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (Container) => HistoryPage()));
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          child: Center(child: Text("History")),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                // Container(
                //   child: Text("you have Active report"),
                // )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
