import 'package:flutter/material.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MQTTState with ChangeNotifier {
  MQTTConnectionState _connectionState = MQTTConnectionState.disconnected;

  String _rcvMsg = "";
  String _hstMsg = "";

  void setReceivedMsg(String msg) {
    _rcvMsg = msg;
    print(msg);
    _hstMsg = _hstMsg + '\n' + _rcvMsg;
    notifyListeners();
  }

  void setConnectionState(MQTTConnectionState state) {
    _connectionState = state;
    notifyListeners();
  }

  String get getReceivedMsg => _rcvMsg;
  String get getHistoryMsg => _hstMsg;
  MQTTConnectionState get getConnectionState => _connectionState;
}
