import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Supported locales ────────────────────────────────────────────────────────

const Locale kLocaleEn = Locale('en');
const Locale kLocalePh = Locale('ph');
const Locale kLocaleEe = Locale('ee');
const List<Locale> kSupportedLocales = <Locale>[kLocaleEn, kLocalePh, kLocaleEe];
const Locale kFallbackLocale = kLocaleEn;

// ── Translation lookup ───────────────────────────────────────────────────────

class AppTranslations {
  AppTranslations._(this._data);

  final Map<String, dynamic> _data;

  static AppTranslations? _instance;
  static AppTranslations get instance => _instance ?? AppTranslations._(<String, dynamic>{});

  static Future<void> load(Locale locale) async {
    final String file = 'assets/translations/${locale.languageCode}.json';
    try {
      final String raw = await rootBundle.loadString(file);
      _instance = AppTranslations._(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Fallback: load English
      try {
        final String raw = await rootBundle.loadString('assets/translations/en.json');
        _instance = AppTranslations._(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _instance = AppTranslations._(<String, dynamic>{});
      }
    }
  }

  /// Resolves a dot-separated key like 'navigation.home'.
  String tr(String key) {
    final List<String> parts = key.split('.');
    dynamic node = _data;
    for (final String part in parts) {
      if (node is Map<String, dynamic>) {
        node = node[part];
      } else {
        return key;
      }
    }
    return node is String ? node : key;
  }
}

// ── InheritedWidget ──────────────────────────────────────────────────────────

class AppLocale extends InheritedWidget {
  const AppLocale({
    super.key,
    required this.locale,
    required this.translations,
    required this.setLocale,
    required super.child,
  });

  final Locale locale;
  final AppTranslations translations;
  final void Function(Locale) setLocale;

  static AppLocale of(BuildContext context) {
    final AppLocale? result = context.dependOnInheritedWidgetOfExactType<AppLocale>();
    assert(result != null, 'No AppLocale found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppLocale old) => locale != old.locale;
}

// ── Root wrapper ─────────────────────────────────────────────────────────────

class AppLocaleScope extends StatefulWidget {
  const AppLocaleScope({super.key, required this.child});

  final Widget child;

  @override
  State<AppLocaleScope> createState() => _AppLocaleScopeState();
}

class _AppLocaleScopeState extends State<AppLocaleScope> {
  Locale _locale = kFallbackLocale;
  AppTranslations _translations = AppTranslations.instance;

  static const String _prefKey = 'app_locale';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Locale _localeFromCode(String? code) {
    if (code == null) return kFallbackLocale;
    return kSupportedLocales.firstWhere(
      (Locale l) => l.languageCode == code,
      orElse: () => kFallbackLocale,
    );
  }

  Future<void> _init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_prefKey);
    final Locale locale = _localeFromCode(saved);
    await AppTranslations.load(locale);
    if (mounted) {
      setState(() {
        _locale = locale;
        _translations = AppTranslations.instance;
      });
    }
  }

  Future<void> _setLocale(Locale locale) async {
    if (locale == _locale) return;
    await AppTranslations.load(locale);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    if (mounted) {
      setState(() {
        _locale = locale;
        _translations = AppTranslations.instance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLocale(
      locale: _locale,
      translations: _translations,
      setLocale: _setLocale,
      child: widget.child,
    );
  }
}

// ── Convenience helpers ──────────────────────────────────────────────────────

/// Translates a dot-separated key using the current locale.
/// Call as `context.tr('navigation.home')`.
extension AppLocaleContext on BuildContext {
  String tr(String key) => AppLocale.of(this).translations.tr(key);
  Locale get appLocale => AppLocale.of(this).locale;
  void setAppLocale(Locale locale) => AppLocale.of(this).setLocale(locale);
}

/// Maps an API language string to a supported [Locale].
/// Defaults to English for unknown/null values.
Locale resolveLocale(BuildContext context, String? language) {
  if (language == null || language.isEmpty) return kFallbackLocale;
  final String code = language.toLowerCase();
  final Locale? found = kSupportedLocales.where(
    (Locale l) => l.languageCode == code,
  ).firstOrNull;
  return found ?? kFallbackLocale;
}
