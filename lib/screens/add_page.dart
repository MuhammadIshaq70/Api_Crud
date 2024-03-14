import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo!['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Padding(padding: EdgeInsets.only(left: 20, right: 20)),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(borderSide: BorderSide(width: 2))),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            maxLines: 8,
            minLines: 5,
            decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(borderSide: BorderSide(width: 2))),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: isEdit ? updatedData : SubmiteData,
              child: Text(isEdit ? 'Update' : 'Submited'))
        ],
      ),
    );
  }

  Future<void> updatedData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('you can not call updated data with out todo data');
      return;
    }
    final id = todo['_id'];
    // final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final discription = descriptionController.text;
    final body = {
      "title": title,
      "description": discription,
      "is_completed": false,
    };
    //Submit updated  data to the server
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      // titleController.text = '';
      // descriptionController.text = '';
      showSuccessMessage(' updation Successfully ');
    } else {
      showErrorMessage('updation failed');
    }
  }

  Future<void> SubmiteData() async {
    //Get the data from form
    final title = titleController.text;
    final discription = descriptionController.text;
    final body = {
      "title": title,
      "description": discription,
      "is_completed": false,
    };

    //Submit data to the server

    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show  success or fail message on based status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Successfully added');
    } else {
      showErrorMessage('Creation failed');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
