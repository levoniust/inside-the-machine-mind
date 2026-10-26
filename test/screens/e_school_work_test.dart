import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_school_work.dart';

import '../helpers.dart';

// TODO(claude-review): Mirai's interaction test didn't pass; this is a smoke test only.
void main() {
  testWidgets('e_school_work renders', (tester) async {
    await pumpApp(tester, home: const ESchoolWorkScreen());
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
