
class TodoModel {
  int id;
  String title, description;

  TodoModel({
    this.id = 0,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  @override
  String toString() {
    return 'TodoModel{id: $id, title: $title, description: $description}';
  }
}
