import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class Logout {
  final AuthRepository repository;
  Logout(this.repository);
  Future<Either<Failure, void>> execute() {
    return repository.logout();
  }
}
