import 'dart:convert';
import 'package:techno_kitchen_dart/techno_kitchen_dart.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'dart:io'; 

void main() async {
  tzdata.initializeTimeZones();

  final technoKitchen = TechnoKitchen();
  final client = technoKitchen.client;

  // === Step 1: Get UserId by QR Code ===
    print('请输入qrCode:');
    final input = stdin.readLineSync();
    final qrCode = input!;

  try {
    final qrResponse = await client.qrApi(qrCode);

    print('QR Login Response:');
    print(jsonEncode(qrResponse));

    if (qrResponse['errorID'] != 0) {
      print('QR login failed with errorID: ${qrResponse['errorID']}');
      return;
    }

    final userId = qrResponse['userID'];
    print('Got userID: $userId');

    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final timestampsinmai = milliseconds ~/ 1000;

    // === Step 2: Fetch User Preview Info ===
    final preview = await technoKitchen.preview(userId);
    print('preview:');
    print(preview);
    // === Step 3: login ===
    final login = await technoKitchen.login(userId,timestampsinmai);
    print('login:');
    print(login);
    // === Step 4: getTicket ===
    final getTicket = await technoKitchen.getTicket(userId);
    print('getTicket:');
    print(getTicket);
    // === Step 5: logout ===
    final logout = await technoKitchen.logout(userId,timestampsinmai);
    print('logout:');
    print(logout);
  } catch (e) {
    print('An error occurred: $e');
  }
}