import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:one/di/database.dart';
import 'package:zero/zero.dart';

@Path("/auth")
class AuthController extends Controller with DbMixin {
  AuthController(Request request) : super(request);


  @Path('/login', method: "POST")
  @Body(
    [
      Field("email", isRequired: true),
      Field("password", isRequired: true),
    ],
  )
  Future<Response> login() async {
    final body = request.body;

    final result = await conn?.query(
      'SELECT * FROM users WHERE email = @email AND password = @password',
      substitutionValues: {
        'email': body!['email'],
        'password': hashPassword(body['password'])
      },
    );

    if (result?.isEmpty ?? true) {
      return Response.unauthorized({
        'message': 'Invalid credentials',
      });
    }

    return Response.ok({
      'token': token(result),
    });
  }

  @Path('/register', method: "POST")
  @Body(
    [
      Field("name", isRequired: true),
      Field("email", isRequired: true),
      Field("password", isRequired: true, pattern: r'^[a-zA-Z0-9]{6,}$'),
    ],
  )
  Future<Response> register() async {
    try {
      final body = request.body!;

      var result = await conn?.query(
          'INSERT INTO users (name, email, password, role) VALUES (@name, @email, @password, \'ADMIN\')',
          substitutionValues: {
            'name': body['name'],
            'email': body['email'],
            'password': hashPassword(body['password'])
          });

      if (result == null) {
        return Response.badRequest({
          'message': 'User already exists',
        });
      }

      return Response.created({
        'message': 'User created',
      });
    } catch (e) {
      return Response.internalServerError(e.toString());
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password + Env().env['SALT']!);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String token(result) {
    final jwt = JWT(
        {
          'id': result![0][0],
          'name': result[0][1],
          'email': result[0][2],
          'role': result[0][4],
        },
        issuer: 'one',
        subject: 'auth',
        header: {
          'typ': 'JWT',
        });

    return jwt.sign(SecretKey(
      Env().env['JWT_SECRET']!,
    ));
  }
}
