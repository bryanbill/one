class Community {
  final int? id;
  final int? ownerId;
  final String? name;
  final String? description;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Community({
    this.id,
    this.name,
    this.ownerId,
    this.image,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Community.fromPostgres(List<dynamic> result) => Community(
        id: result[0][0],
        ownerId: result[0][1],
        name: result[0][2],
        description: result[0][3],
        image: result[0][4],
        createdAt: result[0][5],
        updatedAt: result[0][6],
      );

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        id: json['id'] as int?,
        ownerId: json['owner_id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

}
