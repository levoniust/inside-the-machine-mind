import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "One word at a time": the autoregressive loop. Each new token is appended and the whole
/// thing goes back in. With the KV cache on, earlier tokens' attention notes are reused instead of
/// recomputed (work grows ~n instead of ~n²). Fact: IN-KV-CACHE.
class S3LoopScreen extends StatelessWidget {
  const S3LoopScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_loop',
        children: [_Loop()],
      );
}

const _prompt = ['why', 'is', 'the', 'sky', 'blue', '?'];
const _answer = ['Air', 'scatters', 'blue', 'light', 'more', 'than', 'red', ',', 'so', 'blue', 'fills', 'the', 'sky', '.'];

/// Token-processing work for generating [steps] tokens after a prompt of [prompt] tokens.
int workWithoutCache(int prompt, int steps) {
  var w = 0;
  for (var i = 0; i < steps; i++) {
    w += prompt + i; // re-read everything so far
  }
  return w;
}

int workWithCache(int prompt, int steps) => steps == 0 ? 0 : prompt + steps - 1; // prompt once, then 1 per new token

class _Loop extends StatefulWidget {
  const _Loop();

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  int _n = 0;
  bool _cache = true;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  void _next() {
    if (_n >= _answer.length) return;
    setState(() => _n++);
    if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = _n >= _answer.length;
    final work = _cache ? workWithCache(_prompt.length, _n) : workWithoutCache(_prompt.length, _n);
    final other = _cache ? workWithoutCache(_prompt.length, _n) : workWithCache(_prompt.length, _n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Watch the answer grow',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (var i = 0; i < _prompt.length; i++) _chip(context, _prompt[i], c.textDim, cached: _cache && _n > 0),
                  for (var i = 0; i < _n; i++)
                    _chip(context, _answer[i], c.magenta, isNew: i == _n - 1, cached: _cache && i < _n - 1),
                  if (!done)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Opacity(opacity: 0.4 + 0.6 * (1 - _pulse.value), child: _chip(context, '?', c.lime)),
                    ),
                ],
              ),
              const SizedBox(height: Gap.m),
              Row(
                children: [
                  Icon(Icons.loop, color: c.magenta),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Text(
                      done
                          ? 'Done: the model predicted a "stop" and the loop ends.'
                          : 'Everything so far goes back into the model to predict word ${_n + 1}.',
                      key: const ValueKey('loop-status'),
                      style: TextStyle(color: c.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.m),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('loop-next'),
                    style: FilledButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
                    onPressed: done ? null : _next,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next word'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('loop-all'),
                    onPressed: done ? null : () => setState(() => _n = _answer.length),
                    icon: const Icon(Icons.fast_forward),
                    label: const Text('Finish'),
                  ),
                  TextButton(onPressed: () => setState(() => _n = 0), child: const Text('Restart')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Notes so it doesn\'t re-read',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const ValueKey('loop-cache'),
                contentPadding: EdgeInsets.zero,
                title: const Text('KV cache'),
                subtitle: Text(_cache ? 'On: keeps each word\'s attention notes' : 'Off: re-reads everything every time'),
                value: _cache,
                activeThumbColor: c.magenta,
                onChanged: (v) => setState(() => _cache = v),
              ),
              StatGrid(
                children: [
                  StatTile(label: 'Words processed so far', value: '$work', color: _cache ? c.lime : c.red, icon: Icons.memory),
                  StatTile(label: _cache ? 'Without the cache it\'d be' : 'With the cache it\'d be', value: '$other', icon: Icons.compare_arrows),
                ],
              ),
              const SizedBox(height: Gap.m),
              TermText(
                'Without notes the work grows like a triangle (1 + 2 + 3 + …): a 1,000-word answer would mean re-reading '
                'about half a million words. The [[KV cache]] keeps it to about one new word per step, but the notes take '
                'memory: real models need gigabytes of them for long conversations.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.m),
              const FactCard(
                value: '~0.33 MB',
                label: 'of notes per token for a 70B model, about 40 GB for a 128,000-token conversation',
                factId: 'IN-KV-CACHE',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String t, Color col, {bool isNew = false, bool cached = false}) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isNew ? col.withValues(alpha: 0.3) : col.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cached ? c.lime.withValues(alpha: 0.7) : col.withValues(alpha: 0.6)),
      ),
      child: Text(t, style: TextStyle(color: c.text, fontWeight: isNew ? FontWeight.w800 : FontWeight.w500)),
    );
  }
}
