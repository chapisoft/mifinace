/// Service interface for pulling catalog, centers, groups, and loan schedules from the Backend BFF Gateway.
abstract class PullSyncService {
  /// Pulls delta updates from the server and persists them into the encrypted local database.
  Future<int> pullCatalogDelta({DateTime? since});
}
