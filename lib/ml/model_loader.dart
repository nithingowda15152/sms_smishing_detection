import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SmishModel {
  final Map<String, int> vocab;   // word → index
  final List<double> coefficients;
  final double intercept;
  final double threshold;

  SmishModel({
    required this.vocab,
    required this.coefficients,
    required this.intercept,
    required this.threshold,
  });

  static Future<SmishModel> load() async {
  final jsonString = await rootBundle.loadString("assets/model_new.json");
  final data = jsonDecode(jsonString);

  return SmishModel(
    vocab: Map<String, int>.from(data["vocab"] ?? {}),

    // 🔥 FIX: read "weights" instead of "coefficients"
    coefficients: List<double>.from(
      (data["weights"] ?? []).map((x) => (x as num).toDouble()),
    ),

    // 🔥 FIX: read "bias" instead of "intercept"
    intercept: (data["bias"] as num?)?.toDouble() ?? 0.0,

    threshold: (data["threshold"] as num?)?.toDouble() ?? 0.5,
  );
}
}
