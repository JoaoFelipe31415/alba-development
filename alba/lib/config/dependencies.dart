import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/ui/menu/menu_viewmodel.dart';
import 'package:auto_injector/auto_injector.dart';

final injector = AutoInjector();

void setupInjector() {
  injector.addSingleton<AuthRepository>(AuthRepository.new);
  injector.addSingleton<MetasRepository>(MetasRepository.new);

  injector.add<MenuViewModel>(
    () => MenuViewModel(injector.get<AuthRepository>()),
  );
  injector.commit();
}
