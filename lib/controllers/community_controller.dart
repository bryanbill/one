import 'package:one/di/database.dart';
import 'package:one/middlewares/middlewares.dart';
import 'package:one/models/community_model.dart';
import 'package:one/models/user_model.dart';
import 'package:zero/zero.dart';

class CommunityController extends Controller with DbMixin {
  final Request request;

  CommunityController(this.request) : super(request);

  @Path('/')
  Future<Response> getCommunities() async {
    var communities = <Community>[];

    await conn
        ?.query("SELECT * FROM communities LIMIT 100")
        .then((value) => communities.add(Community.fromPostgres(value)));

    return Response.ok(communities.map((e) => e.toJson()).toList());
  }

  @Path('/:id')
  @Param(['id'])
  Future<Response> getCommunity() async {
    try {
      final id = request.params!['id'];

      final community = await conn?.query(
          'SELECT * FROM communities WHERE id = @id',
          substitutionValues: {
            'id': id,
          }).then((value) => Community.fromPostgres(value));

      if (community == null) {
        return Response.notFound({
          'message': 'Community not found',
        });
      }
      return Response.ok(community.toJson());
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  @Path('/', method: "POST")
  @Body(
    [
      Field("name", isRequired: true),
      Field("description", isRequired: true),
      Field("image", isRequired: true),
    ],
  )
  @Auth()
  Future<Response> createCommunity() async {
    try {
      final body = request.body!;

      var result = await conn?.query(
          'INSERT INTO communities (name, description, owner_id, image) VALUES (@name, @description, @ownerId, @image)',
          substitutionValues: {
            'name': body['name'],
            'description': body['description'],
            'image': body['image'],
            'ownerId': request.params?['_id']
          });

      if (result == null) {
        return Response.internalServerError({
          'message': 'Something went wrong',
        });
      }

      return Response.ok({
        'message': 'Community created successfully',
      });
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  @Path('/:id', method: "PUT")
  @Param(['id'])
  @Body(
    [
      Field("name", isRequired: true),
      Field("description", isRequired: true),
      Field("image", isRequired: true),
    ],
  )
  Future<Response> updateCommunity() async {
    try {
      final id = request.params!['id'];
      final body = request.body!;

      var result = await conn?.query(
          'UPDATE communities SET name = @name, description = @description, image = @image WHERE id = @id',
          substitutionValues: {
            'id': id,
            'name': body['name'],
            'description': body['description'],
            'image': body['image']
          });

      if (result == null) {
        return Response.internalServerError({
          'message': 'Something went wrong',
        });
      }

      return Response.ok({
        'message': 'Community updated successfully',
      });
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  @Path('/:id', method: "DELETE")
  @Param(['id'])
  @Auth()
  Future<Response> deleteCommunity() async {
    try {
      final id = request.params!['id'];

      var result = await conn?.query('DELETE FROM communities WHERE id = @id',
          substitutionValues: {
            'id': id,
          });

      if (result == null) {
        return Response.internalServerError({
          'message': 'Something went wrong',
        });
      }

      return Response.ok({
        'message': 'Community deleted successfully',
      });
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }

  // Members
  @Path("/:id/members")
  @Param(['id'])
  @Auth()
  Future<Response> getMembers() async {
    try {
      final id = request.params?['id'];

      // join community_members and users table
      var members = <User>[];

      await conn?.query(
          "SELECT * FROM community_members INNER JOIN users ON community_members.memberid = users.id WHERE community_id = @id",
          substitutionValues: {
            'id': id,
          }).then((value) {
        value.forEach((element) {
          final row = [
            element.sublist(5, element.length)
              ..removeAt(3)
              ..removeAt(3)
          ];
          members.add(User.fromPostgres(row));
        });
      });

      return Response.ok(members.map((e) => e.toJson()).toList());
    } catch (e) {
      return Response.internalServerError({'message': e.toString()});
    }
  }

  @Path("/:id/members", method: "POST")
  @Param(['id'])
  @Body(
    [
      Field("memberId", isRequired: true),
    ],
  )
  @Auth()
  Future<Response> addMember() async {
    try {
      final id = request.params?['id'];
      final body = request.body!;

      var result = await conn?.query(
          'INSERT INTO community_members (community_id, memberid) VALUES (@communityId, @memberId)',
          substitutionValues: {
            'communityId': id,
            'memberId': body['memberId'],
          });

      if (result == null) {
        return Response.internalServerError({
          'message': 'Something went wrong',
        });
      }

      return Response.ok({
        'message': 'Member added successfully',
      });
    } catch (e) {
      return Response.internalServerError({
        'message': e.toString(),
      });
    }
  }
}
