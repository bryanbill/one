import 'dart:io';

import 'package:one/di/database.dart';
import 'package:zero/zero.dart';

class IndexController extends Controller with DbMixin {
  IndexController(Request request) : super(request);

  @Path('/')
  Future<Response> hello() async {
    final html =
        File(Directory.current.path + '/public/index.html').readAsStringSync();
    return Response.ok(html, {'Content-Type': 'text/html'});
  }

  @Path('/favicon.ico')
  Future<Response> favicon() async {
    final favicon =
        File(Directory.current.path + '/public/favicon.ico').readAsBytesSync();
    return Response.ok(favicon, {'Content-Type': 'image/x-icon'});
  }
}
