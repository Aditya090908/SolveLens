import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'solve_service.dart';

/// Calls the SolveLens FastAPI proxy at [baseUrl]/v1/solve.
class RemoteSolveService implements SolveService {
  RemoteSolveService({
    String? baseUrl,
    http.Client? client,
    Duration? timeout,
  })  : _baseUrl = (baseUrl ?? SolveLensConfig.apiBaseUrl).replaceAll(
          RegExp(r'/+$'),
          '',
        ),
        _client = client ?? http.Client(),
        _timeout = timeout ?? SolveLensConfig.solveTimeout;

  final String _baseUrl;
  final http.Client _client;
  final Duration _timeout;

  @override
  Future<SolveOutcome> solve(String question) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/solve');
    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{'question': question}),
          )
          .timeout(_timeout);

      return _mapResponse(response);
    } on TimeoutException {
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.timeout,
          userMessage:
              'This is taking too long. Please try again.',
        ),
      );
    } on SocketException {
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.network,
          userMessage:
              "Couldn't reach SolveLens. Check your connection and try again.",
        ),
      );
    } on http.ClientException {
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.network,
          userMessage:
              "Couldn't reach SolveLens. Check your connection and try again.",
        ),
      );
    } catch (_) {
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.network,
          userMessage:
              "Couldn't reach SolveLens. Check your connection and try again.",
        ),
      );
    }
  }

  SolveOutcome _mapResponse(http.Response response) {
    final int status = response.statusCode;
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (_) {
      body = null;
    }

    if (status >= 200 && status < 300) {
      final Object? answer = body?['answer'];
      if (answer is String && answer.isNotEmpty) {
        return SolveOk(SolveSuccess(answer));
      }
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.invalidResponse,
          userMessage: 'Something went wrong. Please try again.',
        ),
      );
    }

    final String? serverMessage = _errorMessage(body);
    if (status >= 400 && status < 500) {
      return SolveErr(
        SolveFailure(
          kind: SolveErrorKind.clientError,
          userMessage: serverMessage ??
              "Couldn't process that question. Please try again.",
        ),
      );
    }

    return SolveErr(
      SolveFailure(
        kind: SolveErrorKind.serverError,
        userMessage: serverMessage ??
            'SolveLens is temporarily unavailable. Try again later.',
      ),
    );
  }

  String? _errorMessage(Map<String, dynamic>? body) {
    final Object? error = body?['error'];
    if (error is Map<String, dynamic>) {
      final Object? message = error['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
