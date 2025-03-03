class SchoolClass {
  int? id;
  String name;

  SchoolClass({this.id, required this.name});

  get studentCount => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'],
      name: map['name'],
    );
  }
}