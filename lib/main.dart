import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_bluetooth_dmx/providers/dmx_Controller_provider.dart';
import 'package:flutter_bluetooth_dmx/screens/bluetooth_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
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
