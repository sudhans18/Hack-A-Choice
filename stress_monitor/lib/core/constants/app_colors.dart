import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary colors
  static const primary = Color(0xFF1E3A5F);
  static const primaryLight = Color(0xFF2E5A8F);
  static const primaryDark = Color(0xFF0E2A4F);

  // Risk level colors
  static const riskLow = Color(0xFF10B981);
  static const riskModerate = Color(0xFFF59E0B);
  static const riskHigh = Color(0xFFEF4444);

  // Background colors
  static const backgroundLight = Color(0xFFF8FAFC);
  static const backgroundDark = Color(0xFF0F172A);

  // Surface colors
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1E293B);

  // Card colors
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E293B);

  // Text colors
  static const textPrimaryLight = Color(0xFF1E293B);
  static const textSecondaryLight = Color(0xFF64748B);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);

  // Gradient colors
  static const gradientStart = Color(0xFF1E3A5F);
  static const gradientEnd = Color(0xFF3B82F6);

  // Chart colors
  static const chartBlue = Color(0xFF3B82F6);
  static const chartPurple = Color(0xFF8B5CF6);
  static const chartPink = Color(0xFFEC4899);
  static const chartOrange = Color(0xFFF97316);

  // Get risk color based on score
  static Color getRiskColor(int score) {
    if (score <= 30) return riskLow;
    if (score <= 60) return riskModerate;
    return riskHigh;
  }
}
