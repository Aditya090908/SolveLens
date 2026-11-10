import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solvelens/remote_solve_service.dart';
import 'package:solvelens/solve_service.dart';

void main() {
  group('RemoteSolveService', () {
    test('returns success on 200 with answer', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        client: MockClient((http.Request request) async {
          expect(request.url.path, '/v1/solve');
          expect(
            jsonDecode(request.body),
            <String, String>{'question': '2+2'},
          );
          return http.Response(
            jsonEncode(<String, String>{'answer': '4'}),
            200,
          );
        }),
      );

      final SolveOutcome outcome = await service.solve('2+2');
      expect(outcome, isA<SolveOk>());
      expect((outcome as SolveOk).success.answer, '4');
    });

    test('returns invalidResponse when answer missing', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        client: MockClient(
          (_) async => http.Response('{}', 200),
        ),
      );

      final SolveOutcome outcome = await service.solve('hi');
      expect(outcome, isA<SolveErr>());
      expect(
        (outcome as SolveErr).failure.kind,
        SolveErrorKind.invalidResponse,
      );
    });

    test('maps 500 to serverError', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object>{
              'error': <String, String>{
                'code': 'provider_error',
                'message': 'Upstream failed',
              },
            }),
            502,
          ),
        ),
      );

      final SolveOutcome outcome = await service.solve('x');
      expect(outcome, isA<SolveErr>());
      final SolveErr err = outcome as SolveErr;
      expect(err.failure.kind, SolveErrorKind.serverError);
      expect(err.failure.userMessage, 'Upstream failed');
    });

    test('maps 400 to clientError', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object>{
              'error': <String, String>{
                'code': 'invalid_request',
                'message': 'Bad question',
              },
            }),
            400,
          ),
        ),
      );

      final SolveOutcome outcome = await service.solve('x');
      expect((outcome as SolveErr).failure.kind, SolveErrorKind.clientError);
    });

    test('returns timeout on slow response', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        timeout: const Duration(milliseconds: 50),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response('{}', 200);
        }),
      );

      final SolveOutcome outcome = await service.solve('x');
      expect((outcome as SolveErr).failure.kind, SolveErrorKind.timeout);
    });

    test('returns network on connection failure', () async {
      final RemoteSolveService service = RemoteSolveService(
        baseUrl: 'http://example.com',
        client: MockClient((_) async {
          throw const SocketException('failed');
        }),
      );

      final SolveOutcome outcome = await service.solve('x');
      expect((outcome as SolveErr).failure.kind, SolveErrorKind.network);
    });
  });
}
