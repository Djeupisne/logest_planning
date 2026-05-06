import 'package:get_it/get_it.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/check_auth.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/consultant/data/repositories/mission_repository_impl.dart';
import 'features/consultant/domain/repositories/mission_repository.dart';
import 'features/consultant/domain/usecases/get_daily_missions.dart';
import 'features/consultant/domain/usecases/update_mission_status.dart';
import 'features/consultant/presentation/bloc/mission_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureInjection() async {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<MissionRepository>(() => MissionRepositoryImpl());

  getIt.registerLazySingleton(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Logout(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => CheckAuth(getIt<AuthRepository>()));

  getIt.registerLazySingleton(() => GetDailyMissions(getIt<MissionRepository>()));
  getIt.registerLazySingleton(() => UpdateMissionStatus(getIt<MissionRepository>()));

  getIt.registerFactory(() => AuthBloc(
    login: getIt<Login>(),
    logout: getIt<Logout>(),
    checkAuth: getIt<CheckAuth>(),
  ));
  getIt.registerFactory(() => MissionBloc(
    getDailyMissions: getIt<GetDailyMissions>(),
    updateMissionStatus: getIt<UpdateMissionStatus>(),
  ));
}