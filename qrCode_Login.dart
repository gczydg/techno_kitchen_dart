import 'dart:convert';
import 'package:techno_kitchen_dart/techno_kitchen_dart.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'dart:io'; 

void main() async {
  tzdata.initializeTimeZones();

  final technoKitchen = TechnoKitchen();
  final client = technoKitchen.client;
  final milliseconds = DateTime.now().millisecondsSinceEpoch;
  final timestampsinmai = milliseconds ~/ 1000;
  print('当前时间戳: $timestampsinmai');
  // === Step 1: Get UserId by QR Code ===
    print('请输入qrCode:');
    final input = stdin.readLineSync();
    final qrCode = input!;
    final qrResponse = await client.qrApi(qrCode);
    print('QR Login Response:');
    print(jsonEncode(qrResponse));
    if (qrResponse['errorID'] != 0) {
      print('登陆失败，二维码失效，请获取新的二维码');
      return;
    }
    final userId = qrResponse['userID'];
    // === Step 2: preview ===
    final preview = await technoKitchen.preview(userId);
    print(preview);
    print('');
    print('');
    // === Step 3: login ===
    final login = await technoKitchen.login(userId,timestampsinmai);
    print(login);
    // === Step 4: getTicket ===
    print('请输入付费券倍数（3或6）:');
    final ticketidinput = stdin.readLineSync();
    final ticketid = ticketidinput!;
    final getTicket = await technoKitchen.getTicket(userId, int.parse(ticketid));
    print(getTicket);
    print('ReturnCode=1代表发票成功，ReturnCode=0代表发票失败或账号内已有一张付费券');
    print('');
    print('');
    // === Step 5: logout ===
    final logout = await technoKitchen.logout(userId,timestampsinmai);
    print(logout);
    print('');
    print('');
    print('5秒后自动退出');
    await Future.delayed(Duration(seconds: 5));
}
