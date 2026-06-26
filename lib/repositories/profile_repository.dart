abstract interface class ProfileRepository {
  Future<DateTime?> getTrackingStartedAt();
  Future<void> setTrackingStartedAt(DateTime date);
}
