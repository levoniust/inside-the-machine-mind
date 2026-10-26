import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/library.dart';

void main() {
  test('importing a pack unpacks it and makes the library available; a wrong version is refused', () async {
    final tmp = await Directory.systemTemp.createTemp('mm-lib');
    Archive pack(String version) => Archive()
      ..addFile(ArchiveFile.string('manifest.json', jsonEncode({'version': version})))
      ..addFile(ArchiveFile.string('sources/SRC-TRANSFORMER.txt', 'SOURCE COPY — SRC-TRANSFORMER\nhello'));
    final good = File('${tmp.path}/good.zip')..writeAsBytesSync(ZipEncoder().encode(pack(Library.version)));
    final bad = File('${tmp.path}/bad.zip')..writeAsBytesSync(ZipEncoder().encode(pack('1999.01')));

    final lib = Library.instance..useDirectory(Directory('${tmp.path}/library'));
    expect(lib.installed, isFalse);
    await lib.importFile(bad.path);
    expect(lib.installed, isFalse);
    expect(lib.error, contains('1999.01'));
    await lib.importFile(good.path);
    expect(lib.installed, isTrue);
    expect(await lib.loadText('sources/SRC-TRANSFORMER.txt'), contains('hello'));
    await lib.remove();
    expect(lib.installed, isFalse);
    await tmp.delete(recursive: true);
  });
}
