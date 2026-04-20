// ============================================================
// 智租SaaS - 全局主题配置
// ============================================================

import 'package:flutter/material.dart';

/// 智租SaaS品牌色
class AppColors {
  // 主色系 - 靛蓝紫
  static const Color primary = Color(0xFF4F6AF2);       // 主色
  static const Color primaryDark = Color(0xFF3451D1);    // 深主色
  static const Color primaryLight = Color(0xFFA5B4FC);  // 浅主色
  static const Color primaryBg = Color(0xFFEEF2FF);     // 主色背景

  // 功能色
  static const Color success = Color(0xFF10B981);         // 绿色 - 正常/收入
  static const Color warning = Color(0xFFF59E0B);        // 橙色 - 预警/待处理
  static const Color danger = Color(0xFFEF4444);         // 红色 - 危险/逾期/错误
  static const Color info = Color(0xFF06B6D4);           // 青色 - 信息/链接

  // 中性色
  static const Color background = Color(0xFFF5F7FA);      // 页面背景
  static const Color cardBg = Color(0xFFFFFFFF);         // 卡片背景
  static const Color border = Color(0xFFE5E7EB);         // 边框色
  static const Color textPrimary = Color(0xFF111827);   // 主文字
  static const Color textSecondary = Color(0xFF6B7280); // 次要文字
  static const Color textHint = Color(0xFF9CA3AF);      // 提示文字
  static const Color textDisabled = Color(0xFFD1D5DB);  // 禁用文字

  // 标签色
  static const Color tagRented = Color(0xFF10B981);      // 已出租
  static const Color tagAvailable = Color(0xFF6366F1);  // 未出租
  static const Color tagExpiring = Color(0xFFF59E0B);   // 即将到期
  static const Color tagOverdue = Color(0xFFEF4444);    // 逾期
  static const Color tagSigning = Color(0xFF06B6D4);    // 签订中
}

/// 字体大小常量
class AppSizes {
  static const double fontXs = 10.0;
  static const double fontSm = 11.0;
  static const double fontBase = 12.0;
  static const double fontMd = 13.0;
  static const double fontLg = 14.0;
  static const double fontXl = 16.0;
  static const double font2xl = 18.0;
  static const double font3xl = 20.0;
  static const double font4xl = 24.0;

  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;

  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double icon2xl = 40.0;
}

/// 全局主题
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        surface: AppColors.cardBg,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: AppSizes.fontXs),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: AppSizes.fontBase,
          color: AppColors.textHint,
        ),
        isDense: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: AppSizes.fontSm),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppSizes.font3xl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.font2xl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontMd,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontBase,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: AppSizes.fontXs,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
