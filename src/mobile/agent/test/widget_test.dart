import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/app/app.dart';
import 'package:bmf_agent_app/core/bloc/language/language_cubit.dart';
import 'package:bmf_agent_app/core/enums/app_language.dart';
import 'package:bmf_agent_app/core/security/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  testWidgets('BMF Agent App renders LoginScreen on initial startup', (WidgetTester tester) async {
    final secureStorage = SecureStorageService();
    final languageCubit = LanguageCubit(secureStorage);
    await languageCubit.changeLanguage(AppLanguage.english);

    await tester.pumpWidget(BmfAgentApp(languageCubit: languageCubit));
    await tester.pumpAndSettle();

    expect(find.text('BMF Agent Login'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Agent Username / Code'), findsOneWidget);
  });
}
