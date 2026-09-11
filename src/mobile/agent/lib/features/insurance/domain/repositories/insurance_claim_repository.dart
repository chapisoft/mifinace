import '../models/insurance_claim.dart';

/// Repository interface for mutual micro-insurance claim intake and query.
abstract class InsuranceClaimRepository {
  /// Submits an insurance claim, saving locally in offline queue and optionally syncing online.
  Future<InsuranceClaim> submitClaim(InsuranceClaim claim);

  /// Retrieves insurance claims submitted for a given member or center.
  Future<List<InsuranceClaim>> getClaims({String? memberNrc, String? centerCode});
}
