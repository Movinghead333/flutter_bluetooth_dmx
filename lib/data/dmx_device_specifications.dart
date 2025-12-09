import 'package:flutter_bluetooth_dmx/data_models/channel_info.dart';
import 'package:flutter_bluetooth_dmx/data_models/dmx_device_specification.dart';

const DmxDeviceSpecification kFlatParLedSpec = DmxDeviceSpecification(
  name: 'FLAT PAR LED',
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
);

const DmxDeviceSpecification kLedBarSpec = DmxDeviceSpecification(
  name: 'LED PIX-72 RGB Bar',
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
        ),
      ],
);