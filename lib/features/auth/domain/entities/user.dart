class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  bool get isConsultant => role == 'consultant';
  bool get isPlanner => role == 'planner';
  bool get isDirector => role == 'director';
}