import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/providers/auth_provider.dart';
import 'package:todo_list/providers/todo_provider.dart';
import 'package:todo_list/screens/auth_screen.dart';
import 'package:todo_list/screens/splash_screen.dart';
import 'package:todo_list/widgets/CustomButton.dart';
import 'package:todo_list/widgets/bottom_sheet.dart';
import 'package:todo_list/widgets/custom_container.dart';
import 'package:todo_list/widgets/todo_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider,TodoProvider>(
            update: (ctx,data,previous) => TodoProvider(data.token(),previous == null ?[] :previous.todoList,data.userId)),
        ],
      child: MaterialApp(
          title: 'Todo List',
          theme: ThemeData(
            fontFamily: 'OpenSans',
            textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            canvasColor: Colors.white,
            accentColor: Colors.orange,
            primarySwatch: Colors.purple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Home(),
        ),
    );
  }
}
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var authData = Provider.of<AuthProvider>(context);
    if(authData.isAuth){
      return MyHomePage();
    }
    return FutureBuilder(
      future: authData.autoLogin(),builder: (ctx,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return SplashScreen();
        }
        return AuthScreen();
    }

    );
  }
}


class MyHomePage extends StatelessWidget {

  void addTodoSheet(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (c) => CustomBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          addTodoSheet(context);
        },
        child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ToDo List',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  PopupMenuButton<int>(
                    onSelected: (val){
                      if(val == 1){
                        Provider.of<TodoProvider>(context,listen: false).deleteCompleted();
                      }else{
                        Provider.of<AuthProvider>(context,listen: false).logout();
                      }
                    },
                      itemBuilder:(ctx) => [PopupMenuItem(
                          child: Text('Clear Completed'),value: 1,),
                        PopupMenuItem(
                          child: Text('Logout'),value: 2,)]),
                ],
              ),
            ),
             Expanded(
                child: RefreshIndicator(
                  onRefresh: (){
                    return Provider.of<TodoProvider>(context,listen: false).fetchAllTask();
                  },
                  child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: FutureBuilder(
                          future: Provider.of<TodoProvider>(context,listen: false).fetchAllTask(),
                          builder:(ctx,snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator(),);
                            }
                            if(snapshot.error != null){
                              print(snapshot.error.toString());
                              return Center(child:Text('Error'));
                            }else{
                              return Consumer<TodoProvider>(
                              builder: (c,todoData,_) =>todoData.todoList.isEmpty?
                              Container(
                                  child: Image.asset('assets/images/todo-image.png'))
                                  : ListView.builder(
                                  itemBuilder: (ctx,index) => TodoItem(id: todoData.todoList[index].id,),
                                  itemCount: todoData.todoList.length,
                                ),
                              );
                            }
                          }
                        ),
                      ),
                )

            ),


          ]),
        ),
      ),
    );
  }
}
