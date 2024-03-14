import 'dart:convert';

import 'package:api_crud/screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Todo List')),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTod,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(onSelected: (value) {
                    if (value == 'Edit') {
                      NavigateToEditPage(item);
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => AddTodoPage(
                      //           todo: item,
                      //         )));
                    } else if (value == 'Delete') {
                      deleteById(id);
                    }
                  }, itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                          value: 'Edit',
                          child: Row(
                            children: [Icon(Icons.edit), Text('Edit')],
                          )),
                      const PopupMenuItem(
                          value: 'Delete',
                          child: Row(
                            children: [Icon(Icons.delete), Text('Delete')],
                          ))
                    ];
                  }),
                );
              }),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: NavigateToADDPage,
        label: const Text('Add Todo'),
      ),
    );
  }

  Future<void> NavigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(
              todo: item,
            ));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTod();
  }

  Future<void> NavigateToADDPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTod();
  }

  Future<void> deleteById(String id) async {
    //Delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      //Remove the Item from the list
      final filter = items.where((element) => element['_id '] != id).toList();
      setState(() {
        items = filter;
      });
    } else {
      showErrorMessage('Unable to Delete');
    }
  }

  Future<void> fetchTod() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
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
