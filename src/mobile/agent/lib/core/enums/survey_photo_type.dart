/// Types of field survey photos required for microfinance loan origination.
enum SurveyPhotoType {
  nrcFront(code: 'NRC_FRONT', label: 'Thẻ căn cước mặt trước', myanmarLabel: 'မှတ်ပုံတင် အရှေ့ဘက်'),
  nrcBack(code: 'NRC_BACK', label: 'Thẻ căn cước mặt sau', myanmarLabel: 'မှတ်ပုံတင် အနောက်ဘက်'),
  houseFront(code: 'HOUSE_FRONT', label: 'Hiện trạng mặt tiền nhà ở', myanmarLabel: 'နေအိမ်အရှေ့ဘက်မြင်ကွင်း'),
  livingRoom(code: 'LIVING_ROOM', label: 'Hiện trạng phòng khách/nội thất', myanmarLabel: 'ဧည့်ခန်းမြင်ကွင်း'),
  businessSite(code: 'BUSINESS_SITE', label: 'Địa điểm canh tác / kinh doanh', myanmarLabel: 'စီးပွားရေး/စိုက်ပျိုးမြေနေရာ'),
  livestockBarn(code: 'LIVESTOCK_BARN', label: 'Chuồng trại gia súc', myanmarLabel: 'တိရစ္ဆာန်မွေးမြူရေးခြံ');

  final String code;
  final String label;
  final String myanmarLabel;

  const SurveyPhotoType({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static SurveyPhotoType fromCode(String? code) {
    if (code == null) return SurveyPhotoType.nrcFront;
    for (final type in SurveyPhotoType.values) {
      if (type.code == code || type.name.toUpperCase() == code.toUpperCase()) {
        return type;
      }
    }
    return SurveyPhotoType.nrcFront;
  }
}
