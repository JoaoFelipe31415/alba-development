import 'package:alba/data/repositories/auth_repository.dart';
import 'package:auto_injector/auto_injector.dart';

final injector = AutoInjector();

void setupInjector() {
  injector.addSingleton<AuthRepository>(AuthRepository.new);

  injector.commit();
}
