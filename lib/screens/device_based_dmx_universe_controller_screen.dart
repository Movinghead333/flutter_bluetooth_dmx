import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_dmx/data_models/dmx_device.dart';
import 'package:flutter_bluetooth_dmx/providers/dmx_Controller_provider.dart';
import 'package:provider/provider.dart';

class DeviceBasedDmxUniverseControllerScreen extends StatefulWidget {
  const DeviceBasedDmxUniverseControllerScreen({super.key});

  @override
  State<DeviceBasedDmxUniverseControllerScreen> createState() =>
      _DeviceBasedDmxUniverseControllerScreenState();
}

class _DeviceBasedDmxUniverseControllerScreenState
    extends State<DeviceBasedDmxUniverseControllerScreen> {
  bool _customTileExpanded = false;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DmxControllerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('DMX control')),
      body: Center(
        child: StreamBuilder<List<DmxDevice>>(
            stream: model.dmxDevices.stream,
            builder: (context, dmxDevicesAsyncSnapshot) {
              return StreamBuilder<List<int>>(
                  stream: model.channelValues.stream,
                  builder: (context, asyncSnapshot) {
                    if (dmxDevicesAsyncSnapshot.hasError) {
                      return Center(
                          child:
                              Text('Error: ${dmxDevicesAsyncSnapshot.error}'));
                    }

                    if (asyncSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${asyncSnapshot.error}'));
                    }

                    if (!asyncSnapshot.hasData ||
                        !dmxDevicesAsyncSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DmxDevice> dmxDevices = dmxDevicesAsyncSnapshot.data!;
                    List<int> channelValues = asyncSnapshot.data!;

                    return ListView.builder(
                      itemCount: dmxDevices.length,
                      itemBuilder: (context, index) {
                        return ExpansionTile(
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              _customTileExpanded = expanded;
                            });
                          },
                          title: Text(
                              '${dmxDevices[index].specification.name} (A: ${dmxDevices[index].startAdress}, C: ${dmxDevices[index].specification.numChannels})'),
                          children: List.generate(
                            dmxDevices[index].specification.numChannels,
                            (localChannelIndex) {
                              int channelNumber =
                                  dmxDevices[index].startAdress +
                                      localChannelIndex -
                                      1;
                              return ListTile(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text(dmxDevices[index]
                                                .specification
                                                .channelInfos[localChannelIndex]
                                                .channelName),
                                            content: Text(dmxDevices[index]
                                                .specification
                                                .channelInfos[localChannelIndex]
                                                .description),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('OK'))
                                            ],
                                          ));
                                },
                                title: Text(
                                    '${dmxDevices[index].specification.channelInfos[localChannelIndex].channelName}: ${channelValues[channelNumber]}'),
                                subtitle: Slider(
                                  min: 0,
                                  max: 255,
                                  divisions: 256,
                                  value:
                                      channelValues[channelNumber].toDouble(),
                                  onChanged: (double newValue) {
                                    model.setChannelValue(
                                        channelNumber, newValue.toInt());
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  });
            }),
      ),
    );
  }
}
