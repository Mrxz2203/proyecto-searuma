import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String?> translateToSpanish(String? text) async {
    if (text == null || text.trim().isEmpty) return text;
    try {
      final result = await _translator.translate(text, from: 'en', to: 'es');
      return result.text;
    } catch (e) {
      // Si falla la traducción (rate-limit, sin conexión, etc.),
      // mostramos el texto original en inglés en vez de romper la pantalla.
      return text;
    }
  }
}