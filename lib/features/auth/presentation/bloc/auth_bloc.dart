import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/check_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final CheckAuth checkAuth;
  
  AuthBloc({required this.login, required this.logout, required this.checkAuth}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }
  
  Future<void> _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final result = await checkAuth.execute();
    result.fold((failure) => emit(AuthUnauthenticated()), (user) => user != null ? emit(AuthAuthenticated(user)) : emit(AuthUnauthenticated()));
  }
  
  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await login.execute(event.email, event.password);
    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }
  
  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logout.execute();
    emit(AuthUnauthenticated());
  }
}

