import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/consultant/presentation/pages/consultant_home_page.dart';
import '../features/planner/presentation/pages/planner_dashboard.dart';
import '../features/direction/presentation/pages/direction_home.dart';

class AppRoutes {
  static const String login = '/';
  static const String consultant = '/consultant';
  static const String planner = '/planner';
  static const String director = '/director';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case consultant:
        return MaterialPageRoute(builder: (_) => const ConsultantHomePage());
      case planner:
        return MaterialPageRoute(builder: (_) => const PlannerDashboard());
      case director:
        return MaterialPageRoute(builder: (_) => const DirectionHome());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}