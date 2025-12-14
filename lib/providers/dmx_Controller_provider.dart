import 'package:flutter/widgets.dart';
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
  final PublishSubject<MapEntry<int, int>> _changeSubject =
      PublishSubject<MapEntry<int, int>>();

  bool _isSending = false;
  MapEntry<int, int>? _queuedUpdate;

  DmxControllerProvider() {
    // Throttle rapid changes (e.g. slider moves) using throttleTime so we send
    // updates at regular intervals while dragging. Adjust duration as needed
    // (50-150ms). This ensures responsive feedback during interaction.
    _changeSubject.throttleTime(const Duration(milliseconds: 75)).listen(
          (entry) => _queueOrSend(entry),
        );
  }

  void setChannelValue(int channel, int value) {
    if (channel < 0 || channel > 511) {
      throw ArgumentError('Channel must be between 1 and 256');
    }
    if (value < 0 || value > 255) {
      throw ArgumentError('Value must be between 0 and 255');
    }
    channelValues.value[channel] = value;
    channelValues.add(channelValues.value);

    // Push the change into the throttled subject. Actual sending will be
    // handled by the throttled pipeline to avoid flooding the Bluetooth
    // connection when sliders are moved rapidly, while maintaining responsive
    // periodic updates during interaction.
    _changeSubject.add(MapEntry(channel, value));
  }

  /// Call when disposing the provider to close streams.
  void dispose() {
    channelValues.close();
    dmxDevices.close();
    _changeSubject.close();
  }

  int getChannelValue(int channel) {
    if (channel < 0 || channel > 511) {
      throw ArgumentError('Channel must be between 1 and 256');
    }
    return channelValues.value[channel];
  }

  int get totalChannels => channelValues.value.length;

  void _queueOrSend(MapEntry<int, int> entry) {
    if (_isSending) {
      // Replace any queued update with the newest one — we only care about
      // sending the latest state for a channel.
      _queuedUpdate = entry;
      return;
    }

    // Not currently sending, perform the send and await completion so we can
    // serialize access to the Bluetooth connection.
    _doSend(entry);
  }

  Future<void> _doSend(MapEntry<int, int> entry) async {
    _isSending = true;
    final channel = entry.key;
    final value = entry.value;
    final message = '<${channel + 1},$value>';
    debugPrint('Sending DMX message: $message');
    final bytes = List<int>.from(message.codeUnits);

    try {
      // Await the send so we don't overwhelm the underlying transport with
      // many concurrent requests. This keeps the UI responsive while
      // serializing Bluetooth operations.
      await bluetooth.sendData(bytes);
    } catch (e, st) {
      debugPrint('Error sending DMX message: $e\n$st');
    } finally {
      _isSending = false;
      // If an update arrived while we were sending, send the latest one now.
      if (_queuedUpdate != null) {
        final next = _queuedUpdate!;
        _queuedUpdate = null;
        // Fire-and-forget the next send (it will set _isSending again).
        _doSend(next);
      }
    }
  }
}
