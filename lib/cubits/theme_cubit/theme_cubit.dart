import 'package:bloc/bloc.dart';
import 'package:vegesea/models/enums/theme_state.dart';
import 'package:vegesea/shared/shared/constants.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());
  changeTheme(ThemeStat state) {
    switch (state) {
      case ThemeStat.Initial:
        if (sharedPreferences!.getString('theme') != null) {
          if (sharedPreferences!.getString('theme') == 'l') {
            emit(AppLightTheme());
          } else {
            emit(AppDarkTheme());
          }
        }
        break;
      case ThemeStat.Light:
        sharedPreferences!.setString('theme', 'l');
        emit(AppLightTheme());
        break;
      case ThemeStat.Dark:
        sharedPreferences!.setString('theme', 'd');

        emit(AppDarkTheme());

        break;
    }
  }
}
