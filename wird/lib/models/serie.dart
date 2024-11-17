class Serie {
  int? id;
  int? rosaryId;
  final String title;
  final int count;

  Serie({this.id, this.rosaryId, required this.title, required this.count});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rosaryId': rosaryId,
      'title': title,
      'count': count,
    };
  }

  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      id: map['id'],
      rosaryId: map['rosaryId'],
      title: map['title'],
      count: map['count'],
    );
  }
}
