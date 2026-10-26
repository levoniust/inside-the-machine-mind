import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/library.dart';
import 'components.dart';

/// Status of the source library plug-in with its actions: download (once, then offline), import a pack file, remove.
class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key, this.compact = false});

  /// Compact = only shown when the library is missing (inside the reader).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final lib = Library.instance;
    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final c = AppColors.of(context);
        if (compact && lib.installed) return const SizedBox.shrink();
        return DemoCard(
          key: const ValueKey('library-card'),
          title: 'The source library',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lib.installed
                    ? (kIsWeb
                          ? 'Every source copy and original PDF is available.'
                          : 'Installed: every source copy and original PDF works offline.')
                    : 'The copies of every source (the papers, spec sheets and pages behind each fact) are a separate '
                          'download of about ${Library.approxSizeMB} MB, so the app itself stays small. '
                          'Get it once and it works offline from then on.',
                key: const ValueKey('library-status'),
              ),
              if (lib.busy) ...[
                const SizedBox(height: Gap.s),
                LinearProgressIndicator(value: lib.progress, color: c.cyan, backgroundColor: c.surfaceHi),
                const SizedBox(height: 4),
                Text('${((lib.progress ?? 0) * 100).round()}%', style: AppText.mono.copyWith(fontSize: 12)),
              ],
              if (lib.error != null) ...[
                const SizedBox(height: Gap.s),
                Text(lib.error!, style: TextStyle(color: c.red, fontSize: 13)),
              ],
              if (!kIsWeb) ...[
                const SizedBox(height: Gap.s),
                Wrap(
                  spacing: Gap.s,
                  runSpacing: Gap.s,
                  children: [
                    if (!lib.installed)
                      FilledButton.icon(
                        key: const ValueKey('library-download'),
                        onPressed: lib.busy ? null : lib.download,
                        icon: const Icon(Icons.download),
                        label: Text('Get the library (${Library.approxSizeMB} MB)'),
                      ),
                    if (!lib.installed)
                      OutlinedButton.icon(
                        key: const ValueKey('library-import'),
                        onPressed: lib.busy
                            ? null
                            : () async {
                                final r = await FilePicker.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['zip'],
                                );
                                final path = r.isEmpty ? null : r.single.path;
                                if (path != null) await lib.importFile(path);
                              },
                        icon: const Icon(Icons.file_open_outlined),
                        label: const Text('Import a pack file'),
                      ),
                    if (lib.installed && !compact)
                      OutlinedButton.icon(
                        key: const ValueKey('library-remove'),
                        onPressed: lib.remove,
                        icon: Icon(Icons.delete_outline, color: c.red),
                        label: const Text('Remove (frees space)'),
                      ),
                  ],
                ),
                if (!lib.installed) ...[
                  const SizedBox(height: Gap.xs),
                  Text(
                    'The download comes from the app\'s GitHub release page. It is the only thing the app ever uses the internet for.',
                    style: TextStyle(color: c.textDim, fontSize: 12),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
