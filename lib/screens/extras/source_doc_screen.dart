import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../core/models.dart' show Source;
import '../../content/source_docs.dart';

/// Reads one bundled source copy. Text is shown in lazy chunks (some papers run
/// hundreds of KB); papers also offer the original PDF.
class SourceDocScreen extends StatefulWidget {
  const SourceDocScreen({super.key, required this.sourceId});
  final String sourceId;

  @override
  State<SourceDocScreen> createState() => _SourceDocScreenState();
}

class _SourceDocScreenState extends State<SourceDocScreen> {
  static const maxChars = 140000;
  late final Future<List<String>> _chunks = _load();

  Future<List<String>> _load() async {
    final raw = await rootBundle.loadString(sourceDocs[widget.sourceId]!.asset);
    var text = raw;
    if (raw.length > maxChars) {
      var cut = raw.lastIndexOf('\n', maxChars);
      if (cut < 0) cut = maxChars; // no newline near the cap: hard cut rather than crash
      text = raw.substring(0, cut);
    }
    final truncated = raw.length > text.length;
    // Group paragraphs into ~4 KB chunks so the list stays lazy and smooth.
    final out = <String>[];
    final buf = StringBuffer();
    for (final line in const LineSplitter().convert(text)) {
      buf.writeln(line);
      if (buf.length > 4000) {
        out.add(buf.toString());
        buf.clear();
      }
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    if (truncated) {
      out.add('\n— end of the readable excerpt —\nThe full original continues beyond this excerpt '
          '(${(raw.length / 1000).round()} KB copied in total). Open the original PDF or the URL above for the rest.');
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final doc = sourceDocs[widget.sourceId]!;
    final src = sources[widget.sourceId];
    return Scaffold(
      appBar: AppBar(
        title: Text(shortTitle(src ?? Source(widget.sourceId, widget.sourceId)), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (doc.pdf != null)
            IconButton(
              key: const ValueKey('open-pdf'),
              tooltip: 'Read the original PDF',
              icon: Icon(Icons.picture_as_pdf_outlined, color: c.amber),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => PdfCopyScreen(asset: doc.pdf!, title: src?.title ?? widget.sourceId),
              )),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<List<String>>(
              future: _chunks,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Center(child: CircularProgressIndicator(color: c.cyan));
                }
                final chunks = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xl),
                  itemCount: chunks.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Gap.m, top: Gap.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (src != null) Text(src.title, style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: Gap.xs),
                            Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(Icons.link, size: 14, color: c.textDim),
                                // Flexible is illegal inside Wrap; cap the link to the available width instead.
                                LayoutBuilder(
                                  builder: (context, cons) => ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: cons.maxWidth - 26),
                                    child: SelectableText(doc.url ?? '(no URL recorded)',
                                        style: AppText.mono.copyWith(color: c.cyan, fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                            if (doc.note != null)
                              Padding(
                                padding: const EdgeInsets.only(top: Gap.xs),
                                child: Text(doc.note!, style: TextStyle(color: c.amber, fontSize: 12)),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: Gap.s, bottom: Gap.s),
                              child: Row(
                                children: [
                                  Text('offline copy', style: TextStyle(color: c.textDim, fontSize: 12)),
                                  const Spacer(),
                                  TextButton.icon(
                                    key: const ValueKey('copy-source-link'),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: doc.url ?? src?.title ?? widget.sourceId));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                                    },
                                    icon: Icon(Icons.copy_rounded, size: 16, color: c.textDim),
                                    label: Text('Copy link', style: TextStyle(color: c.textDim, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: c.line, height: 1),
                            SizedBox(height: Gap.s),
                          ],
                        ),
                      );
                    }
                    return SelectableText(
                      chunks[i - 1],
                      style: TextStyle(color: c.text, fontSize: 13.5, height: 1.5, fontFamilyFallback: const ['monospace']),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The original paper PDF, bundled with the app (rendered offline).
class PdfCopyScreen extends StatelessWidget {
  const PdfCopyScreen({super.key, required this.asset, required this.title});
  final String asset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: PdfPreview(
        build: (_) => rootBundle.load(asset).then((b) => b.buffer.asUint8List()),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
        useActions: false,
        pdfFileName: title,
      ),
    );
  }
}
