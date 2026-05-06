import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logest_planning/core/theme/app_theme.dart';
import 'package:logest_planning/core/database/hive_service.dart';
import 'package:logest_planning/injection.dart';
import 'package:logest_planning/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logest_planning/features/auth/presentation/pages/login_page.dart';
import 'package:logest_planning/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await configureInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: MaterialApp(
        title: 'Logest Planning',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}