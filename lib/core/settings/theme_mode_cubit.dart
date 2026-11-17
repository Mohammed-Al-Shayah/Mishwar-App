import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._preferences)
    : super(
        ThemeMode.values.firstWhere(
          (mode) => mode.name == _preferences.getString('themeMode'),
          orElse: () => ThemeMode.system,
        ),
      );
  final SharedPreferences _preferences;
  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _preferences.setString('themeMode', mode.name);
  }
}
