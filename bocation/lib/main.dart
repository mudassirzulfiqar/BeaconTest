import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const BeaconPage(),
    );
  }
}

class BeaconPage extends StatefulWidget {
  const BeaconPage({Key? key}) : super(key: key);

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  late StreamSubscription<MonitoringResult> streamRegion;
  late StreamSubscription<RangingResult> streamRanging;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    initialize();
                    start();
                  },
                  child: const Text('Start Monitoring')),
              TextButton(
                  onPressed: () {
                    cancelMonitoring();
                  },
                  child: const Text('Cancel Monitoring'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    try {
      // if you want to manage manual checking about the required permissions
      await flutterBeacon.initializeScanning;

      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch (e) {
      showMessage(e.message!);
      // library failed to initialize, check code and message
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void start() {
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Office-Entrance',
          proximityUUID: 'e2c56db5-dffb-48d2-b060-d0f5a71096e0',
          major: 0,
          minor: 0));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

    streamRegion =
        flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      // result contains a region, event type and event state
      if (result.monitoringState == MonitoringState.inside) {
        showMessage("inside");
        log("inside");
      } else if (result.monitoringState == MonitoringState.outside) {
        showMessage("outside");
        log("outside");
      } else {
        showMessage("unknown");
        log("unknown");
      }
    });

    streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        showMessage("ranging${result.beacons[0].accuracy}");
        log("ranging${result.beacons[0].accuracy}");
      }
    });

    showMessage("Started monitoring");
  }

  void cancelMonitoring() {
    streamRegion.cancel();
  }
}
