import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_dmx/dmx_Controller_provider.dart';
import 'package:flutter_bluetooth_dmx/bluetooth_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DmxControllerProvider>(create: (_) => DmxControllerProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Bluetooth DMX',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BluetoothScreen(),
      ),
    );
  }
}
