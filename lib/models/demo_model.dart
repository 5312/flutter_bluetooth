class DemoModel {
  String? name;
  String? mail;

  DemoModel({this.name, this.mail});

  DemoModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mail = json['mail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'mail': mail,
    };

    return data;
  }
}
