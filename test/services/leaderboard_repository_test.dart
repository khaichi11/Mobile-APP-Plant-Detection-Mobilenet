import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/models/user_profile.dart';
import 'package:pandai/services/leaderboard_repository.dart';

void main() {
  final me = UserProfile(
    id: 'user-1',
    name: 'Sari',
    grade: 4,
    createdAt: DateTime(2026),
  );

  test('places the player by points with ranks from 1', () async {
    const repo = DemoLeaderboardRepository();
    final entries = await repo.fetch(me: me, myPoints: 700);
    expect(repo.isDemo, isTrue);
    expect(entries.first.rank, 1);
    expect(
      entries.map((e) => e.rank),
      List.generate(entries.length, (i) => i + 1),
    );
    final mine = entries.singleWhere((e) => e.isMe);
    expect(mine.name, 'Sari');
    expect(mine.rank, 5);
  });

  test('the player wins ties', () async {
    final entries = await const DemoLeaderboardRepository().fetch(
      me: me,
      myPoints: 980,
    );
    expect(entries.singleWhere((e) => e.isMe).rank, 2);
  });
}
