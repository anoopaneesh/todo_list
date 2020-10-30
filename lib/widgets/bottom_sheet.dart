import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/providers/todo_provider.dart';

import 'custom_container.dart';
class CustomBottomSheet extends StatefulWidget {
  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (nctx,todoData,_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Text(
              'Add a new task',
              style: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withAlpha(50),
              ),
              child: TextField(
                controller: todoData.textController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 18,),
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    todoData.setPriority(Priority.High);
                  },
                  child: CustomContainer(
                    child: Text(
                      'High',
                      style: TextStyle(color:Colors.white),
                    ),
                    color:todoData.currentPriority == Priority.High ? Colors.red :
                    Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    todoData.setPriority(Priority.Medium);
                  },
                  child: CustomContainer(
                    child: Text(
                      'Medium',
                      style: TextStyle(color: Colors.white),
                    ),
                    color:todoData.currentPriority == Priority.Medium ? Colors.orange :
                    Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    todoData.setPriority(Priority.Low);
                  },
                  child: CustomContainer(
                    child: Text(
                      'Low',
                      style: TextStyle(color: Colors.white),
                    ),
                    color:todoData.currentPriority == Priority.Low ? Colors.green :
                    Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              child: todoData.isLoading?Center(child: CircularProgressIndicator(),):RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Theme.of(context).primaryColor,
                onPressed: (){
                  if(todoData.textController.text != ""){
                    todoData.setLoading(true);
                    todoData.onSaveTask().catchError((error){
                      return showDialog(context: nctx,builder: (c) =>
                      AlertDialog(title: Text('An error occurred'),content:Text('Something went wrong'),
                      actions: [
                        FlatButton(onPressed:(){
                          todoData.setLoading(false);
                          Navigator.of(c).pop();
                        }, child: Text('Ok'))
                      ],)
                      );
                    }).then((res){
                      todoData.setLoading(false);
                      Navigator.of(nctx).pop();
                    });


                  }
                },
                child:Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(18),
                    width: double.infinity,
                    child: Text('Save',style: TextStyle(fontSize: 18,color: Colors.white),)),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
