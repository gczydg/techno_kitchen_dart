import 'dart:io'; 
import 'dart:convert';
import 'package:techno_kitchen_dart/techno_kitchen_dart_web.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
void main() async {
  tzdata.initializeTimeZones();
  final technoKitchen = TechnoKitchen();
  final client = technoKitchen.client;
  final milliseconds = DateTime.now().millisecondsSinceEpoch;
  final timestampsinmai = milliseconds ~/ 1000;
  print('当前时间戳: $timestampsinmai');
  final input = stdin.readLineSync();
  int userId;
  // Step 1: getUserId
  if (input!.startsWith('SGWCMAID') && input.length == 84) {
    print('Type:qrCode');
    final qrResponse = await client.qrApi(input);
    print('qrResponse: ${jsonEncode(qrResponse)}');
    if (qrResponse['errorID'] != 0) {
      print('解析失败，二维码过期');
      return;
    } else{
      print('解析成功, userID: ${qrResponse['userID']}');
    }
    userId = int.parse(qrResponse['userID'].toString());
  } else if (input.length == 8 && int.tryParse(input) != null) {
    print('Type:userID');
    userId = int.parse(input);
  } else {
    print('输入格式错误');
    return;
  }
  // Step 1.1: checkWhitelist
  final hasPermission = await checkWhitelist(userId);
  if (!hasPermission) {
    return;
  }
  // Step 2: preview
  final preview = await technoKitchen.preview(userId);
  printUserPreviewDescription(preview);
  try {
    final previewData = jsonDecode(preview);
    final isLogin = previewData['isLogin'] as bool;
    if (isLogin) {
      print('当前账号已登录，请先解小黑屋');
      return;
    }
  } catch (e) {
    print('解析preview数据时出错: $e');
  }
  // Step 3: login
  final login = await technoKitchen.login(userId, timestampsinmai);
  final loginSuccess = printUserLoginDescription(login);
  if (loginSuccess) {
    // Step 4: TaskCheck
    print('waiting for request……');
    final ticketidinput = stdin.readLineSync();
    // Step 4.1: GetUserCharge
    if (ticketidinput == 'GetUserCharge') {
      final usercharge = await technoKitchen.getUsercharge(userId);
      printUserChargeDescription(usercharge);
    } else if (ticketidinput == null || (ticketidinput != '3' && ticketidinput != '6' && ticketidinput != 'GetUserCharge')) {
      print('输入无效,自动登出');
    } else {
      // Step 4.9: getTicket
      final ticketid = ticketidinput;
      final UpsertUserCharge = await technoKitchen.getTicket(userId, int.parse(ticketid));
      printUpsertUserChargeResponse(UpsertUserCharge);
    }
    // Step 5: logout
    await technoKitchen.logout(userId, timestampsinmai);
    // Step 6: checkisloginstatus
    final preview = await technoKitchen.preview(userId);
    try {
      final previewData = jsonDecode(preview);
      final isLogin = previewData['isLogin'] as bool;
      if (isLogin) {
        print('登出失败，请用时间戳重试');
        print('Timestamp: $timestampsinmai');
        await Future.delayed(Duration(seconds: 30));
        return;
      } else {
        print('登出成功');
      }
    } catch (e) {
      print('解析preview数据时出错: $e');
    }
  }
}
