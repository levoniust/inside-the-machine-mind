import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Cleaning the library": a messy sample web page goes through five filters one by one
/// (language, quality, duplicates, safety, personal info). Fact: TR-FINEWEB.
class S2CleaningScreen extends StatelessWidget {
  const S2CleaningScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_cleaning',
        children: [_Washer()],
      );
}

enum _Kind { good, foreign, spam, duplicate, toxic, personal }

class _Line {
  const _Line(this.text, this.kind, [this.masked]);
  final String text;
  final _Kind kind;
  final String? masked;
}

const _page = [
  _Line('Why is the sky blue? Sunlight is made of many colors.', _Kind.good),
  _Line('CLICK HERE!!! Win a FREE phone!!! Best deals best deals best deals', _Kind.spam),
  _Line('Air molecules scatter short blue waves more than red ones.', _Kind.good),
  _Line('Le ciel est bleu à cause de la diffusion de la lumière.', _Kind.foreign),
  _Line('Air molecules scatter short blue waves more than red ones.', _Kind.duplicate),
  _Line('Anyone who disagrees with me is an idiot and should be hurt.', _Kind.toxic),
  _Line('Questions? Call Sam at 555-0137 or sam@example.com', _Kind.personal, 'Questions? Call [NAME] at [PHONE] or [EMAIL]'),
  _Line('That is why the sky looks blue during the day.', _Kind.good),
  _Line('Home | About | Contact | Privacy | Cookies | Login', _Kind.spam),
];

class _Filter {
  const _Filter(this.name, this.icon, this.removes, this.explain);
  final String name;
  final IconData icon;
  final _Kind removes;
  final String explain;
}

const _filters = [
  _Filter('Language', Icons.translate, _Kind.foreign, 'Keep the languages this model is meant to learn (here: English).'),
  _Filter('Quality', Icons.thumb_up_alt_outlined, _Kind.spam, 'Drop spam, menus and gibberish that teach nothing useful.'),
  _Filter('De-duplicate', Icons.copy_all, _Kind.duplicate, 'Remove repeats, so the model doesn\'t memorize text it sees too often.'),
  _Filter('Safety', Icons.shield_outlined, _Kind.toxic, 'Filter out hateful or harmful text.'),
  _Filter('Personal info', Icons.person_off_outlined, _Kind.personal, 'Hide names, phone numbers and emails.'),
];

class _Washer extends StatefulWidget {
  const _Washer();

  @override
  State<_Washer> createState() => _WasherState();
}

class _WasherState extends State<_Washer> {
  int _applied = 0; // number of filters applied

  bool _removed(_Line l) {
    for (var i = 0; i < _applied; i++) {
      if (_filters[i].removes == l.kind && l.kind != _Kind.personal) return true;
    }
    return false;
  }

  bool _masked(_Line l) => l.kind == _Kind.personal && _applied >= 5;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final left = _page.where((l) => !_removed(l)).length;
    final cur = _applied == 0 ? null : _filters[_applied - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'A raw web page goes in…',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final l in _page)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _removed(l)
                      ? const SizedBox(width: double.infinity)
                      : Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(Gap.s),
                          decoration: BoxDecoration(
                            color: _masked(l) ? c.lime.withValues(alpha: 0.1) : c.surfaceHi,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _masked(l) ? c.lime.withValues(alpha: 0.6) : c.line),
                          ),
                          child: Text(
                            _masked(l) ? l.masked! : l.text,
                            style: TextStyle(color: c.text, fontSize: 14, fontFamily: l.kind == _Kind.spam ? 'monospace' : null),
                          ),
                        ),
                ),
              const SizedBox(height: Gap.s),
              Text('Lines kept: $left of ${_page.length}', key: const ValueKey('clean-left'),
                  style: AppText.mono.copyWith(color: c.violet, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'The filters',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _filters.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: i < _applied ? c.violet : c.surfaceHi,
                    child: Icon(_filters[i].icon, color: i < _applied ? Colors.white : c.textDim, size: 20),
                  ),
                  title: Text(_filters[i].name, style: TextStyle(fontWeight: i < _applied ? FontWeight.w800 : FontWeight.w500)),
                  subtitle: Text(_filters[i].explain),
                  trailing: i < _applied ? Icon(Icons.check_circle, color: c.lime) : null,
                ),
              const SizedBox(height: Gap.s),
              Wrap(
                spacing: Gap.s,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('clean-next'),
                    style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: Colors.white),
                    onPressed: _applied < _filters.length ? () => setState(() => _applied++) : null,
                    icon: const Icon(Icons.local_laundry_service_outlined),
                    label: Text(_applied < _filters.length ? 'Run: ${_filters[_applied].name}' : 'All clean!'),
                  ),
                  TextButton(onPressed: () => setState(() => _applied = 0), child: const Text('Start over')),
                ],
              ),
              if (cur != null) ...[
                const SizedBox(height: Gap.s),
                Text('Just ran: ${cur.name}', style: TextStyle(color: c.textDim, fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const FactCard(
          value: '96 → 1',
          label: 'FineWeb boiled 96 monthly web snapshots down to one cleaned [[dataset]] of 15 trillion tokens',
          factId: 'TR-FINEWEB',
        ),
        const SizedBox(height: Gap.s),
        const TermText('Real pipelines run filters like these over billions of pages, often using small AI models to judge quality.'),
      ],
    );
  }
}
