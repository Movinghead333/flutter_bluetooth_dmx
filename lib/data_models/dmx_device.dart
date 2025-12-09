import 'package:flutter_bluetooth_dmx/data_models/dmx_device_specification.dart';

class DmxDevice {
  int startAdress;
  final DmxDeviceSpecification specification;

  DmxDevice({
    required this.startAdress,
    required this.specification,
  });
}
