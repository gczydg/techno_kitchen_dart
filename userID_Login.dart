import 'package:techno_kitchen_dart/techno_kitchen_dart.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'dart:io'; 

void main() async {
  tzdata.initializeTimeZones();

  final technoKitchen = TechnoKitchen();
    print('请输入userId:');
    final input = stdin.readLineSync();
    final userId = int.parse(input!);

    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final timestampsinmai = milliseconds ~/ 1000;

    // === Step 2: preview ===
    final preview = await technoKitchen.preview(userId);
    print(preview);
    print('');
    print('');
    // === Step 3: login ===
    final login = await technoKitchen.login(userId,timestampsinmai);
    print(login);
    print('response=1代表登陆成功');
    print('response=102代表二维码过期登陆失败');
    print('');
    print('');
    // === Step 4: getTicket ===
    final getTicket = await technoKitchen.getTicket(userId);
    print(getTicket);
    print('response=1代表发票成功');
    print('response=0代表发票失败或账号内已有一张付费券');
    print('');
    print('');
    // === Step 5: logout ===
    final logout = await technoKitchen.logout(userId,timestampsinmai);
    print(logout);
    print('response=1代表登出成功');
    print('response=0代表登出失败');
    print('');
    print('');
    print('5秒后自动退出');
    await Future.delayed(Duration(seconds: 5));
}