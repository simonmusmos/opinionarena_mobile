import 'package:flutter/widgets.dart';
import 'package:intra/l10n/app_locale.dart';

class LocaleUtils {
  LocaleUtils._();

  /// Resolves the API language string and applies it to the app locale.
  static void apply(BuildContext context, String? language) {
    final Locale locale = resolveLocale(context, language);
    context.setAppLocale(locale);
  }
}
