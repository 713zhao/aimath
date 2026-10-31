# Adding a subject

The Learn tab works the same way for every subject: a **skill graph** (skills plus
the skills they depend on), a **placement test** that finds where a child is, and
**practice** that tracks mastery and gives a targeted hint after each mistake.
A subject only provides the content. Math and Spelling are the two examples.

```
lib/learning/
  core/                 # subject-independent engine — normally no changes needed
    learning_item.dart  # LearningItem, AnswerFormat, Diagnosis
    skill_graph.dart    # Skill, SkillGraph
    subject.dart        # Subject
    learner_model.dart  # mastery tracking (Bayesian Knowledge Tracing)
    placement_test.dart # adaptive placement over the graph
    learner_model_store.dart
  subjects/
    math/               # ArithmeticItem + 16-skill curriculum
    spelling/           # choice + typed items, 7 skills
    subjects.dart       # registry: the list of subjects shown in the app
```

## Steps

### 1. Decide the skills and their prerequisites

Write the skills down as a small dependency graph before coding. Keep each skill
narrow enough that one kind of question tests it (for example, "silent e words",
not "spelling"). A skill should list only its *direct* prerequisites.

```
cvc ──► digraphs ──► tricky_words ──┐
 ├────► magic_e ──► vowel_teams ─────┼──► spell_it
 └────► double_letters ──────────────┘
```

Between 5 and 20 skills works well. Placement asks about 1.5 questions per skill
at most, and usually fewer.

### 2. Define the question type: a `LearningItem`

Create `lib/learning/subjects/<subject>/<subject>_subject.dart`. Pick an
`AnswerFormat`; the UI chooses the input from it:

| Format | Input shown | Typical use |
|---|---|---|
| `number` | big number pad | arithmetic, counting |
| `choice` | one big button per option | spelling, vocabulary, facts, "which is bigger" |
| `text` | text box | typed spelling, short words |

```dart
class CapitalItem extends LearningItem {
  CapitalItem(this.skillId, this.country, this.capital, this.wrong);
  @override final String skillId;
  final String country, capital;
  final List<String> wrong; // plausible wrong answers

  @override String get prompt => 'Capital of $country?';
  @override AnswerFormat get format => AnswerFormat.choice;
  @override List<String> get choices => [capital, ...wrong]..shuffle();
  @override String get answerText => capital;
}
```

`isCorrect` defaults to a trimmed, case-insensitive comparison with
`answerText`; override it for anything else (numbers, accepted spellings).
If the item keeps `choices` in a field, shuffle it once in the constructor
rather than in the getter, so the order doesn't change on every rebuild.

### 3. Recognise common mistakes (optional, but it's what makes hints useful)

Override `diagnose(response)` and return a `Diagnosis(code, hint)` for each
mistake you can recognise. The simplest reliable way, used by Spelling, is to
tag each wrong option with the mistake it shows:

```dart
SpellingWord('cake', '🎂 You eat it on your birthday', {'cak': magicE, 'kake': magicE});
```

Codes are stored in each child's progress, so **never rename a code** once it
has shipped. Anything unrecognised falls back to `Diagnosis.unknownCode` with a
generic "the answer is …" hint.

### 4. Build the `Subject`

```dart
final Subject geographySubject = Subject(
  id: 'geography',              // storage key — never change it
  name: 'Geography',
  description: 'Countries, capitals and continents',
  emoji: '🌍',
  graph: SkillGraph([
    Skill(
      id: 'capitals_europe',     // unique within the subject — never change it
      name: 'European capitals',
      description: 'Paris, Rome, Madrid',
      strand: 'Capitals',        // heading the skill appears under on the map
      prerequisites: const [],
      generate: (rng) => /* return a CapitalItem for this skill */,
    ),
    // …
  ]),
);
```

`SkillGraph` throws immediately on duplicate ids, unknown prerequisites or
cycles, so mistakes in the graph show up on the first run.

### 5. Register it

Add the subject to `allSubjects` in `lib/learning/subjects/subjects.dart`. The
subject picker on the Learn tab shows every registered subject. Each child's
progress is saved separately per subject.

### 6. Test it

The generic tests in `test/learning/learning_test.dart` (group `Subjects`)
already run against **every registered subject**. They check that:

- every skill generates items tagged with its own skill id;
- `answerText` is accepted as correct and has no diagnosis;
- choice items include the right answer once, with no duplicate options;
- placement recovers every possible learner state exactly.

Add your own tests for content rules (for example, "never asks about a country
twice in a row") and for each mistake code. Then run:

```bash
flutter test test/learning
```

## Tips

- **Content quality matters most.** Plausible wrong options teach more than
  random ones. Use the mistakes children actually make.
- **Clues must identify the answer without giving it away.** Spelling uses an
  emoji plus a short meaning, or a sentence with a blank.
- Generators receive a `Random`. Use it (not `Random()`) so tests are repeatable.
- If a subject needs a new kind of input (drag-and-drop, audio, drawing), add a
  value to `AnswerFormat` and a matching widget in
  `lib/screens/learning/answer_widgets.dart` (`ItemAnswerInput`).
