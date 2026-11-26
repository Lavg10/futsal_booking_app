abstract final class AppConstants {
  static const String usersCollection = 'users';
  static const String ownerApplicationsCollection = 'ownerApplications';
  static const String ownersCollection = 'owners';
  static const String groundsCollection = 'grounds';

  static const String ownerDocumentsPath = 'owner-documents';
  static const String groundImagesPath = 'ground-images';

  static const double nearbyRadiusKm = 10;
  static const int geohashPrecision = 9;
  static const int maxImageSizeMb = 5;

  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  static const String roleUser = 'user';
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
}
