import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/learning/core/learner_model.dart';
import 'package:aimath/learning/core/learner_model_store.dart';
import 'package:aimath/learning/core/learning_item.dart';
import 'package:aimath/learning/core/placement_test.dart';
import 'package:aimath/learning/core/skill_graph.dart';
import 'package:aimath/learning/subjects/math/math_items.dart';
import 'package:aimath/learning/subjects/math/math_subject.dart';
import 'package:aimath/learning/subjects/spelling/spelling_subject.dart';
import 'package:aimath/learning/subjects/subjects.dart';
import 'package:aimath/providers/learning_provider.dart';
import 'package:aimath/utils/enums.dart';

final graph = mathSubject.graph;

/// Every set of skills that is closed under prerequisites, i.e. every
/// possible "true state" of a child.
List<Set<String>> allPossibleStates(SkillGraph graph) {
  final ids = graph.topologicalOrder;
  final states = <Set<String>>[];
  for (var mask = 0; mask < (1 << ids.length); mask++) {
    final set = {for (var i = 0; i < ids.length; i++) if (mask & (1 << i) != 0) ids[i]};
    if (set.every((id) => graph.ancestorsOf(id).every(set.contains))) states.add(set);
  }
  return states;
}

/// What a child who does / doesn't know the skill would answer.
String answerFor(LearningItem item, bool knows) => knows ? item.answerText : '${item.answerText}x';

