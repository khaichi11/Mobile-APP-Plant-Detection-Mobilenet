import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/services/account_repository.dart';
import 'package:pandai/services/local_database.dart';

void main() {
  late MemoryDatabase db;
  late AccountRepository accounts;

  setUp(() {
    db = MemoryDatabase();
    accounts = AccountRepository(db);
  });

  test('register stores a hashed password, never the plain text', () async {
    await accounts.register(
      name: 'Bima',
      email: 'bima@school.id',
      password: 'tumbuhan',
      grade: 5,
    );
    final stored = db.data['accounts.v1']!;
    expect(stored, isNot(contains('tumbuhan')));
    expect(accounts.currentUser()!.name, 'Bima');
  });

  test('sign in works with any letter case and spaces in the email', () async {
    await accounts.register(
      name: 'Bima',
      email: 'bima@school.id',
      password: 'tumbuhan',
      grade: 5,
    );
    await accounts.signOut();
    expect(accounts.currentUser(), isNull);
    final user = await accounts.signIn(
      email: '  BIMA@School.id ',
      password: 'tumbuhan',
    );
    expect(user.email, 'bima@school.id');
  });

  test('wrong passwords and unknown emails are rejected', () async {
    await accounts.register(
      name: 'Bima',
      email: 'bima@school.id',
      password: 'tumbuhan',
      grade: 5,
    );
    await expectLater(
      accounts.signIn(email: 'bima@school.id', password: 'wrong!'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      accounts.signIn(email: 'nobody@school.id', password: 'tumbuhan'),
      throwsA(isA<AuthException>()),
    );
  });

  test('emails must be unique', () async {
    await accounts.register(
      name: 'Bima',
      email: 'bima@school.id',
      password: 'tumbuhan',
      grade: 5,
    );
    await expectLater(
      accounts.register(
        name: 'Other',
        email: 'Bima@school.id',
        password: 'another',
        grade: 2,
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('invalid input is rejected with friendly messages', () async {
    expect(AccountRepository.validateName(' '), isNotNull);
    expect(AccountRepository.validateName('A' * 25), isNotNull);
    expect(AccountRepository.validateEmail('not-an-email'), isNotNull);
    expect(AccountRepository.validateEmail('a@b.co'), isNull);
    expect(AccountRepository.validatePassword('12345'), isNotNull);
    await expectLater(
      accounts.register(
        name: '',
        email: 'x@y.id',
        password: '123456',
        grade: 1,
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('grades are kept between 1 and 6', () async {
    final user = await accounts.continueAsGuest(name: 'Tiny', grade: 9);
    expect(user.grade, 6);
    expect(user.isGuest, isTrue);
  });

  test('guest accounts are removed on sign out', () async {
    final guest = await accounts.continueAsGuest(name: 'Explorer', grade: 2);
    await accounts.signOut();
    expect(db.data['accounts.v1'], isNot(contains(guest.id)));
  });
}
