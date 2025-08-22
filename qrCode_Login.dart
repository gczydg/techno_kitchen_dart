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
  print('Timestamp: $timestampsinmai');
  print('请输入qrCode或userID:');
  final input = stdin.readLineSync();
  int userId;
  // Step 1: getUserId
  if (input!.startsWith('SGWCMAID') && input.length == 84) {
    print('Type:qrCode');
    final qrResponse = await client.qrApi(input);
    print('qrResponse: ${jsonEncode(qrResponse)}');
    if (qrResponse['errorID'] != 0) {
      print('解析失败，二维码过期');
      print('5秒后自动退出');
      await Future.delayed(Duration(seconds: 5));
      return;
    }
    userId = int.parse(qrResponse['userID'].toString());
  } else if (input.length == 8 && int.tryParse(input) != null) {
    print('Type:userID');
    userId = int.parse(input);
  } else {
    print('输入格式错误');
    print('5秒后自动退出');
    await Future.delayed(Duration(seconds: 5));
    return;
  }
  // Step 2: preview
  final preview = await technoKitchen.preview(userId);
  print('UserPreview:$preview');
  // Step 3: login
  final login = await technoKitchen.login(userId, timestampsinmai);
  print('UserLogin: $login');
  if (login.startsWith('{"returnCode":1,')) {
    // Step 4: getTicket
    print('请输入功能票倍数（3或6）:');
    final ticketidinput = stdin.readLineSync();
    if (ticketidinput == null || (ticketidinput != '3' && ticketidinput != '6')) {
      print('输入无效,自动登出');
      final logout = await technoKitchen.logout(userId, timestampsinmai);
      print('UserLogout: $logout');
      print('5秒后自动退出');
      await Future.delayed(Duration(seconds: 5));
    } else {
      final ticketid = ticketidinput;
      final getTicket = await technoKitchen.getTicket(userId, int.parse(ticketid));
      print('GetTicket: $getTicket');
      if (getTicket.startsWith('{"returnCode":1,')) {
      print('发票成功');
      } else {
        print('发票失败或账号内已有一张付费功能票');
      }
    // Step 5: logout
    final logout = await technoKitchen.logout(userId, timestampsinmai);
    print('UserLogout: $logout');
    print('5秒后自动退出');
    await Future.delayed(Duration(seconds: 5));
    }
  } else {
    print('登录失败，二维码超时');
    print('5秒后自动退出');
    await Future.delayed(Duration(seconds: 5));
  }
}