import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:flutter_bluetooth_dmx/data_models/channel_info.dart';
import 'package:flutter_bluetooth_dmx/data_models/dmx_device.dart';
import 'package:rxdart/rxdart.dart';

class DmxControllerProvider {
  BehaviorSubject<List<int>> channelValues =
      BehaviorSubject<List<int>>.seeded(List.filled(512, 0));
  BehaviorSubject<List<DmxDevice>> dmxDevices =
      BehaviorSubject<List<DmxDevice>>.seeded([
    DmxDevice(
      name: 'FLAT PAR LED',
      startAdress: 1,
      numChannels: 8,
      channelInfos: [
        ChannelInfo(
          channelName: 'Red',
          description: "1 - 255: RED 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Green',
          description: "1 - 255: GREEN 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Blue',
          description: "1 - 255: BLUE 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'White',
          description: "1 - 255: WHITE 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Master Dimmer',
          description: "1 - 255: MASTER DIMMER 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'STROBING/PROGRAM SPEED/SOUND SENSITIVITY',
          description: "0 - 15: STROBING OFF\n"
              "16 - 255: STROBING SLOW - FAST\n"
              "0 - 255: PROGRAM SPEED SLOW - FAST\n"
              "0 - 31: SOUND SENSITIVITY OFF\n"
              "32 - 255: SOUND SENSITIVE LEAST - MOST",
        ),
        ChannelInfo(
          channelName:
              'DIMMING/STATIC COLOR SELECT/ COLOR CHANGE SELECT/COLOR FADE SELECT',
          description: "0 - 51: DIMMER MODE\n"
              "52 - 102: COLOR MACRO MODE\n"
              "103 - 153: COLOR CHANGE MODE\n"
              "154 - 204: COLOR FADE MODE\n"
              "205 - 255: SOUND ACTIVE MODE",
        ),
        ChannelInfo(
          channelName: 'MODES COLOR MACROS',
          description: "0 - 15: COLOR CHANGE 1\n"
              "16 - 31: COLOR CHANGE 2\n"
              "32 - 47: COLOR CHANGE 3\n"
              "48 - 63: COLOR CHANGE 4",
        ),
      ],
    ),
    DmxDevice(
      name: 'LED PIX-72 RGB Bar',
      startAdress: 9,
      numChannels: 5,
      channelInfos: [
        ChannelInfo(
          channelName: 'Red',
          description: "1 - 255: RED 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Green',
          description: "1 - 255: GREEN 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Blue',
          description: "1 - 255: BLUE 0% - 100%",
        ),
        ChannelInfo(
          channelName: 'Master Dimmer',
          description: "1 - 255: MASTER DIMMER 0% - 100%%",
        ),
        ChannelInfo(
          channelName: 'Music Mode / Strobe',
          description: "000 - 000: NO FUNCTION\n"
              "001 - 005: SOUND ACTIVE MODE (7 colors)\n"
              "006 - 010: NO FUNCTION\n"
              "011 - 255: Strobe-Effect with 0-100%",
        )
      ],
    ),
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
