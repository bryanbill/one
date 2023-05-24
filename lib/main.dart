import 'package:one/controllers/auth_controller.dart';
import 'package:one/controllers/community_controller.dart';
import 'package:one/controllers/index_controller.dart';
import 'package:one/controllers/users_controller.dart';
import 'package:one/di/database.dart';
import 'package:zero/zero.dart';

void main() async {
  try {
    await Database()
      ..connect();

    final zero = Server(routes: [
      Route(path: '/auth', controller: (req) => AuthController(req)),
      Route(path: '/users', controller: (req) => UserController(req)),
      Route(
          path: "/communities", controller: (req) => CommunityController(req)),
      Route(path: '/__dev', controller: (req) => IndexController(req)),
      Route(path: '/404', controller: (req) => IndexController(req)),
    ]);

    zero.run();

    print('Listening on port ${zero.port}');
  } catch (e) {
    print(e);
  }
}
