// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/todo_model.dart';

class TodoUiScreen extends StatefulWidget {
  const TodoUiScreen({super.key});
  @override
  State<TodoUiScreen> createState() => _TodoUiScreenState();
}

class _TodoUiScreenState extends State<TodoUiScreen> {
  //Controllers
  TextEditingController titleControler = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<TodoModel> todoCardsList = [];
  List<Color> colorList = [
    Color.fromARGB(255, 88, 168, 88), // Light Green
    Color.fromARGB(255, 90, 154, 199), // Light Blue
    Color.fromARGB(255, 196, 157, 93), // Light Orange
    Color.fromARGB(255, 158, 86, 169), // Light Purple
    Color.fromARGB(255, 160, 74, 87), // Light Pink
    Color.fromARGB(255, 90, 175, 170), // Light Teal
    Color.fromARGB(255, 168, 148, 82), // Light Yellow
    Color.fromARGB(255, 62, 72, 128), // Light Indigo
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  /////////--------
  void getData() async {
    List<Map> cardList = await TodoDatabase().getTodoItems();
    log("CARD LIST $cardList");

    todoCardsList.clear();
    for (var element in cardList) {
      todoCardsList.add(
        TodoModel(
          date: element['date'],
          description: element['description'],
          title: element['title'],
          id: element['id'],
        ),
      );
    }

    setState(() {});
  }

  void clearControler() {
    titleControler.clear();
    descriptionController.clear();
    dateController.clear();
  }

  void submit(bool doEidit, [TodoModel? obj]) {
    if (titleControler.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        dateController.text.isNotEmpty) {
      if (doEidit) {
        //Edit
        obj!.title = titleControler.text;
        obj.description = descriptionController.text;
        obj.date = dateController.text;

        Map<String, dynamic> mapobj = {
          'title': obj.title,
          'description': obj.description,
          'id': obj.id,
        };
        TodoDatabase().updateTodoItem(mapobj);
      } else {
        //ADD
        todoCardsList.add(
          TodoModel(
            date: dateController.text,
            description: descriptionController.text,
            title: titleControler.text,
          ),
        );
        Map<String, dynamic> dataMap = {
          'title': titleControler.text,
          'description': descriptionController.text,
          'date': dateController.text,
        };

        TodoDatabase().insertTodoItem(dataMap);
      }
      clearControler();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  showBottomsheet(bool doEdit, [TodoModel? obj]) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  doEdit ? "Edit Task" : "Add New Task",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 30),

                // Title Field
                _buildInputField(
                  controller: titleControler,
                  label: "Title",
                  hint: "Enter task title",
                  icon: Icons.title,
                ),
                SizedBox(height: 20),

                // Description Field
                _buildInputField(
                  controller: descriptionController,
                  label: "Description",
                  hint: "Enter task description",
                  icon: Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                // Date Field
                _buildDateField(),
                SizedBox(height: 30),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (doEdit == true) {
                        submit(true, obj);
                      } else {
                        submit(false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      doEdit ? "Update Task" : "Add Task",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          onTap: () async {
            DateTime? pickDate = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xFF667eea),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickDate != null) {
              String strDate = DateFormat.yMMMMd().format(pickDate);
              dateController.text = strDate;
            }
          },
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Select Date",
            prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 16),
        constraints: BoxConstraints(minWidth: 28, minHeight: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /////////////----
  @override
  Widget build(BuildContext context) {
    log("------IN BUILD----");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("TodoApp"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          left: MediaQuery.of(context).padding.left,
          right: MediaQuery.of(context).padding.right,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: todoCardsList.isEmpty
                    ? Center(
                        child: Text("Empty", style: TextStyle(fontSize: 20)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: todoCardsList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Task Icon
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  colorList[index %
                                                      colorList.length],
                                                  colorList[index %
                                                          colorList.length]
                                                      .withOpacity(0.7),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Icon(
                                              Icons.check_box,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  todoCardsList[index].title,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  todoCardsList[index]
                                                      .description,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[600],
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          // Date
                                          Flexible(
                                            flex: 3,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 15,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      todoCardsList[index].date,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[600],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Action Buttons
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildActionButton(
                                                icon: Icons.edit,
                                                color: Colors.blue,
                                                onTap: () {
                                                  titleControler.text =
                                                      todoCardsList[index]
                                                          .title;
                                                  descriptionController.text =
                                                      todoCardsList[index]
                                                          .description;
                                                  dateController.text =
                                                      todoCardsList[index].date;
                                                  showBottomsheet(
                                                    true,
                                                    todoCardsList[index],
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 2),

                                              _buildActionButton(
                                                icon: Icons.delete,
                                                color: Colors.red,
                                                onTap: () {
                                                  int id =
                                                      todoCardsList[index].id;
                                                  todoCardsList.removeAt(index);
                                                  TodoDatabase().deleteTodoItem(
                                                    id,
                                                  );
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            showBottomsheet(false);
          },
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
