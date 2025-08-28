import 'dart:convert';

bool printUserLoginDescription(String userLoginJson) {
  try {
    final data = jsonDecode(userLoginJson);
    final returnCode = data['returnCode'];
    final loginId = data['loginId'];
    if (returnCode == 1) {
      print('登录成功,loginId: $loginId');
      return true;
    } else if (returnCode == 102) {
      print('登录失败，二维码超时');
    } else if (returnCode == 100) {
      print('登录失败，账号已登录');
    } else if (returnCode == 103) {
      print('登录失败，账号不存在');
    } else {
      print('登录失败，未知错误');
    }
    return false;
  } catch (e) {
    print('解析 userlogin 数据时出错: $e');
    return false;
  }
}