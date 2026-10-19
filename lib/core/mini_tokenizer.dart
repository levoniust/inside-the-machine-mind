/// A small, honest stand-in for a real tokenizer: greedy longest-match over a hand-made vocabulary of
/// common words (with a leading space, like GPT-style tokenizers), common word pieces, and single
/// characters as a fallback. Real tokenizers learn 50,000–128,000 pieces with byte-pair encoding.
class MiniTokenizer {
  MiniTokenizer() {
    final pieces = <String>[];
    for (final w in _words.split(' ')) {
      pieces
        ..add(' $w')
        ..add(w);
      final cap = w[0].toUpperCase() + w.substring(1);
      pieces
        ..add(' $cap')
        ..add(cap);
    }
    pieces.addAll(_parts.split(' '));
    pieces.addAll(_parts.split(' ').map((p) => ' $p'));
    for (var c = 32; c < 127; c++) {
      pieces.add(String.fromCharCode(c));
    }
    for (final p in pieces) {
      if (!_ids.containsKey(p)) _ids[p] = _ids.length;
    }
    _maxLen = _ids.keys.fold(0, (m, k) => k.length > m ? k.length : m);
  }

  final Map<String, int> _ids = {};
  late final int _maxLen;

  int get vocabularySize => _ids.length;

  /// Split [text] into (piece, id) tokens.
  List<(String, int)> encode(String text) {
    final out = <(String, int)>[];
    var i = 0;
    while (i < text.length) {
      var len = (_maxLen < text.length - i) ? _maxLen : text.length - i;
      while (len > 0) {
        final piece = text.substring(i, i + len);
        final id = _ids[piece];
        if (id != null) {
          out.add((piece, id));
          i += len;
          break;
        }
        len--;
      }
      if (len == 0) {
        // Character outside the vocabulary (emoji, accents): one "unknown" token per character. Keep
        // surrogate pairs together; half an emoji is not a valid string and crashes text layout.
        final pair = i + 1 < text.length && (text.codeUnitAt(i) & 0xFC00) == 0xD800 && (text.codeUnitAt(i + 1) & 0xFC00) == 0xDC00;
        final n = pair ? 2 : 1;
        out.add((text.substring(i, i + n), -1));
        i += n;
      }
    }
    return out;
  }

  static const _words = 'the be to of and a in that have i it for not on with he as you do at this but his by from they we '
      'say her she or an will my one all would there their what so up out if about who get which go me when make can '
      'like time no just him know take people into year your good some could them see other than then now look only '
      'come its over think also back after use two how our work first well way even new want because any these give '
      'day most us is was are were been has had did does said why sky blue light sun air red color colors scatter '
      'scatters scattering wave waves short long eye eyes see world model models machine mind question answer token '
      'tokens word words learn learning train training brain computer chip chips memory data robot bit hello hi yes '
      'thank thanks please ai large language how many much very more less big small fast slow cat dog tea happy '
      'night day morning water fire earth space star stars moon planet ocean green yellow orange purple black white '
      'because where here there something nothing everything really little great right left old young man woman king '
      'queen boy girl child children friend family home house school car book books read write play game music love';

  static const _parts = 'ing ed er est ly s es tion tions ness ment ments able ably ible ful less un re pre dis over '
      'under inter super auto believ believe incred ible amaz amazing comput compute understand under stand trans form '
      'former transformer neur neural network net work ize ise al ally ic ical ity ous ive en est th ch sh qu ph tr st '
      'pl gr cl br fl sp sc';
}
