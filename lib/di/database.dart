import 'package:postgres/postgres.dart';
import 'package:zero/zero.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  PostgreSQLConnection? conn;
  Env process = Env(path: '.env');

  Future<void> connect() async {
    print("Connecting to database...");
    conn = PostgreSQLConnection(
        process.env['HOST'], int.parse(process.env['PORT']), process.env['DB'],
        username: process.env['USER'], password: process.env['PASS']);
    await conn!.open();
  }

  Future<void> disconnect() async {
    await conn!.close();
  }
}


mixin DbMixin {
  final Database _db = Database();
  PostgreSQLConnection? get conn => _db.conn;
}