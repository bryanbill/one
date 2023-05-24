import 'dart:async';

import 'package:one/di/database.dart';
import 'package:one/middlewares/middlewares.dart';
import 'package:one/models/user_model.dart';
import 'package:zero/zero.dart';

class UserController extends Controller with DbMixin {
  final Request request;

  UserController(this.request) : super(request);

  @Path('/me', method: "GET")
  @Auth()
  Future<Response> me() async {
    try {
      if (request.params?['_id'] == null) {
        return Response.unauthorized({
          'message': 'Invalid token',
        });
      }

      final user = await conn
          ?.query('SELECT * FROM users WHERE id = @id', substitutionValues: {
        'id': request.params?['_id'],
      }).then((value) {
        final row = value.sublist(0, value.length)..removeAt(3);
        print(row);
        return User.fromPostgres(row);
      });

      return Response.ok(user?.toJson());
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  @Path('/', method: "GET")
  @Admin()
  Future<Response> getUsers() async {
    final users = await conn
        ?.query('SELECT * FROM users')
        .then((value) => value.map((e) => User.fromPostgres(e)).toList());

    return Response.ok(users!.map((e) => e.toJson()).toList());
  }

  @Path('/:id', method: "GET")
  @Param(['id'])
  @Admin()
  Future<Response> getUser() async {
    try {
      final id = request.params!['id'];

      final user = await conn
          ?.query('SELECT * FROM users WHERE id = @id', substitutionValues: {
        'id': id,
      }).then((value) => User.fromPostgres(value));

      if (user == null) {
        return Response.notFound({
          'message': 'User not found',
        });
      }
      return Response.ok(user.toJson());
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  @Path('/search', method: "POST")
  @Admin()
  Future<Response> searchUser() async {
    try {
      final body = request.body;

      print(body);
      final users = await conn?.query(
          'SELECT * FROM users WHERE name LIKE @name OR email LIKE @email',
          substitutionValues: {
            'name': '%${body?['name']}%',
            'email': '%${body?['email']}%',
          }).then((value) => value.map((e) => User.fromPostgres(e)).toList());

      return Response.ok(users?.map((e) => e.toJson()).toList());
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }
}
