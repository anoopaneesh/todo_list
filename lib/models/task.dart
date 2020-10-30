import 'package:flutter/foundation.dart';

enum Priority{
  High,
  Medium,
  Low

}
class Task{
  final String id;
  var isCompleted = false;
  final String text;
  final Priority priority;

  Task({@required this.id,this.text,this.isCompleted=false, this.priority});
}

