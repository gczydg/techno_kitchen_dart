import 'dart:convert';

void printUserChargeDescription(String userChargeJson) {
  try {
    final data = jsonDecode(userChargeJson);
    final userChargeList = data['userChargeList'] as List;
    const chargeIdMap = {
      2: '二倍功能票',
      3: '三倍功能票',
      4: '四倍功能票',
      5: '五倍功能票',
      6: '六倍功能票',
    };
    print('用户功能票库存详情:');
    for (final charge in userChargeList) {
      final chargeId = charge['chargeId'] as int;
      final stock = charge['stock'] as int;
      final name = chargeIdMap[chargeId] ?? '未知功能票(chargeId: $chargeId)';
      print('$name: $stock张');
    }
  } catch (e) {
    print('解析 usercharge 数据时出错: $e');
    print('原始数据: $userChargeJson');
  }
}