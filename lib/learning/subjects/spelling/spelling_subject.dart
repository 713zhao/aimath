import 'dart:math';

import '../../core/learning_item.dart';
import '../../core/skill_graph.dart';
import '../../core/subject.dart';

/// Spelling mistake codes. Stored in the learner model — never rename.
abstract final class SpellingMistake {
  static const shortVowel = 'shortVowel';
  static const digraph = 'digraph';
  static const magicE = 'magicE';
  static const doubleLetter = 'doubleLetter';
  static const vowelTeam = 'vowelTeam';
  static const trickyWord = 'trickyWord';

  static String hint(String code, String word) {
    switch (code) {
      case shortVowel:
        return 'Say it slowly, sound by sound. Which vowel do you hear in the middle of "$word"?';
      case digraph:
        return 'Two letters can make one sound: sh, ch, th. Listen to the start and end of "$word".';
      case magicE:
        return 'The silent e at the end makes the vowel say its name: "$word".';
      case doubleLetter:
        return 'After a short vowel, f, l and s are usually doubled: "$word".';
      case vowelTeam:
        return 'Two vowels can team up to make one long sound (ai, ee, oa): "$word".';
      case trickyWord:
        return '"$word" is a tricky word — it doesn\'t sound like it looks. Look, say, cover, write!';
      default:
        return 'It\'s spelled "$word".';
    }
  }
}

/// A word with a picture/meaning clue and common misspellings of it.
class SpellingWord {
  final String word;
  final String clue;

  /// Misspelling → the mistake it shows.
  final Map<String, String> misspellings;

  const SpellingWord(this.word, this.clue, this.misspellings);
}

/// "Which spelling is right?" — pick from the word and two misspellings.
class SpellingChoiceItem extends LearningItem {
  @override
  final String skillId;
  final SpellingWord word;
  final List<String> _choices;

  SpellingChoiceItem(this.skillId, this.word, Random rng)
      : _choices = ([word.word, ...word.misspellings.keys.take(2)]..shuffle(rng));

  @override
  String get prompt => word.clue;

  @override
  String get instruction => 'Which spelling is right?';

  @override
  AnswerFormat get format => AnswerFormat.choice;

  @override
  List<String> get choices => _choices;

  @override
  String get answerText => word.word;

  @override
  Diagnosis? diagnose(String response) {
    if (isCorrect(response)) return null;
    final code = word.misspellings[response.trim().toLowerCase()] ?? Diagnosis.unknownCode;
    return Diagnosis(code, SpellingMistake.hint(code, word.word));
  }
}

/// "Spell it yourself" — type the word from its clue.
class SpellingTypeItem extends LearningItem {
  @override
  final String skillId;
  final SpellingWord word;

  SpellingTypeItem(this.skillId, this.word);

  @override
  String get prompt => word.clue;

  @override
  String get instruction => 'Type the word (${word.word.length} letters, starts with "${word.word[0]}")';

  @override
  AnswerFormat get format => AnswerFormat.text;

  @override
  String get answerText => word.word;

  @override
  Diagnosis? diagnose(String response) {
    if (isCorrect(response)) return null;
    final code = word.misspellings[response.trim().toLowerCase()] ?? Diagnosis.unknownCode;
    return Diagnosis(code, SpellingMistake.hint(code, word.word));
  }
}

// ---------------------------------------------------------------------------
// Word lists
// ---------------------------------------------------------------------------

const _v = SpellingMistake.shortVowel;
const _d = SpellingMistake.digraph;
const _e = SpellingMistake.magicE;
const _l = SpellingMistake.doubleLetter;
const _t = SpellingMistake.vowelTeam;
const _k = SpellingMistake.trickyWord;

const cvcWords = [
  SpellingWord('cat', '🐱 It says "meow"', {'cet': _v, 'kat': _v}),
  SpellingWord('dog', '🐶 It says "woof"', {'dag': _v, 'dogg': _v}),
  SpellingWord('sun', '☀️ It shines in the sky', {'sen': _v, 'son': _v}),
  SpellingWord('pig', '🐷 It says "oink"', {'peg': _v, 'pigg': _v}),
  SpellingWord('bed', '🛏️ You sleep in it', {'bid': _v, 'bad': _v}),
  SpellingWord('cup', '☕ You drink from it', {'cap': _v, 'kup': _v}),
  SpellingWord('bus', '🚌 A big car for lots of people', {'bas': _v, 'buss': _v}),
  SpellingWord('hat', '🎩 You wear it on your head', {'het': _v, 'hatt': _v}),
];

const digraphWords = [
  SpellingWord('ship', '🚢 A big boat', {'sip': _d, 'chip': _d}),
  SpellingWord('fish', '🐟 It swims in water', {'fis': _d, 'fich': _d}),
  SpellingWord('chick', '🐤 A baby chicken', {'shick': _d, 'chik': _d}),
  SpellingWord('chin', '🙂 Under your mouth', {'shin': _d, 'cin': _d}),
  SpellingWord('bath', '🛁 You wash in it', {'baf': _d, 'bat': _d}),
  SpellingWord('three', '3️⃣ The number after two', {'free': _d, 'tree': _d}),
  SpellingWord('shop', '🏪 You buy things there', {'chop': _d, 'sop': _d}),
  SpellingWord('lunch', '🥪 A meal in the middle of the day', {'lunsh': _d, 'lunc': _d}),
];

