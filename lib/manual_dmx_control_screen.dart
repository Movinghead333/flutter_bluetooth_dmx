import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

class ManualDmxControlScreen extends StatefulWidget {
  final FlutterBluetoothClassic bluetooth;

  const ManualDmxControlScreen({required this.bluetooth, Key? key})
      : super(key: key);

  @override
  State<ManualDmxControlScreen> createState() => _ManualDmxControlScreenState();
}

class _ManualDmxControlScreenState extends State<ManualDmxControlScreen> {
  List<int> channelValues = List.filled(256, 0);
  bool sent = false;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DMX control')),
      body: Center(
        child: ListView.builder(
          itemCount: channelValues.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Channel ${index + 1}:'),
              subtitle: Slider(
                min: 0,
                max: 255,
                divisions: 256,
                value: channelValues[index].toDouble(),
                onChanged: (double newValue) {
                  setState(() {
                    if (channelValues[index] == newValue) {
                      return;
                    }
                    channelValues[index] = newValue.toInt();
                    if (counter == 0) {
                      String message = '<${index + 1},${channelValues[index]}>';

                      widget.bluetooth
                          .sendData(List<int>.from(message.codeUnits));

                      debugPrint('Sent: $message');
                    }
                    counter = (counter + 1) % 1;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
