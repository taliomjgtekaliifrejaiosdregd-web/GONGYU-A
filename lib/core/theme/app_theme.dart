import 'package:flutter/material.dart';

class AppTheme {
  // ==================== 科技感高级配色 ====================

  // 主色：靛蓝紫 - 沉稳、科技、信赖感
  static const Color primaryColor = Color(0xFF6366F1);

  // 强调色：青色 - 科技感点缀
  static const Color accentColor = Color(0xFF06B6D4);

  // 背景色：极浅灰蓝
  static const Color bgColor = Color(0xFFF1F5F9);

  // 卡片/表面：纯白
  static const Color surfaceColor = Color(0xFFFFFFFF);

  // 主文字：深墨
  static const Color textPrimary = Color(0xFF1E293B);

  // 次要文字
  static const Color textSecondary = Color(0xFF64748B);

  // 成功色
  static const Color successColor = Color(0xFF10B981);

  // 警告色
  static const Color warningColor = Color(0xFFF59E0B);

  // 错误色
  static const Color errorColor = Color(0xFFEF4444);

  // 渐变色1：用于AppBar、按钮渐变背景
  static const Color gradientStart = Color(0xFF6366F1);
  static const Color gradientEnd = Color(0xFF8B5CF6);

  // TabBar 房屋管理色
  static const Color tabHouse = Color(0xFF6366F1);

  // TabBar 商场管理色
  static const Color tabMall = Color(0xFF06B6D4);

  // 字体缩放因子（0.5倍）
  static const double fontScale = 0.5;

  // 基础字体大小（已缩小）
  static const double fontSizeXs = 9.0;
  static const double fontSizeSm = 10.0;
  static const double fontSizeMd = 11.0;
  static const double fontSizeLg = 12.0;
  static const double fontSizeXl = 14.0;
  static const double fontSizeXxl = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PingFang SC',
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: fontSizeLg,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: fontSizeSm, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: const TextStyle(fontSize: fontSizeSm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: fontSizeSm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: TextStyle(color: textSecondary, fontSize: fontSizeSm),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 0.5,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        labelStyle: const TextStyle(fontSize: fontSizeSm, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: fontSizeSm),
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: fontSizeSm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: fontSizeLg, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: textSecondary, fontSize: fontSizeSm),
      ),
    );
  }
}