void main() {
  group('SkillGraph', () {
    test('is acyclic and every prerequisite comes first', () {
      final order = graph.topologicalOrder;
      expect(order.toSet().length, graph.skills.length);
      for (final s in graph.skills) {
        for (final p in s.prerequisites) {
          expect(order.indexOf(p), lessThan(order.indexOf(s.id)), reason: '${s.id} before $p');
        }
      }
    });

    test('rejects cycles and unknown prerequisites', () {
      LearningItem gen(Random r) => ArithmeticItem(skillId: 'x', a: 1, b: 1, op: Operation.add);
      expect(
        () => SkillGraph([
          Skill(id: 'a', name: 'a', description: '', strand: 's', prerequisites: const ['b'], generate: gen),
          Skill(id: 'b', name: 'b', description: '', strand: 's', prerequisites: const ['a'], generate: gen),
        ]),
        throwsStateError,
      );
      expect(
        () => SkillGraph([
          Skill(id: 'a', name: 'a', description: '', strand: 's', prerequisites: const ['zzz'], generate: gen),
        ]),
        throwsArgumentError,
      );
    });

    test('generators respect each skill\'s constraints', () {
      final rng = Random(1);
      for (var i = 0; i < 300; i++) {
        ArithmeticItem g(String id) {
          final p = graph[id].generate(rng) as ArithmeticItem;
          expect(p.skillId, id);
          return p;
        }

        var p = g('add_within_5');
        expect(p.answer, inInclusiveRange(0, 5));
        p = g('add_within_10');
        expect(p.answer, inInclusiveRange(6, 10));
        p = g('add_bridge_10');
        expect(p.a, lessThan(10));
        expect(p.b, lessThan(10));
        expect(p.answer, inInclusiveRange(11, 18));
        p = g('add_2d_no_carry');
        expect(p.a % 10 + p.b % 10, lessThan(10));
        expect(p.answer, lessThan(100));
        p = g('add_2d_carry');
        expect(p.a % 10 + p.b % 10, greaterThanOrEqualTo(10));
        expect(p.answer, lessThan(100));
        p = g('sub_within_10');
        expect(p.answer, greaterThanOrEqualTo(0));
        expect(p.a, lessThanOrEqualTo(10));
        p = g('sub_bridge_10');
        expect(p.b, lessThan(10));
        expect(p.answer, inInclusiveRange(2, 9));
        expect(p.a % 10, lessThan(p.b));
        p = g('sub_2d_no_borrow');
        expect(p.a % 10, greaterThanOrEqualTo(p.b % 10));
        expect(p.answer, greaterThan(0));
        p = g('sub_2d_borrow');
        expect(p.a % 10, lessThan(p.b % 10));
        expect(p.answer, greaterThan(0));
        p = g('sub_3d');
        expect(p.answer, greaterThan(0));
        p = g('div_facts');
        expect(p.a % p.b, 0);
        p = g('div_2d_by_1d');
        expect(p.a % p.b, 0);
        expect(p.a, lessThan(100));
        expect(p.answer, greaterThanOrEqualTo(11));
      }
    });
  });

  group('diagnoseArithmetic', () {
    ArithmeticItem prob(int a, Operation op, int b) => ArithmeticItem(skillId: 't', a: a, b: b, op: op);

    test('returns null for a correct answer', () {
      expect(diagnoseArithmetic(prob(38, Operation.add, 47), 85), isNull);
    });

    test('spots a forgotten carry and names the column', () {
      final d = diagnoseArithmetic(prob(38, Operation.add, 47), 75)!;
      expect(d.code, MathMistake.forgotCarry);
      expect(d.hint, contains('ones'));
      final d3 = diagnoseArithmetic(prob(451, Operation.add, 372), 723)!;
      expect(d3.code, MathMistake.forgotCarry);
      expect(d3.hint, contains('tens'));
    });

    test('spots smaller-from-larger subtraction', () {
      final d = diagnoseArithmetic(prob(62, Operation.subtract, 27), 45)!;
      expect(d.code, MathMistake.subtractedSmallerFromLarger);
      expect(d.hint, contains('ones'));
    });

    test('spots the wrong operation', () {
      expect(diagnoseArithmetic(prob(9, Operation.subtract, 4), 13)!.code, MathMistake.wrongOperation);
      expect(diagnoseArithmetic(prob(6, Operation.multiply, 7), 13)!.code, MathMistake.wrongOperation);
    });

    test('spots neighbouring times-table facts', () {
      expect(diagnoseArithmetic(prob(7, Operation.multiply, 8), 49)!.code, MathMistake.timesTableNeighbour);
    });

    test('spots reversed digits, off-by-one, and falls back to unknown', () {
      expect(diagnoseArithmetic(prob(9, Operation.add, 5), 41)!.code, MathMistake.reversedDigits);
      expect(diagnoseArithmetic(prob(4, Operation.add, 3), 8)!.code, MathMistake.offByOne);
      expect(diagnoseArithmetic(prob(4, Operation.add, 3), 20)!.code, Diagnosis.unknownCode);
    });
  });

  group('LearnerModel', () {
    test('a new learner starts at the root skill', () {
      final m = LearnerModel(graph);
      expect(m.frontier, ['add_within_5']);
      expect(m.statusOf('add_within_5'), SkillStatus.ready);
      expect(m.statusOf('add_within_10'), SkillStatus.locked);
    });

    test('a few correct answers in a row reach mastery and unlock the next skill', () {
      final m = LearnerModel(graph);
      var n = 0;
      while (!m.isMastered('add_within_5')) {
        m.recordAnswer('add_within_5', correct: true);
        n++;
      }
      expect(n, inInclusiveRange(3, 6));
      expect(m.frontier, ['add_within_10']);
    });

    test('a single wrong answer cannot create mastery, and lowers belief', () {
      final m = LearnerModel(graph);
      for (var i = 0; i < 2; i++) {
        m.recordAnswer('add_within_5', correct: true);
      }
      final before = m.of('add_within_5').pKnown;
      m.recordAnswer('add_within_5', correct: false, mistake: MathMistake.offByOne);
      expect(m.of('add_within_5').pKnown, lessThan(before));
      expect(m.of('add_within_5').mistakes[MathMistake.offByOne], 1);
    });

    test('round-trips through JSON', () {
      final m = LearnerModel(graph)..applyPlacement({'add_within_5', 'add_within_10'});
      m.recordAnswer('add_bridge_10', correct: false, mistake: MathMistake.forgotCarry);
      final copy = LearnerModel.fromJson(graph, m.toJson());
      expect(copy.placementDone, isTrue);
      expect(copy.isMastered('add_within_10'), isTrue);
      expect(copy.of('add_bridge_10').attempts, 1);
      expect(copy.of('add_bridge_10').mistakes[MathMistake.forgotCarry], 1);
      expect(copy.frontier, m.frontier);
    });
  });

  group('PlacementTest', () {
    test('recovers every possible learner state exactly within the question budget', () {
      final states = allPossibleStates(graph);
      expect(states.length, greaterThan(20));
      var worst = 0;
      for (final truth in states) {
        final t = PlacementTest(graph, rng: Random(7));
        while (!t.isFinished) {
          final p = t.currentItem!;
          t.submit(answerFor(p, truth.contains(p.skillId)));
        }
        expect(t.knownSkills, truth, reason: 'true state $truth');
        worst = max(worst, t.questionsAsked);
      }
      // A consistent child needs 2 answers per probe.
      expect(worst, lessThanOrEqualTo(24));
    });

    test('tolerates a single slip on a probed skill', () {
      final truth = graph.skills.map((s) => s.id).toSet(); // knows everything
      final t = PlacementTest(graph, rng: Random(3));
      var slipped = false;
      while (!t.isFinished) {
        final p = t.currentItem!;
        if (!slipped) {
          slipped = true;
          t.submit('wrong');
        } else {
          t.submit(answerFor(p, truth.contains(p.skillId)));
        }
      }
      expect(t.knownSkills, truth);
    });
  });

  group('LearningProvider', () {
    test('placement then practice persists and unlocks skills', () async {
      final store = MemoryLearnerModelStore();
      final provider = LearningProvider(store: store, rng: Random(5));
      await provider.load('kid');
      expect(provider.model!.recommendedSkill, 'add_within_5');

      final known = {'add_within_5', 'add_within_10'};
      final t = provider.startPlacement();
      while (!t.isFinished) {
        final p = t.currentItem!;
        t.submit(answerFor(p, known.contains(p.skillId)));
      }
      await provider.finishPlacement(t);
      expect(provider.model!.frontier, ['add_bridge_10', 'add_2d_no_carry', 'sub_within_10']);

      PracticeFeedback? last;
      while (!(last?.justMastered ?? false)) {
        final p = provider.nextItem('sub_within_10');
        last = await provider.answer(p, p.answerText);
      }
      expect(provider.model!.isMastered('sub_within_10'), isTrue);

      final wrong = provider.nextItem('add_bridge_10') as ArithmeticItem;
      final fb = await provider.answer(wrong, '${wrong.answer - 10}'); // forgot the carry
      expect(fb.correct, isFalse);
      expect(fb.diagnosis!.code, MathMistake.forgotCarry);

      final reloaded = LearningProvider(store: store);
      await reloaded.load('kid');
      expect(reloaded.model!.placementDone, isTrue);
      expect(reloaded.model!.isMastered('sub_within_10'), isTrue);
    });
  });

  group('Subjects', () {
    test('every registered subject has a unique id and a valid, generating graph', () {
      expect(allSubjects.map((s) => s.id).toSet().length, allSubjects.length);
      final rng = Random(11);
      for (final subject in allSubjects) {
        for (final skill in subject.graph.skills) {
          for (var i = 0; i < 30; i++) {
            final item = skill.generate(rng);
            expect(item.skillId, skill.id, reason: '${subject.id}/${skill.id}');
            expect(item.isCorrect(item.answerText), isTrue, reason: '${subject.id}/${skill.id}: $item');
            expect(item.diagnose(item.answerText), isNull);
            if (item.format == AnswerFormat.choice) {
              expect(item.choices, contains(item.answerText));
              expect(item.choices!.toSet().length, item.choices!.length);
            }
          }
        }
      }
    });

    test('placement recovers every learner state in every subject', () {
      for (final subject in allSubjects) {
        for (final truth in allPossibleStates(subject.graph)) {
          final t = PlacementTest(subject.graph, rng: Random(9));
          while (!t.isFinished) {
            final item = t.currentItem!;
            t.submit(answerFor(item, truth.contains(item.skillId)));
          }
          expect(t.knownSkills, truth, reason: '${subject.id}: $truth');
        }
      }
    });
  });

  group('Spelling', () {
    test('choice items name the mistake behind a wrong pick', () {
      final item = SpellingChoiceItem('magic_e', magicEWords.first, Random(1));
      expect(item.choices, containsAll(['cake', 'cak', 'kake']));
      expect(item.isCorrect('cake'), isTrue);
      expect(item.isCorrect(' Cake '), isTrue);
      final d = item.diagnose('cak')!;
      expect(d.code, SpellingMistake.magicE);
      expect(d.hint, contains('silent e'));
    });

    test('typed answers recognise known misspellings and fall back to a generic hint', () {
      final item = SpellingTypeItem('spell_it', vowelTeamWords.first); // rain
      expect(item.format, AnswerFormat.text);
      expect(item.instruction, contains('4 letters'));
      expect(item.diagnose('rane')!.code, SpellingMistake.vowelTeam);
      expect(item.diagnose('xyz')!.code, Diagnosis.unknownCode);
    });

    test('progress is kept separately per subject', () async {
      final store = MemoryLearnerModelStore();
      final provider = LearningProvider(store: store, rng: Random(1));
      await provider.load('kid');
      expect(provider.subject.id, 'math');
      await provider.answer(provider.nextItem('add_within_5'), 'nope');

      await provider.selectSubject('spelling');
      expect(provider.subject.name, 'Spelling');
      expect(provider.model!.recommendedSkill, 'cvc');
      expect(provider.model!.of('cvc').attempts, 0);
      final item = provider.nextItem('cvc');
      await provider.answer(item, item.answerText);

      await provider.selectSubject('math');
      expect(provider.model!.of('add_within_5').attempts, 1);
      expect(store.data.keys, containsAll(['kid::math', 'kid::spelling']));
    });
  });
}
