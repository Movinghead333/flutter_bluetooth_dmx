import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ManualDmxControlScreen extends StatefulWidget {
  final BluetoothConnection arduinoConnection;

  const ManualDmxControlScreen({required this.arduinoConnection, Key? key})
      : super(key: key);

  @override
  State<ManualDmxControlScreen> createState() => _ManualDmxControlScreenState();
}

class _ManualDmxControlScreenState extends State<ManualDmxControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DMX control')),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            child: Text('Turn off LED'),
            onPressed: () {
              Uint8List outputData = Uint8List.fromList(ascii.encode('0'));
              //[99, 48, 118, 50, 53, 53, 10]

              widget.arduinoConnection.output.add(outputData);
            },
          ),
          ElevatedButton(
            child: Text('Turn on LED'),
            onPressed: () {
              Uint8List outputData = Uint8List.fromList(ascii.encode('1'));
              //[99, 48, 118, 50, 53, 53, 10]

              widget.arduinoConnection.output.add(outputData);
            },
          ),
        ]),
      ),
    );
  }
}
