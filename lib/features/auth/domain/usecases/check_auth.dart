import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class CheckAuth {
  final AuthRepository repository;
  CheckAuth(this.repository);
  Future<Either<Failure, User?>> execute() {
    return repository.checkAuth();
  }
}
