import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recommendation_pack.dart';

class RecommendationCacheService {
  const RecommendationCacheService();

  static const _packKey = 'kx.recommendations.weekly_pack.v1';

  Future<RecommendationPack?> cachedPack() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_packKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }
    return RecommendationPack.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> savePack(RecommendationPack pack) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_packKey, jsonEncode(pack.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_packKey);
  }
}
