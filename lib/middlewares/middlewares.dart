import 'dart:async';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:zero/zero.dart';

class Admin extends Middleware {
  const Admin();

  @override
  FutureOr<RequestOrResponse> handle(Request request) {
    final token = request.headers?['authorization'];

    if (token == null)
      return RequestOrResponse(
        response: Response.unauthorized({'message': 'Unauthorized'}),
      );

    final jwt = JWT.verify(token, SecretKey(Env().env['JWT_SECRET']!));

    if (jwt.payload['role'] != 'ADMIN') {
      return RequestOrResponse(
        response: Response.unauthorized({'message': 'Unauthorized'}),
      );
    }

    return RequestOrResponse(request: request);
  }
}

class Auth implements Middleware {
  const Auth();

  @override
  FutureOr<RequestOrResponse> handle(Request request) {
    try {
      final token = request.headers?['authorization'];

      if (token == null)
        return RequestOrResponse(
          response: Response.unauthorized({'message': 'Unauthorized'}),
        );

      final jwt = JWT.verify(token, SecretKey(Env().env['JWT_SECRET']!));
     
      if (jwt.payload['role'] != 'user' && jwt.payload['role'] != 'ADMIN') {
        return RequestOrResponse(
          response: Response.unauthorized({'message': 'Unauthorized'}),
        );
      }

      //add user id to request params, copy the old params if you want to keep it
      request.params = {
        ...request.params ?? {},
        '_id': jwt.payload['id'],
      };
      return RequestOrResponse(request: request);
    } catch (e) {
      if (e is JWTExpiredError)
        return RequestOrResponse(
          response: Response.unauthorized({'message': 'Token expired'}),
        );

      if (e is JWTInvalidError)
        return RequestOrResponse(
          response: Response.unauthorized({'message': 'Invalid token'}),
        );
      return RequestOrResponse(
        response: Response.unauthorized({'message': 'Unauthorized'}),
      );
    }
  }
}

