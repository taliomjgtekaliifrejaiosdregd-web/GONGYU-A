import 'package:flutter/material.dart';

class AppConstants {
  // App 信息
  static const String appName = '自优租';
  static const String appVersion = '1.0.0';

  // 手机号长度
  static const int phoneNumberLength = 11;

  // SharedPreferences Keys
  static const String tokenKey = 'user_token';
  static const String userRoleKey = 'user_role';  // tenant | landlord
  static const String userInfoKey = 'user_info';
  static const String themeKey = 'app_theme';

  // 房源类型
  static const List<String> roomTypes = ['全部', '整租', '合租', '公寓'];

  // 排序方式
  static const List<String> sortOptions = ['默认排序', '价格低→高', '价格高→低', '最新发布'];

  // 页面路由
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeTenantHome = '/tenant/home';
  static const String routeLandlordHome = '/landlord/home';
}
