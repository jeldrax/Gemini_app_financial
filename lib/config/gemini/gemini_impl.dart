import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiImpl {
  // Se crea una instancia de Dio configurando como URL base el valor de ENDPOINT_API del .env.
  // Si la variable no existe, usa una cadena vacía como respaldo.
  final Dio http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  /// Envía el [prompt] del usuario al endpoint `/basic-prompt` del backend
  /// y devuelve la respuesta generada por Gemini como texto.
  Future<String> getResponse(String prompt) async {
    // Convierte el mapa {'prompt': prompt} a una cadena JSON para enviarlo en el body de la petición.
    final body = jsonEncode({'prompt': prompt});

    // Realiza una petición POST asíncrona concatenando '/basic-prompt' a la baseUrl configurada en Dio.
    final response = await http.post('/basic-prompt', data: body);

    print(response.data);

    return 'Hola mundo desde gemini';
  }
}
