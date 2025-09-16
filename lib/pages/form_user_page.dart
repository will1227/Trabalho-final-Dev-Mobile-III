import 'package:flutter/material.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/repositories/users_repository.dart';

class FormUserPage extends StatefulWidget {
  FormUserPage({super.key, this.userEdit});

  UserModel? userEdit;

  @override
  State<FormUserPage> createState() => _FormUserPageState();
}

class _FormUserPageState extends State<FormUserPage> {
  TextEditingController txtNameController = TextEditingController();

  TextEditingController txtEmailController = TextEditingController();

  TextEditingController txtPhotoController = TextEditingController();

  String? id;

  final formKey = GlobalKey<FormState>();

  //instanciar o repositório
  final repository = UsersRepository();

  updateUser() async {
    try {
      await repository.updateUser(
        UserModel(
          id: id,
          name: txtNameController.text,
          email: txtEmailController.text,
          avatar: txtPhotoController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  saveUser() async {
    try {
      //criar o UserModel a partir dos dados do formulário
      UserModel userModel = UserModel(
        name: txtNameController.text,
        email: txtEmailController.text,
        avatar: txtPhotoController.text,
      );

      //salvar o usuário no banco
      await repository.postNewUser(userModel);

      //mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos!')),
      );

      //voltar para a tela anterior
      Navigator.pop(context);
    } catch (e) {
      //mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userEdit != null) {
      txtNameController.text = widget.userEdit?.name ?? '';
      txtEmailController.text = widget.userEdit?.email ?? '';
      txtPhotoController.text = widget.userEdit?.avatar ?? '';
      id = widget.userEdit?.id ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulário usuário"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obrigatório";
                    }
                    return null;
                  },
                  controller: txtNameController,
                  decoration:
                      const InputDecoration(hintText: "Preencha o nome"),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obrigatório";
                    }
                    return null;
                  },
                  controller: txtEmailController,
                  decoration:
                      const InputDecoration(hintText: "Preencha o email"),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obrigatório";
                    }
                    return null;
                  },
                  controller: txtPhotoController,
                  decoration:
                      const InputDecoration(hintText: "Preencha a foto"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (widget.userEdit != null) {
                        updateUser();
                      } else {
                        //pegar os valores e salvar no DB
                        saveUser();
                      }
                    }
                  },
                  child: const Text("Salvar"),
                )
              ],
            )),
      ),
    );
  }
}
