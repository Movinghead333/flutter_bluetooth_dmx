import 'package:flutter_bluetooth_dmx/data_models/channel_info.dart';

class DmxDeviceSpecification {
  final String name;
  final int numChannels;
  final List<ChannelInfo> channelInfos;

  const DmxDeviceSpecification({
    required this.name,
    required this.numChannels,
    required this.channelInfos,
  });
}
