import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:flutter_bluetooth_dmx/screens/device_based_dmx_universe_controller_screen.dart';
import 'package:flutter_bluetooth_dmx/providers/dmx_Controller_provider.dart';
import 'package:flutter_bluetooth_dmx/screens/manual_dmx_control_screen.dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late FlutterBluetoothClassic _bluetooth;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _isBluetoothEnabled = false;
  bool _isConnected = false;
  String _receivedData = '';
  final TextEditingController _messageController = TextEditingController();

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BluetoothData>? _dataSubscription;
  StreamSubscription<BluetoothState>? _stateSubscription;
  late DmxControllerProvider model;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bluetooth = Provider.of<DmxControllerProvider>(context).bluetooth;
    _initBluetooth();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _stateSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    // Check Bluetooth status
    bool isSupported = await _bluetooth.isBluetoothSupported();
    bool isEnabled = await _bluetooth.isBluetoothEnabled();

    setState(() {
      _isBluetoothEnabled = isEnabled;
    });

    if (isSupported && isEnabled) {
      await _loadDevices();
      _setupListeners();
    }
  }

  void _setupListeners() {
    // Listen for Bluetooth state changes
    _stateSubscription = _bluetooth.onStateChanged.listen((state) {
      setState(() {
        _isBluetoothEnabled = state.isEnabled;
      });
    });

    // Listen for connection changes
    _connectionSubscription =
        _bluetooth.onConnectionChanged.listen((connectionState) {
      setState(() {
        debugPrint('Connection state changed: $connectionState');
        _isConnected = connectionState.isConnected;
        if (connectionState.isConnected) {
          _connectedDevice = _devices.firstWhere(
            (device) => device.address == connectionState.deviceAddress,
            orElse: () => BluetoothDevice(
              name: 'Unknown Device',
              address: connectionState.deviceAddress,
              paired: false,
            ),
          );
        } else {
          _connectedDevice = null;
        }
      });

      // Show connection status
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(connectionState.isConnected
                ? 'Connected to ${_connectedDevice?.name}'
                : 'Disconnected: ${connectionState.status}'),
            backgroundColor:
                connectionState.isConnected ? Colors.green : Colors.red,
          ),
        );
      }
    });

    // Listen for incoming data
    _dataSubscription = _bluetooth.onDataReceived.listen((data) {
      setState(() {
        _receivedData += data.asString();
      });
    });
  }

  Future<void> _loadDevices() async {
    try {
      List<BluetoothDevice> devices = await _bluetooth.getPairedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      _showError('Failed to load devices: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      bool success = await _bluetooth.connect(device.address);
      if (!success) {
        _showError('Failed to connect to ${device.name}');
      }
    } catch (e) {
      _showError('Connection error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      if (await _bluetooth.disconnect()) {
        setState(() {
          _isConnected = false;
          _connectedDevice = null;
        });
      } else {
        _showError('Disconnect did not succeed');
      }
    } catch (e) {
      _showError('Disconnect error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || !_isConnected) return;

    try {
      bool success = await _bluetooth
          .sendData(List<int>.from(_messageController.text.codeUnits));
      if (success) {
        setState(() {
          _receivedData += 'Sent: ${_messageController.text}\n';
        });
        _messageController.clear();
      } else {
        _showError('Failed to send message');
      }
    } catch (e) {
      _showError('Send error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Classic Demo'),
        actions: [
          IconButton(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Manual DMX Control',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualDmxControlScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_display_rounded),
            tooltip: 'Manual DMX Control',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DeviceBasedDmxUniverseControllerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: !_isBluetoothEnabled
          ? const Center(
              child: Text('Please enable Bluetooth'),
            )
          : Column(
              children: [
                // Connection Status
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color: _isConnected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(_isConnected
                            ? 'Connected to ${_connectedDevice?.name}'
                            : 'Not connected'),
                        const Spacer(),
                        if (_isConnected)
                          ElevatedButton(
                            onPressed: _disconnect,
                            child: const Text('Disconnect'),
                          ),
                      ],
                    ),
                  ),
                ),

                // Device List
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Paired Devices',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              BluetoothDevice device = _devices[index];
                              bool isConnectedDevice =
                                  _connectedDevice?.address == device.address;

                              return ListTile(
                                leading: Icon(
                                  Icons.bluetooth,
                                  color:
                                      isConnectedDevice ? Colors.green : null,
                                ),
                                title: Text(device.name),
                                subtitle: Text(device.address),
                                trailing: isConnectedDevice
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: _isConnected
                                            ? null
                                            : () => _connectToDevice(device),
                                        child: const Text('Connect'),
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Message Input
                if (_isConnected)
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Enter message',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _sendMessage,
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Received Data
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const Text('Received Data',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _receivedData = ''),
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _receivedData.isEmpty
                                    ? 'No data received'
                                    : _receivedData,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
