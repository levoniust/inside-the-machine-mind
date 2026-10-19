# AGENTS.md: rules for coding agents working on this app

Inside the Machine Mind is a Flutter (Dart) Android app that teaches how LLMs are built. It is fully offline and has no network calls.

## Before you write code
- Read `lib/screens/s1/s1_storage.dart` and `test/screens/s1_storage_test.dart`. **They are the reference pattern.** Copy their structure.
- Shared widgets live in `lib/widgets/` (`LessonScaffold`, `DemoCard`, `FactCard`, `KeyIdea`, `LabeledSlider`, `StatTile`, `StatGrid` (use it instead of GridView for tiles), `CompareBars`/`BarItem`, `StepControls`, `SectionTag`, `TermText`, `BitAvatar`/`BitSays`) plus the helpers `humanNumber`, `humanBytes` and `humanSeconds`. Use them; don't reinvent them.
- Colors come only from `AppColors.of(context)` (`c.cyan`, `c.violet`, `c.magenta`, `c.lime`, `c.amber`, `c.red`, `c.text`, `c.textDim`, `c.surface`, `c.surfaceHi`, `c.line`, `c.bg`). Never hard-code colors except inside painters, where you take them from AppColors. Spacing uses `Gap.*`. Monospace numbers use `AppText.mono`.

## A lesson screen
- File `lib/screens/s<N>/<lesson_id>.dart`, class `<PascalCase>Screen` (e.g. `s1_ram` → `S1RamScreen`), `const` constructor.
- `build` returns `LessonScaffold(lessonId: '<lesson_id>', children: [...])`. Don't add an AppBar, Bit's intro, the key idea or navigation: LessonScaffold does all of that (the narration comes from `lib/content/narration.dart`).
- The children are the **interactive** part: 2–4 `DemoCard`s with custom painters, sliders, buttons and animations, plus `FactCard`s for headline numbers.
- **Numbers:** only use values from `lib/content/facts.dart` (verified). Pass `factId:` to `FactCard`. Never invent statistics. Arithmetic that derives from verified numbers is fine (show the formula).
- Glossary terms in text: `[[term]]` inside strings rendered by `TermText`/`FactCard` labels. Only use terms that exist in `lib/content/glossary.dart`.
- Animations: an `AnimationController` in a `State` with `SingleTickerProviderStateMixin`. Stop looping animations when `MediaQuery.maybeDisableAnimationsOf(context) == true` (see s1_storage). Always dispose controllers.
- Painters: a `CustomPainter` with a correct `shouldRepaint`. Wrap canvases in `Semantics(label: ...)` describing what is shown.
- Layout must work from 360 dp wide phones to tablets, and at text scale 1.3. Use `Expanded`/`Flexible`/`Wrap`/`FittedBox` to avoid overflow. No fixed widths above 320.
- Give interactive widgets `ValueKey`s (e.g. `ValueKey('ram-channels-slider')`) so tests can find them.
- Register the screen: add an import + one line in `lib/screens/screen_registry.dart` (keep journey order).

## Tests (required for every screen)
- `test/screens/<lesson_id>_test.dart`, using `pumpApp`, `pumpFrames`, `tapVisible`, `scrollTo` and `expectNoErrors` from `test/helpers.dart`. Lesson lists are lazy: a card further down doesn't exist until scrolled to, so call `scrollTo(tester, finder)` before `expect`ing anything below the first card (`tapVisible` scrolls by itself). **Don't use pumpAndSettle** (looping animations never settle).
- At least: (1) it renders its main title/text; (2) the main interaction changes what is shown (tap/drag, then expect new text); (3) no errors at `textScale: 1.3` with `brightness: Brightness.light`.
- To drag a slider: `await tester.drag(find.byKey(...), const Offset(200, 0)); await tester.pump();`

## Done means
- `flutter analyze` → **No issues found!**
- `flutter test` → **All tests passed!** (the whole suite, not just yours)
- Don't edit files outside your task, don't delete tests, don't weaken existing tests, and don't touch `lib/content/facts.dart` (it's generated).
- Don't commit or push; the orchestrator reviews and commits.
