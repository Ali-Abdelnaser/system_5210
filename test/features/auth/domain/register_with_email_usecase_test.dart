import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:five2ten/core/errors/failures.dart';
import 'package:five2ten/features/auth/domain/entities/user_entity.dart';
import 'package:five2ten/features/auth/domain/repositories/auth_repository.dart';
import 'package:five2ten/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late RegisterWithEmailUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = RegisterWithEmailUseCase(repo);
  });

  test('returns user when repository succeeds', () async {
    const user = UserEntity(uid: '1', email: 'a@b.com');
    when(
      () => repo.registerWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => const Right(user));

    final result = await useCase(
      email: 'a@b.com',
      password: 'secret',
      name: 'Name',
    );

    expect(result, const Right<Failure, UserEntity>(user));
  });

  test('returns failure when repository fails', () async {
    when(
      () => repo.registerWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => const Left(FirebaseFailure('used')));

    final result = await useCase(
      email: 'a@b.com',
      password: 'secret',
      name: 'Name',
    );

    expect(result, const Left<Failure, UserEntity>(FirebaseFailure('used')));
  });
}
