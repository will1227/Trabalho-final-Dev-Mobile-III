class UserModel {
  String? id;
  String? name;
  String? email;
  String? avatar;
  String? createdAt;

  UserModel({this.id, this.name, this.email, this.avatar, this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatar: json['avatar'],
        createdAt: json['createdAt']);
  }

  //converte um UserModel em um Map (json)
  static Map<String, dynamic> toJson(UserModel userModel) {
    Map<String, dynamic> json = {
      'name': userModel.name,
      'email': userModel.email,
      'avatar': userModel.avatar
    };
    return json;
  }
}
