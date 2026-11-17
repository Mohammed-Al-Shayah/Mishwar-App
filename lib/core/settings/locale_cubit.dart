import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._preferences)
    : super(Locale(_preferences.getString('locale') == 'en' ? 'en' : 'ar'));
  final SharedPreferences _preferences;
  Future<void> setLocale(String language) async {
    if (language != 'ar' && language != 'en') return;
    emit(Locale(language));
    await _preferences.setString('locale', language);
  }
}