const magicEWords = [
  SpellingWord('cake', '🎂 You eat it on your birthday', {'cak': _e, 'kake': _e}),
  SpellingWord('bike', '🚲 Two wheels and pedals', {'bik': _e, 'bicke': _e}),
  SpellingWord('home', '🏠 Where you live', {'hom': _e, 'hoam': _e}),
  SpellingWord('kite', '🪁 It flies on a string', {'kit': _e, 'kight': _e}),
  SpellingWord('rope', '🪢 A thick string for climbing', {'rop': _e, 'roap': _e}),
  SpellingWord('cube', '🧊 A shape like a dice', {'cub': _e, 'kube': _e}),
  SpellingWord('game', '🎲 Something you play', {'gam': _e, 'gaim': _e}),
  SpellingWord('nose', '👃 You smell with it', {'nos': _e, 'noze': _e}),
];

const doubleLetterWords = [
  SpellingWord('bell', '🔔 It rings', {'bel': _l, 'bele': _l}),
  SpellingWord('hill', '⛰️ A small mountain', {'hil': _l, 'hille': _l}),
  SpellingWord('doll', '🪆 A toy that looks like a person', {'dol': _l, 'dolle': _l}),
  SpellingWord('kiss', '😘 A little touch with your lips', {'kis': _l, 'kisse': _l}),
  SpellingWord('cliff', '🏞️ A steep rock edge', {'clif': _l, 'cliffe': _l}),
  SpellingWord('grass', '🌱 Green and grows in the garden', {'gras': _l, 'grasse': _l}),
  SpellingWord('shell', '🐚 You find it on the beach', {'shel': _l, 'chell': _l}),
  SpellingWord('puff', '💨 A small breath of air', {'puf': _l, 'pufe': _l}),
];

const vowelTeamWords = [
  SpellingWord('rain', '🌧️ Water falling from clouds', {'rane': _t, 'ran': _t}),
  SpellingWord('tree', '🌳 It has leaves and a trunk', {'tre': _t, 'trea': _t}),
  SpellingWord('boat', '⛵ It floats on water', {'bote': _t, 'bot': _t}),
  SpellingWord('seed', '🌰 A plant grows from it', {'sed': _t, 'sead': _t}),
  SpellingWord('train', '🚆 It runs on tracks', {'trane': _t, 'tran': _t}),
  SpellingWord('goat', '🐐 A farm animal with horns', {'gote': _t, 'got': _t}),
  SpellingWord('sheep', '🐑 It gives us wool', {'shep': _t, 'sheap': _t}),
  SpellingWord('snail', '🐌 Slow, with a shell on its back', {'snale': _t, 'snal': _t}),
];

const trickyWords = [
  SpellingWord('said', 'Yesterday Mum ___ hello.', {'sed': _k, 'sayed': _k}),
  SpellingWord('was', 'It ___ sunny yesterday.', {'woz': _k, 'wos': _k}),
  SpellingWord('they', '___ are my friends.', {'thay': _k, 'thei': _k}),
  SpellingWord('friend', 'A ___ is someone you like to play with.', {'frend': _k, 'freind': _k}),
  SpellingWord('because', 'I smiled ___ I was happy.', {'becos': _k, 'becuz': _k}),
  SpellingWord('people', 'Lots of ___ came to the party.', {'peeple': _k, 'pepul': _k}),
  SpellingWord('could', 'I ___ swim when I was five.', {'cud': _k, 'coud': _k}),
  SpellingWord('there', 'Put the box over ___.', {'thare': _k, 'ther': _k}),
];

ItemGenerator _choice(String skillId, List<SpellingWord> words) =>
    (rng) => SpellingChoiceItem(skillId, words[rng.nextInt(words.length)], rng);

const _sounds = 'Sounds';
const _patterns = 'Spelling patterns';
const _words = 'Tricky words';

/// Early phonics and spelling patterns (roughly ages 5–8).
final Subject spellingSubject = Subject(
  id: 'spelling',
  name: 'Spelling',
  description: 'Short vowels, sh/ch/th, silent e and tricky words',
  emoji: '🔤',
  graph: SkillGraph([
    Skill(
      id: 'cvc',
      name: 'Short vowel words',
      description: 'cat, dog, sun',
      strand: _sounds,
      prerequisites: const [],
      generate: _choice('cvc', cvcWords),
    ),
    Skill(
      id: 'digraphs',
      name: 'sh, ch, th',
      description: 'ship, chin, bath',
      strand: _sounds,
      prerequisites: const ['cvc'],
      generate: _choice('digraphs', digraphWords),
    ),
    Skill(
      id: 'double_letters',
      name: 'Double letters',
      description: 'bell, kiss, puff',
      strand: _patterns,
      prerequisites: const ['cvc'],
      generate: _choice('double_letters', doubleLetterWords),
    ),
    Skill(
      id: 'magic_e',
      name: 'Silent e',
      description: 'cake, bike, home',
      strand: _patterns,
      prerequisites: const ['cvc'],
      generate: _choice('magic_e', magicEWords),
    ),
    Skill(
      id: 'vowel_teams',
      name: 'Vowel teams',
      description: 'rain, tree, boat',
      strand: _patterns,
      prerequisites: const ['magic_e', 'digraphs'],
      generate: _choice('vowel_teams', vowelTeamWords),
    ),
    Skill(
      id: 'tricky_words',
      name: 'Tricky words',
      description: 'said, was, friend',
      strand: _words,
      prerequisites: const ['digraphs'],
      generate: _choice('tricky_words', trickyWords),
    ),
    Skill(
      id: 'spell_it',
      name: 'Spell it yourself',
      description: 'Type whole words from a clue',
      strand: _words,
      prerequisites: const ['vowel_teams', 'double_letters', 'tricky_words'],
      generate: (rng) {
        const pool = [...cvcWords, ...digraphWords, ...magicEWords, ...doubleLetterWords, ...vowelTeamWords];
        return SpellingTypeItem('spell_it', pool[rng.nextInt(pool.length)]);
      },
    ),
  ]),
);
