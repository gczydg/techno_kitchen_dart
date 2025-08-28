import 'dart:convert';

bool printUpsertUserChargeResponse(String userChargeJson) {
  try {
    final data = jsonDecode(userChargeJson);
    final returnCode = data['returnCode'];
    if (returnCode == 1) {
      print('发票成功');
      return true;
    } else {
      print('发票失败或账号内已有该功能票');
    }
    return false;
  } catch (e) {
    print('解析 userlogin 数据时出错: $e');
    return false;
  }
}