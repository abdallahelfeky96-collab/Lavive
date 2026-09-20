import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangCubit extends Cubit<Locale> {
  LangCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  // تغيير اللغة وحفظها
  void changeLanguage(String languageCode) async {
    emit(Locale(languageCode));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
  }

  // تحميل اللغة المحفوظة عند بدء التطبيق
  void _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('selectedLanguage');
    if (savedLanguageCode != null) {
      emit(Locale(savedLanguageCode));
    }
  }
}
