import 'package:wird/models/serie.dart';

class Rosary {
  int? id;
  String name;

  List<Serie> rosarySeries = [];

  Rosary({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Rosary.fromMap(Map<String, dynamic> map) {
    return Rosary(
      id: map['id'],
      name: map['name'],
    );
  }
}
