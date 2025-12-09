import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:flutter_bluetooth_dmx/data/dmx_device_specifications.dart';
import 'package:flutter_bluetooth_dmx/data_models/dmx_device.dart';
import 'package:rxdart/rxdart.dart';

class DmxControllerProvider {
  BehaviorSubject<List<int>> channelValues =
      BehaviorSubject<List<int>>.seeded(List.filled(512, 0));
  BehaviorSubject<List<DmxDevice>> dmxDevices =
      BehaviorSubject<List<DmxDevice>>.seeded([
    DmxDevice(startAdress: 1, specification: kFlatParLedSpec),
    DmxDevice(startAdress: 9, specification: kFlatParLedSpec),
    DmxDevice(startAdress: 17, specification: kLedBarSpec),
  ]);

  FlutterBluetoothClassic bluetooth = FlutterBluetoothClassic();

  void setChannelValue(int channel, int value) {
    if (channel < 0 || channel > 511) {
      throw ArgumentError('Channel must be between 1 and 256');
    }
    if (value < 0 || value > 255) {
      throw ArgumentError('Value must be between 0 and 255');
    }
    channelValues.value[channel] = value;
    channelValues.add(channelValues.value);

    String message = '<${channel + 1},$value>';

    bluetooth.sendData(List<int>.from(message.codeUnits));
  }

  int getChannelValue(int channel) {
    if (channel < 0 || channel > 511) {
      throw ArgumentError('Channel must be between 1 and 256');
    }
    return channelValues.value[channel];
  }

  int get totalChannels => channelValues.value.length;
}
