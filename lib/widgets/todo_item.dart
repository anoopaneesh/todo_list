import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/providers/todo_provider.dart';
class TodoItem extends StatelessWidget {
  final String id;

  const TodoItem({Key key, this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Consumer<TodoProvider>(
      builder: (ctx,todoData,_){
        var task = todoData.findTaskById(id);
        return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
          SizedBox(width: 20,),
          GestureDetector(
            onTap: (){
              todoData.toggleCompleted(id);
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Theme.of(context).primaryColor,width: 2),
              color: task.isCompleted?Theme.of(context).primaryColor:Colors.white),
              child: Icon(Icons.done,color: Colors.white,size: 20,),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Text(task.text,style: Theme.of(context).textTheme.headline6.copyWith(
              decoration: task.isCompleted?TextDecoration.lineThrough:TextDecoration.none,
              fontSize: 18,
            ),),
          ),
          SizedBox(width: 10,),
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: todoData.getColor(task.priority),
            shape: BoxShape.circle,
            ),

          ),
          SizedBox(width: 20,),
          IconButton(icon: Icon(Icons.cancel,color: Colors.red,),onPressed: ()async {
                  try{
                    await todoData.onDeleteTask(id);
                  }catch(e){
                    scaffold.showSnackBar(SnackBar(content: Text('Error deleting product')),);
                  }
                }),
        ],),
      );
  }
    );
  }
}
