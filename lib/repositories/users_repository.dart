import 'dart:convert';

import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:http/http.dart' as http;

class UsersRepository {
  final urlBaseApi = "${baseURLMockApi}users";

  Future<List<UserModel>> getUsers() async {
    List<UserModel> usersList = [];

    final response = await http.get(Uri.parse(urlBaseApi));
    if (response.statusCode == 200) {
      //string para json
      final List<dynamic> usersJson = jsonDecode(response.body);
      //json para objeto
      for (var user in usersJson) {
        usersList.add(UserModel.fromJson(user));
      }
    }
    return usersList;
  }

  postNewUser(UserModel userModel) async {
    final json = jsonEncode(UserModel.toJson(userModel));
    var response = await http.post(Uri.parse(urlBaseApi), body: json);
    if (response.statusCode != 201) {
      throw 'Problemas ao inserir Usuário';
    }
  }

  deleteUser(String id) async {
    final url = '$urlBaseApi/$id';
    var response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw 'Problemas ao excluir usuário';
    }
  }

  updateUser(UserModel userModel) async {
    //monta a url com o id do usuario
    //mockapi.com/users/123
    final url = '$urlBaseApi/${userModel.id}';
    final json = jsonEncode(UserModel.toJson(userModel));
    var response = await http.put(Uri.parse(url), body: json);
    if (response.statusCode != 200) {
      throw 'Problemas ao atualizar usuário';
    }
  }
}
