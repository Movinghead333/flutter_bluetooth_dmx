import 'package:flutter_bluetooth_dmx/data_models/channel_info.dart';

class DmxDevice {
  String name;
  int startAdress;
  int numChannels;
  List<ChannelInfo> channelInfos;

  DmxDevice({
    required this.name,
    required this.startAdress,
    required this.numChannels,
    required this.channelInfos,
  });
}
