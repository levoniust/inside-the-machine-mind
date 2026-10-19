import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/tiny_net.dart';

void main() {
  test('gradient descent lowers the loss and learns the ring', () {
    final data = ringDataset();
    final net = TinyNet(seed: 1);
    final before = net.loss(data);
    for (var i = 0; i < 1500; i++) {
      net.trainStep(data, 0.8);
    }
    expect(net.loss(data), lessThan(before * 0.5));
    expect(net.accuracy(data), greaterThan(0.9));
  });

  test('backprop gradient matches a numerical gradient', () {
    final data = ringDataset(n: 20);
    final a = TinyNet(seed: 5);
    // Numerical derivative of the loss with respect to w2[0].
    const eps = 1e-5;
    final w = a.w2[0];
    a.w2[0] = w + eps;
    final up = a.loss(data);
    a.w2[0] = w - eps;
    final down = a.loss(data);
    a.w2[0] = w;
    final numeric = (up - down) / (2 * eps);
    // One SGD step with lr=1 changes w2[0] by exactly -gradient.
    a.trainStep(data, 1.0);
    final analytic = w - a.w2[0];
    expect(analytic, closeTo(numeric, 1e-4));
  });

  test('parameter count is 33 for 8 hidden neurons', () => expect(TinyNet().parameterCount, 33));
}
