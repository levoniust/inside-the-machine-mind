import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/library.dart';

void main() {
  test('importing a pack unpacks it; an older pack works but asks for an update; a non-pack is refused', () async {
    final tmp = await Directory.systemTemp.createTemp('mm-lib');
    Archive pack(String version, {bool withNew = true}) {
      final a = Archive()
        ..addFile(ArchiveFile.string('manifest.json', jsonEncode({'version': version})))
        ..addFile(ArchiveFile.string('sources/SRC-TRANSFORMER.txt', 'SOURCE COPY — SRC-TRANSFORMER\nhello'));
      if (withNew) a.addFile(ArchiveFile.string('sources/SRC-DOLMA.txt', 'SOURCE COPY — SRC-DOLMA'));
      return a;
    }

    final good = File('${tmp.path}/good.zip')..writeAsBytesSync(ZipEncoder().encode(pack(Library.version)));
    final old = File('${tmp.path}/old.zip')..writeAsBytesSync(ZipEncoder().encode(pack('2026.10', withNew: false)));
    final bad = File('${tmp.path}/bad.zip')
      ..writeAsBytesSync(ZipEncoder().encode(Archive()..addFile(ArchiveFile.string('readme.txt', 'not a pack'))));

    final lib = Library.instance..useDirectory(Directory('${tmp.path}/library'));
    expect(lib.installed, isFalse);
    await lib.importFile(bad.path);
    expect(lib.installed, isFalse);
    expect(lib.error, contains('manifest'));

    await lib.importFile(old.path);
    expect(lib.installed, isTrue);
    expect(lib.outdated, isTrue);
    expect(lib.has('sources/SRC-TRANSFORMER.txt'), isTrue);
    expect(lib.has('sources/SRC-DOLMA.txt'), isFalse);

    await lib.importFile(good.path);
    expect(lib.outdated, isFalse);
    expect(lib.has('sources/SRC-DOLMA.txt'), isTrue);
    expect(await lib.loadText('sources/SRC-TRANSFORMER.txt'), contains('hello'));
    await lib.remove();
    expect(lib.installed, isFalse);
    await tmp.delete(recursive: true);
  });
}
