import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_dmx/providers/dmx_Controller_provider.dart';
import 'package:provider/provider.dart';

class ManualDmxControlScreen extends StatefulWidget {
  const ManualDmxControlScreen({Key? key}) : super(key: key);

  @override
  State<ManualDmxControlScreen> createState() => _ManualDmxControlScreenState();
}

class _ManualDmxControlScreenState extends State<ManualDmxControlScreen> {
  int counter = 0;

  initState() {
    super.initState();
  }

  double x = 0;
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DmxControllerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('DMX control')),
      body: Center(
        child: StreamBuilder<List<int>>(
            stream: model.channelValues,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error: ${asyncSnapshot.error}'));
              }

              if (!asyncSnapshot.hasData) {
                return Center(child: const CircularProgressIndicator());
              }

              List<int> channelValues = asyncSnapshot.data!;
              return ListView.builder(
                itemCount: channelValues.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text('Channel ${index + 1}: ${channelValues[index]}'),
                    subtitle: Slider(
                      min: 0,
                      max: 255,
                      divisions: 256,
                      value: channelValues[index].toDouble(),
                      onChanged: (double newValue) {
                        if (channelValues[index] == newValue) {
                          return;
                        }
                        model.setChannelValue(index, newValue.toInt());

                        if (counter == 0) {
                          String message =
                              '<${index + 1},${channelValues[index]}>';

                          Provider.of<DmxControllerProvider>(context,
                                  listen: false)
                              .bluetooth
                              .sendData(List<int>.from(message.codeUnits));

                          //debugPrint('Sent: $message');
                        }
                        //counter = (counter + 1) % 2;
                      },
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
