import 'dart:math';
import 'model_loader.dart';

class SmishClassifier {
  final SmishModel model;

  SmishClassifier(this.model);

  /// ✅ Predict probability between 0 and 1
  double predictProba(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final vector = List.filled(model.coefficients.length, 0);

    for (var word in words) {
      final index = model.vocab[word];
      if (index != null && index < vector.length) {
        vector[index] += 1;
      }

    }

    double score = model.intercept;
    for (int i = 0; i < vector.length; i++) {
      score += model.coefficients[i] * vector[i];
    }

    return 1 / (1 + exp(-score)); // sigmoid function
  }

  /// ✅ Binary classification (true = smishing, false = safe)
  bool predict(String text) {
    final prob = predictProba(text);
    return prob >= threshold;
  }

  /// ✅ Expose threshold (needed by main.dart)
  double get threshold => model.threshold;
}
