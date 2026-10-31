import 'dart:math';

import 'learning_item.dart';

typedef ItemGenerator = LearningItem Function(Random rng);

/// One node in a subject's curriculum: a narrowly defined skill with
/// prerequisites and a generator that only produces items for exactly that
/// skill.
class Skill {
  final String id;
  final String name;
  final String description;

  /// Group label on the skill map, e.g. "Adding" or "Word families".
  final String strand;
  final List<String> prerequisites;
  final ItemGenerator _generate;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.strand,
    required this.prerequisites,
    required ItemGenerator generate,
  }) : _generate = generate;

  LearningItem generate(Random rng) => _generate(rng);
}

/// Directed acyclic graph of skills. Edges point from a prerequisite to the
/// skills that build on it.
class SkillGraph {
  final List<Skill> skills;
  final Map<String, Skill> _byId;
  late final List<String> topologicalOrder = _topoSort();
  late final Map<String, List<String>> _children = _buildChildren();
  late final Map<String, Set<String>> _ancestors = {
    for (final s in skills) s.id: _collect(s.id, (id) => _byId[id]!.prerequisites),
  };
  late final Map<String, Set<String>> _descendants = {
    for (final s in skills) s.id: _collect(s.id, (id) => _children[id]!),
  };

  SkillGraph(this.skills) : _byId = {for (final s in skills) s.id: s} {
    if (skills.isEmpty) throw ArgumentError('A skill graph needs at least one skill');
    if (_byId.length != skills.length) {
      throw ArgumentError('Duplicate skill ids in graph');
    }
    for (final s in skills) {
      for (final p in s.prerequisites) {
        if (!_byId.containsKey(p)) {
          throw ArgumentError('Skill ${s.id} has unknown prerequisite $p');
        }
      }
    }
    topologicalOrder; // throws on cycles
  }

  Skill operator [](String id) {
    final s = _byId[id];
    if (s == null) throw ArgumentError('Unknown skill $id');
    return s;
  }

  bool contains(String id) => _byId.containsKey(id);

  /// Strand labels in the order they first appear in the curriculum.
  List<String> get strands => [
        for (final id in topologicalOrder) _byId[id]!.strand,
      ].toSet().toList();

  /// All skills that must be known before [id] (transitively), excluding [id].
  Set<String> ancestorsOf(String id) => _ancestors[id]!;

  /// All skills that depend on [id] (transitively), excluding [id].
  Set<String> descendantsOf(String id) => _descendants[id]!;

  List<String> childrenOf(String id) => _children[id]!;

  Map<String, List<String>> _buildChildren() {
    final children = {for (final s in skills) s.id: <String>[]};
    for (final s in skills) {
      for (final p in s.prerequisites) {
        children[p]!.add(s.id);
      }
    }
    return children;
  }

  Set<String> _collect(String start, Iterable<String> Function(String) next) {
    final seen = <String>{};
    final stack = [...next(start)];
    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      if (seen.add(id)) stack.addAll(next(id));
    }
    return seen;
  }

  /// Kahn's algorithm, stable with respect to declaration order.
  List<String> _topoSort() {
    final indegree = {for (final s in skills) s.id: s.prerequisites.length};
    final order = <String>[];
    final remaining = [...skills.map((s) => s.id)];
    while (remaining.isNotEmpty) {
      final next = remaining.firstWhere(
        (id) => indegree[id] == 0,
        orElse: () => throw StateError('Skill graph contains a cycle'),
      );
      remaining.remove(next);
      order.add(next);
      for (final s in skills) {
        if (s.prerequisites.contains(next)) {
          indegree[s.id] = indegree[s.id]! - 1;
        }
      }
    }
    return order;
  }
}
