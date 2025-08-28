import 'dart:convert';

void printUserPreviewDescription(String userPreviewJson) {
  try {
    final data = jsonDecode(userPreviewJson);
    final userName = data['userName'];
    final isLogin = data['isLogin'] ? '已登录' : '未登录';
    final playerRating = data['playerRating'];
    final lastRomVersion = data['lastRomVersion'] ?? '未知';
    final lastDataVersion = data['lastDataVersion'] ?? '未知';
    String gameVersion = '未知版本';
    if (lastRomVersion != null && lastDataVersion != null) {
      final romParts = lastRomVersion.split('.');
      final dataParts = lastDataVersion.split('.');
      if (romParts.length >= 2) {
        gameVersion = '${romParts[0]}.${romParts[1]}';
        if (dataParts.length >= 3) {
          final minorVersion = int.tryParse(dataParts[2]) ?? 0;
          if (minorVersion >= 1 && minorVersion <= 26) {
            final suffix = String.fromCharCode(64 + minorVersion);
            gameVersion += '-$suffix';
          }
        }
      }
    }
    final banState = data['banState'];
    String banStatus;
    switch (banState) {
      case 0:
        banStatus = '正常';
        break;
      case 1:
        banStatus = '警告';
        break;
      case 2:
        banStatus = '封禁';
        break;
      default:
        banStatus = '未知状态($banState)';
    }
    print('用户名: $userName Rating: $playerRating 登录状态: $isLogin 游戏版本: $gameVersion 账号状态: $banStatus');
  } catch (e) {
    print('解析 userpreview 数据时出错: $e');
  }
}