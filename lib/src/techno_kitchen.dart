import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:techno_kitchen_dart/src/config.dart';
import 'package:techno_kitchen_dart/techno_kitchen_dart.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TechnoKitchen {
  late final TechnoKitchenClient _client;
  late final MusicData _musicData;
  late final ArcadeInfo _arcadeInfo;

  TechnoKitchen() {
    _client = TechnoKitchenClient.defaultValues();
    _musicData = MusicData.defaultData();
    _arcadeInfo = ArcadeInfo.defaultInfo();
  }

  TechnoKitchen.custom(
    TechnoKitchenClient client,
    MusicData musicData,
    ArcadeInfo arcadeInfo,
  ) {
    _client = client;
    _musicData = musicData;
    _arcadeInfo = arcadeInfo;
  }

  get client => _client;
  get musicData => _musicData;
  get arcadeInfo => _arcadeInfo;

  Future<String> getUserId(String qrCode) async {
    return (await _client.qrApi(qrCode))['userID'] as String;
  }

  Future<String> login(int userId, int timestamp) async {
    final data = {
      "userId": userId,
      "accessCode": "",
      "regionId": _arcadeInfo.regionId,
      "placeId": _arcadeInfo.placeId,
      "clientId": _arcadeInfo.clientId,
      "dateTime": timestamp,
      "isContinue": false,
      "genericFlag": 0,
    };

    String result = await _client.sdgbApi(
      jsonEncode(data),
      "UserLoginApi",
      userId,
    );

    return result;
  }

  Future<String> logout(int userId, int timestamp) async {
    final data = {
      "userId": userId,
      "accessCode": "",
      "regionId": _arcadeInfo.regionId,
      "placeId": _arcadeInfo.placeId,
      "clientId": _arcadeInfo.clientId,
      "dateTime": timestamp,
      "type": 1,
    };

    final result = await _client.sdgbApi(
      jsonEncode(data),
      "UserLogoutApi",
      userId,
    );

    return result;
  }

  Future<String> preview(int userId) async {
    final data = {"userId": userId};

    final result = await _client.sdgbApi(
      jsonEncode(data),
      "GetUserPreviewApi",
      userId,
    );

    return result;
  }

  Future<String> userdata(int userId) async {
    final data = {"userId": userId};

    final result = await _client.sdgbApi(
      jsonEncode(data),
      "GetUserDataApi",
      userId,
    );

    return result;
  }

  Future<String> getTicket(int userId, int multiplier) async {
    tzdata.initializeTimeZones();
    final shanghai = tz.getLocation('Asia/Shanghai');
    final now = tz.TZDateTime.now(shanghai).subtract(Duration(hours: 1));
    final purchaseDate = DateFormat("yyyy-MM-dd HH:mm:ss.0").format(now);
    final validDate = DateFormat("yyyy-MM-dd").format(
      now.add(Duration(days: 90)),
    ) + " 04:00:00";

  // 根据倍数确定票种信息
    final chargeId = multiplier == 3 ? 3 : 6;
    final price = multiplier == 3 ? 2 : 4;

    final data = {
      "userId": userId,
      "userCharge": {
        "chargeId": chargeId,
        "stock": 1,
        "purchaseDate": purchaseDate,
        "validDate": validDate,
      },
      "userChargelog": {
        "chargeId": chargeId,
        "price": price,
        "purchaseDate": purchaseDate,
        "placeId": _arcadeInfo.placeId,
        "regionId": _arcadeInfo.regionId,
        "clientId": _arcadeInfo.clientId,
      },
    };

    final result = await _client.sdgbApi(
      jsonEncode(data),
      "UpsertUserChargelogApi",
      userId,
    );
    return result;
}
}
