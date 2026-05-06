class Mission {
  final int id;
  final int consultantId;
  final String title;
  final String clientName;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String status;
  final String? contactName;
  final String? contactPhone;
  final bool requiresSignature;

  const Mission({
    required this.id,
    required this.consultantId,
    required this.title,
    required this.clientName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    this.contactName,
    this.contactPhone,
    this.requiresSignature = false,
  });
}
