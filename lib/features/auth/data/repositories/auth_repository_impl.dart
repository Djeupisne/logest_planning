import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/database/hive_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userBox = HiveService.users;
      final dbUser = userBox.values.cast<UserModel>().firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'token_${dbUser.id}');
      await prefs.setBool('is_logged_in', true);

      return Right(User(
        id: dbUser.id,
        email: dbUser.email,
        fullName: dbUser.fullName,
        role: dbUser.role,
        phone: dbUser.phone,
      ));
    } catch (e) {
      return const Left(AuthFailure("Email ou mot de passe incorrect"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_logged_in');
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return const Right(null);
    return const Right(null);
  }
}