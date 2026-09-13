import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../presentation/screens/branch_network_screen.dart';

/// Service responsible for loading official Microfinance Branch Directory.
class BranchDirectoryService {
  final ApiClient _apiClient;

  BranchDirectoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(secureStorage: SecureStorageService());

  Future<List<BranchPoint>> getBranchPoints() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.branches);
      if (response.statusCode == 200 && response.data != null) {
        final dynamic body = response.data;
        final List<dynamic> list = body is Map<String, dynamic> && body['data'] is List
            ? body['data'] as List<dynamic>
            : (body is List ? body : []);
        if (list.isNotEmpty) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => BranchPoint.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      AppLogger.warn('Remote branch catalog fetch failed: $e. Returning static directory.', tag: 'BranchService');
    }

    return defaultBranches;
  }

  static const List<BranchPoint> defaultBranches = [
    BranchPoint(
      code: 'BR-YGN-01',
      name: 'Chi Nhánh Trung Tâm Yangon (Head Office)',
      type: 'MAIN_BRANCH',
      region: 'Yangon',
      township: 'Dagon Township',
      address: 'Số 142 Đường Pyay, Dagon Township, Yangon',
      phone: '01-2305899',
      workingHours: '08:00 - 16:30 (Thứ 2 - Thứ 6)',
      distanceKm: 1.2,
      isOpenNow: true,
      services: ['Giải ngân vốn', 'Thu nợ MMQR & Tiền mặt', 'Mở sổ tiết kiệm', 'Thẩm định tín dụng', 'Đổi ngoại tệ'],
    ),
    BranchPoint(
      code: 'BR-YGN-02',
      name: 'Phòng Giao Dịch Hlaing Tharyar',
      type: 'SUB_BRANCH',
      region: 'Yangon',
      township: 'Hlaing Tharyar',
      address: 'Số 58 Khu công nghiệp Hlaing Tharyar, Yangon',
      phone: '01-6890123',
      workingHours: '08:00 - 16:30 (Thứ 2 - Thứ 6)',
      distanceKm: 4.5,
      isOpenNow: true,
      services: ['Giải ngân tiểu thương', 'Thu nợ', 'Gửi tiết kiệm', 'Hỗ trợ Smart OTP'],
    ),
    BranchPoint(
      code: 'BR-YGN-03',
      name: 'Điểm Giao Dịch Xã Thanlyin',
      type: 'VILLAGE_POINT',
      region: 'Yangon',
      township: 'Thanlyin',
      address: 'Trụ sở Hợp tác xã Nông nghiệp Thanlyin, Yangon',
      phone: '09-450123456',
      workingHours: '08:30 - 15:30 (Thứ 3, Thứ 5 hàng tuần)',
      distanceKm: 8.7,
      isOpenNow: false,
      services: ['Vay nông nghiệp', 'Sinh hoạt cụm nhóm', 'Thu nợ định kỳ'],
    ),
    BranchPoint(
      code: 'BR-MDY-01',
      name: 'Chi Nhánh Mandalay Central',
      type: 'MAIN_BRANCH',
      region: 'Mandalay',
      township: 'Chanayethazan',
      address: 'Số 73 Đường 26x77, Chanayethazan, Mandalay',
      phone: '02-4067890',
      workingHours: '08:00 - 16:30 (Thứ 2 - Thứ 6)',
      distanceKm: 620.0,
      isOpenNow: true,
      services: ['Giải ngân vốn', 'Thu nợ MMQR', 'Tiết kiệm vi mô', 'Thẩm định hộ kinh doanh'],
    ),
    BranchPoint(
      code: 'BR-BGO-01',
      name: 'Phòng Giao Dịch Bago City',
      type: 'SUB_BRANCH',
      region: 'Bago',
      township: 'Bago Township',
      address: 'Số 12 Đường Yangon-Mandalay, Bago',
      phone: '052-220145',
      workingHours: '08:00 - 16:30 (Thứ 2 - Thứ 6)',
      distanceKm: 78.0,
      isOpenNow: true,
      services: ['Vay mùa vụ lúa', 'Thu nợ', 'Mở sổ tiết kiệm', 'Hỗ trợ bồi thường'],
    ),
    BranchPoint(
      code: 'BR-AYY-01',
      name: 'Điểm Dịch Vụ Nông Nghiệp Pathein',
      type: 'VILLAGE_POINT',
      region: 'Ayeyarwady',
      township: 'Pathein',
      address: 'Ấn số 4, Cụm Nông nghiệp Pathein, Ayeyarwady',
      phone: '042-24567',
      workingHours: '08:00 - 15:00 (Thứ 2 - Thứ 6)',
      distanceKm: 185.0,
      isOpenNow: true,
      services: ['Vay nông nghiệp', 'Thu nợ nhóm', 'Tập huấn tín dụng'],
    ),
    BranchPoint(
      code: 'BR-NPT-01',
      name: 'Phòng Giao Dịch Thủ Đô Naypyidaw',
      type: 'SUB_BRANCH',
      region: 'Naypyidaw',
      township: 'Zabuthiri',
      address: 'Khu thương mại Zabuthiri, Naypyidaw',
      phone: '067-8109234',
      workingHours: '08:00 - 16:30 (Thứ 2 - Thứ 6)',
      distanceKm: 340.0,
      isOpenNow: true,
      services: ['Tín dụng cán bộ', 'Tiết kiệm', 'Dịch vụ MMQR'],
    ),
  ];
}
