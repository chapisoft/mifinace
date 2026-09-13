import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/customer_saving_account.dart';
import '../../domain/repositories/savings_repository.dart';

/// Implementation of [SavingsRepository] querying Core Saving Gateway.
class SavingsRepositoryImpl implements SavingsRepository {
  final ApiClient _apiClient;
  final List<CustomerSavingAccount> _accounts = [];

  SavingsRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(secureStorage: SecureStorageService());

  @override
  Future<List<CustomerSavingAccount>> getSavingAccounts(String memberNrc) async {
    AppLogger.info('Retrieving savings accounts for member: $memberNrc', tag: 'SavingsRepo');

    try {
      final response = await _apiClient.get(ApiEndpoints.getMySavings);
      if (response.statusCode == 200 && response.data != null) {
        final dynamic body = response.data;
        List<dynamic> list = [];
        if (body is Map<String, dynamic>) {
          if (body['data'] is List) {
            list = body['data'] as List<dynamic>;
          } else if (body['data'] is Map && body['data']['accounts'] is List) {
            list = body['data']['accounts'] as List<dynamic>;
          }
        } else if (body is List) {
          list = body;
        }

        final fetched = list
            .whereType<Map<String, dynamic>>()
            .map((item) => CustomerSavingAccount.fromJson(item))
            .toList();
        _accounts.clear();
        _accounts.addAll(fetched);
        return List.unmodifiable(_accounts);
      }
    } catch (e) {
      AppLogger.warn('Remote savings accounts fetch failed: $e. Returning cached accounts.', tag: 'SavingsRepo');
    }

    return List.unmodifiable(_accounts);
  }

  @override
  Future<CustomerSavingAccount> openFixedTermSaving({
    required String memberNrc,
    required double initialDepositMmk,
    required int tenureMonths,
    required String beneficiaryName,
  }) async {
    AppLogger.info('Opening new $tenureMonths-month fixed savings for $memberNrc, beneficiary: $beneficiaryName', tag: 'SavingsRepo');

    try {
      final response = await _apiClient.post(
        ApiEndpoints.openSavings,
        data: {
          'customerCode': memberNrc,
          'productType': 'FIXED_TERM',
          'initialDepositMmk': initialDepositMmk,
          'tenureMonths': tenureMonths,
          'beneficiaryName': beneficiaryName,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic body = response.data;
        final data = body is Map<String, dynamic> ? (body['data'] ?? body) : <String, dynamic>{};
        final account = CustomerSavingAccount.fromJson(data);
        _accounts.add(account);
        return account;
      }
      throw Exception('Mở sổ tiết kiệm thất bại: Máy chủ trả về mã lỗi HTTP ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Remote openFixedTermSaving failed: $e', tag: 'SavingsRepo');
      throw Exception('Không thể mở sổ tiết kiệm: Máy chủ chưa sẵn sàng hoặc kết nối mạng gián đoạn.');
    }
  }
}
