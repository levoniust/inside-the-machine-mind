import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/toy_transformer.dart';

void main() {
  final run = ToyTransformer().run();

  test('the toy model predicts "blue" after "why is the sky"', () {
    expect(run.probabilities().first.key, 'blue');
  });

  test('attention rows sum to 1 and never look ahead', () {
    for (var i = 0; i < run.attention.length; i++) {
      expect(run.attention[i].fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
      for (var j = i + 1; j < run.attention[i].length; j++) {
        expect(run.attention[i][j], 0);
      }
    }
  });

  test('probabilities sum to 1; high temperature flattens them', () {
    final p1 = run.probabilities();
    expect(p1.fold<double>(0, (a, e) => a + e.value), closeTo(1, 1e-9));
    final hot = run.probabilities(temperature: 5);
    expect(hot.first.value, lessThan(p1.first.value));
  });
}
