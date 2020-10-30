import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_list/models/task.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoProvider with ChangeNotifier{
  final String authToken;
  final String userId;
  List<Task> todoList;
  TodoProvider(this.authToken,this.todoList,this.userId);


  var isLoading = false;



  var textController = TextEditingController();


  Future<void> fetchAllTask() async{
    final baseUrl = "https://fir-test-eb2de.firebaseio.com/$userId/task.json?auth=$authToken";
    try {
      final response = await http.get(baseUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<Task> fetchedData = [];
      if (extractedData != null){
        extractedData.forEach((taskId, taskData) {
          fetchedData.add(
              Task(
                  id: taskId,
                  text: taskData['text'],
                  priority: priorityFromString(taskData['priority']),
                  isCompleted: taskData['is_complete']
              )
          );
        });
    }
      todoList = fetchedData;
      notifyListeners();
    }catch(error){
      throw error;
    }
  }

  Future<void> onSaveTask() async{
    final baseUrl = "https://fir-test-eb2de.firebaseio.com/$userId/task.json?auth=$authToken";
    if(textController.text != "" && textController.text != null){
      try{
        final response = await http.post(baseUrl,
            body: json.encode({
              'text': textController.text,
              'is_complete': false,
              'priority': currentPriority.toString()
            }));
        var task = Task(text: textController.text,priority: currentPriority,id: json.decode(response.body)['name']);
        todoList.add(task);
        print(task.id);
        textController.clear();
        notifyListeners();
      }catch(error){
        throw error;
      }
    }

  }

  Future<void> onDeleteTask(String id) async{
    final url = "https://fir-test-eb2de.firebaseio.com/$userId/task/$id.json?auth=$authToken";
    final existingTaskId = todoList.indexWhere((element) => element.id == id);
    var existingTask = todoList[existingTaskId];
    print(id+ " removed");
    todoList.removeAt(existingTaskId);
    notifyListeners();
    final response = await http.delete(url);
      if(response.statusCode >= 400) {
        todoList.insert(existingTaskId, existingTask);
        notifyListeners();
        throw Exception("Error deleting task");
      }
      existingTask = null;
  }

  Priority currentPriority = Priority.Medium;

  void setPriority(Priority priority){
    currentPriority = priority;
    notifyListeners();
  }

  void toggleCompleted(String id) async{
    final url = "https://fir-test-eb2de.firebaseio.com/$userId/task/$id.json?auth=$authToken";
     var task = findTaskById(id);
     var oldValue = task.isCompleted;
     task.isCompleted = !task.isCompleted;
     notifyListeners();

     try{
       final response = await http.patch(url,body: json.encode({'is_complete':task.isCompleted}));
       if(response.statusCode >= 400){
         task.isCompleted = oldValue;
         notifyListeners();
       }
     }catch(error){
       task.isCompleted = oldValue;
       notifyListeners();
     }
  }
  Color getColor(Priority priority){
    if(priority == Priority.High) return Colors.red;
    else if(priority == Priority.Medium)return Colors.orange;
    else return Colors.green;
  }


  Priority priorityFromString(String s){
    if(s == Priority.High.toString()) return Priority.High;
    else if(s == Priority.Medium.toString()) return Priority.Medium;
    else return Priority.Low;
  }

  Task findTaskById(String id) {
    return todoList.firstWhere((element) => element.id == id);
  }

  void setLoading(bool val){
    isLoading = val;
    notifyListeners();
  }

  Future<void> deleteCompleted() async{
    List<String> toDelete = [];
    todoList.forEach((element) {
      if(element.isCompleted){
       toDelete.add(element.id);
      }
    });
    toDelete.forEach((element) async {
      print(element);
      await onDeleteTask(element);
    });
  }

}