import 'dart:convert';

void printUserChargeDescription(String userChargeJson) {
  try {
    if (userChargeJson.isEmpty) {
      print('账号内没有票');
      return;
    }
    final data = jsonDecode(userChargeJson);
    if (data == null) {
      print('账号内没有票');
      return;
    }
    final userChargeList = data['userChargeList'] as List?;
    if (userChargeList == null || userChargeList.isEmpty) {
      print('账号内没有票');
      return;
    }
    const chargeIdMap = {
      2: '二倍功能票',
      3: '三倍功能票',
      4: '四倍功能票',
      5: '五倍功能票',
      6: '六倍功能票',
    };
    bool hasAnyTicket = false;
    bool hasDataAnomaly = false;
    List<String> ticketDescriptions = [];
    List<String> anomalyDescriptions = [];
    for (final charge in userChargeList) {
      final chargeId = charge['chargeId'] as int;
      final stock = charge['stock'] as int;
      final name = chargeIdMap[chargeId] ?? '未知功能票(chargeId: $chargeId)';
      if (stock != 0 && stock != 1) {
        hasDataAnomaly = true;
        anomalyDescriptions.add('$name 的stock值为$stock（应为0或1）');
      } else if (stock == 1) {
        hasAnyTicket = true;
        ticketDescriptions.add('账号已有1张$name');
      }
    }
    if (hasDataAnomaly) {
      print('警告：检测到账号数据异常！可能存在非法操作！');
      for (final anomaly in anomalyDescriptions) {
        print('异常: $anomaly');
      }
    }
    if (hasAnyTicket) {
      for (final description in ticketDescriptions) {
        print(description);
      }
    } else if (!hasDataAnomaly) {
      print('账号内没有票');
    }
  } catch (e) {
    print('解析 usercharge 数据时出错: $e');
  }
}