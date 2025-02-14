class Commodiity {
  String id;
  String name;
  String? type;

  Commodiity({
    required this.id,
    required this.name,
    this.type,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
