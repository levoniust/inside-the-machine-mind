import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_tools_mcp.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_tools_mcp: stepping through the round trip shows each message', (tester) async {
    await pumpApp(tester, home: const LToolsMcpScreen());
    await scrollTo(tester, find.byKey(const ValueKey('mcp-trip-0')));
    expect(find.textContaining('"inputSchema"'), findsOneWidget);
    await tapVisible(tester, find.byIcon(Icons.chevron_right).first);
    await tester.pump();
    expect(find.byKey(const ValueKey('mcp-trip-1')), findsOneWidget);
    expect(find.textContaining('"tools/call"'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_tools_mcp: a wrong call shows the error; five right calls finish the game', (tester) async {
    await pumpApp(tester, home: const LToolsMcpScreen());
    await scrollTo(tester, find.byKey(const ValueKey('mcp-cand-0-2')));
    await tapVisible(tester, find.byKey(const ValueKey('mcp-cand-0-2')));
    await tester.pump();
    expect(find.textContaining('Unknown tool: weather'), findsOneWidget);
    const right = [1, 2, 0, 1, 1];
    for (var r = 0; r < right.length; r++) {
      await scrollTo(tester, find.byKey(ValueKey('mcp-cand-$r-${right[r]}')));
      await tapVisible(tester, find.byKey(ValueKey('mcp-cand-$r-${right[r]}')));
      await tester.pump();
      if (r < right.length - 1) {
        await tapVisible(tester, find.byKey(const ValueKey('mcp-next')));
        await tester.pump();
      }
    }
    expect(find.textContaining('Right first time: 4 of 5'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_tools_mcp has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LToolsMcpScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
