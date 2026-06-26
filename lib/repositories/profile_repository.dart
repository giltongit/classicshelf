abstract interface class ProfileRepository {
  Future<DateTime?> getTrackingStartedAt();
  Future<void> setTrackingStartedAt(DateTime date);
  Future<String?> getLibraryName();
  Future<void> setLibraryName(String? name);
}
