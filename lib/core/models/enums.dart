enum UserRole { seeker, donor, orgRep }

enum AidType { food, clothing, medical, cash, school, housing, ceremony, other }

enum UrgencyLevel { low, medium, high, critical }

enum RequestStatus {
  draft,
  submitted,
  verified,
  matched,
  inProgress,
  completed,
  expired,
}

enum OfferStatus { offered, accepted, inTransit, delivered, confirmed }

String enumToApiString(Object value) =>
    value.toString().split('.').last.toLowerCase();

T enumFromApiString<T>(List<T> values, String? raw, T fallback) {
  if (raw == null) {
    return fallback;
  }
  final normalized = raw.toLowerCase();
  return values.firstWhere(
    (value) => value.toString().split('.').last.toLowerCase() == normalized,
    orElse: () => fallback,
  );
}


