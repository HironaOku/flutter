import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial_3/student_details.kt.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'student.dart';
import 'summary.dart';
import 'week.dart';

var MARK_TYPE = "";
var DISP_MODE = "grade";
var existingMark =  false;
var max_score = 0;
List<String> HDitems = ["","HD+", "HD", "DN", "CR","PP","NN"];
List<String> ABCitems = ["","A", "B", "C", "D","F"];
String _selectedItem = "";

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  runApp(MyApp());

  //if(student.)
}

class MyApp extends StatelessWidget
{
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void initState(){
    WeekModel();
   // var week = WeekModel.try;
  }
  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) //this function is called every time the "future" updates
      {
        // Check for errors
        if (snapshot.hasError) {
          return FullScreenText(text:"Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done)
        {
          //BEGIN: the old MyApp builder from last week
          return ChangeNotifierProvider(
              create: (context) => StudentModel(),
              child: MaterialApp(
                  title: 'Tutorial Marks App',
                  theme: ThemeData(
                    primarySwatch: Colors.teal,
                  ),
                  home: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: AppBar(
                        bottom: TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.supervisor_account_sharp)),
                            Tab(icon: Icon(Icons.bar_chart)),
                          ],
                        ),
                        title: Text("Tutorial Marks App"),
                      ),
                      body: TabBarView(
                        children: [
                          MarkingPage(title: 'Marks'),
                          WeeklyPage(title: 'Week summary')
                        ],
                      ),
                    ),
                  )


                  //home: MyHomePage(title: 'Tutorial Marks App')
              )
          );
          //END: the old MyApp builder from last week
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return FullScreenText(text:"Loading");
      },
    );
  }
}

class MarkingPage extends StatefulWidget
{
  MarkingPage({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _MyMarkingPageState createState() => _MyMarkingPageState();

}
//for marking scheme
class _MyMarkingPageState extends State<MarkingPage>
{
  final maxScoreController = TextEditingController();
  final studentScoreController = TextEditingController();

  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentModel>(
        builder:buildScaffold
    );
  }



  Scaffold buildScaffold(BuildContext context, StudentModel studentModel, _) {
    if(DISP_MODE == "edit" || DISP_MODE == "change" ){
      maxScoreController.text = max_score.toString();
    }
    return Scaffold(
      drawer: Drawer(
        child: ListView.builder(
          itemCount: WEEK_NAME.length,
          itemBuilder: (context, i){
            return ListTile(
              title: Text(WEEK_NAME[i]),
              leading: Icon(Icons.arrow_forward_ios),
              onTap: (){
                Navigator.pop(context);
                setState(() {
                  DISP_MODE = "grade";
                  SELECTED_WEEK = (WEEK_NAME[i]);
                  MARK_TYPE ="";
                  max_score = 0;
                  var week = studentModel.weekitems;
                  existingMark = false;
                  week.forEach((weekItem) {
                    //print(weekItem.weekName);
                    if(SELECTED_WEEK==weekItem.weekName){
                      existingMark = true;
                      MARK_TYPE = weekItem.markType;
                      max_score = weekItem.markMax;
                      print("there is a mark on selected week"+ MARK_TYPE +" "+ max_score.toString() +" "+  SELECTED_WEEK);
                    }
                  });
                });
                print(SELECTED_WEEK);
                //setState();
                //reload();
                //need reload
              },
            );
          },
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title,
          style: TextStyle(color: Colors.black26),

        ),
        actions: <Widget>[
          //mark edit buton
          if (SELECTED_WEEK != "" && DISP_MODE == "grade") IconButton(
            icon: Icon(
                Icons.edit,
              color: Colors.blue,
            ),
            onPressed: ()  {
              if(existingMark){
                selectMode(context);
              }else{
                DISP_MODE = "add";
                selectMarking(context);
              }
              //_count++;
            }),
          if (DISP_MODE != "grade") IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.blue,
              ),
              onPressed: ()  {
                setState(() {
                  DISP_MODE = "grade";
                });
              }),

        ],
      //),
        backgroundColor: Colors.white70,
      ),


      // way of getting to the add student screen

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (DISP_MODE == "grade")
            FloatingActionButton(
            child: Icon(Icons.person_add),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return StudentDetails();
              });
            },
          ),
        ],
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            if (SELECTED_WEEK != "" && MARK_TYPE == "score" )
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(SELECTED_WEEK.toUpperCase() + "\n" + MARK_TYPE + "   out of : " + max_score.toString()),
              )
            else if (SELECTED_WEEK != "" && MARK_TYPE != "score" )
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(SELECTED_WEEK.toUpperCase() + "\n" + MARK_TYPE),
              )
            else if (!studentModel.loading)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Please select the week"),
              ),

            if (DISP_MODE != "grade" && MARK_TYPE == "score" )
            new Container(
              width: 150.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 3,
                    child:
                    new TextField( //for score
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          labelText: "Enter the max",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      controller: maxScoreController,
                      onChanged: (text) {
                        int score = 0;

                        try {
                          score = int.parse(text.toString());
                        } catch (exception) {
                          score = 0;
                        }

                        setState(() {
                          max_score = score;
                        });

                          var week = studentModel.weekitems;
                          //existingMark = false;
                          var i = 0;
                          var id;
                          if(existingMark && (DISP_MODE == "edit" || DISP_MODE == "change")){
                            week.forEach((weekItem) {
                              //print(weekItem.weekName);
                              if(SELECTED_WEEK==weekItem.weekName){
                                week[i].weekName = SELECTED_WEEK;
                                week[i].markType = MARK_TYPE;
                                week[i].markMax = max_score;
                                id = i;
                              }
                              i++;
                            });
                          }
                         if(DISP_MODE == "edit" || DISP_MODE == "change") {
                           Provider.of<StudentModel>(
                               context, listen: false).updateWeek(week[id]);
                         } else if (DISP_MODE == "add"){
                           week[0].weekName = SELECTED_WEEK;
                           week[0].markType = MARK_TYPE;
                           week[0].markMax = max_score;

                           Provider.of<StudentModel>(
                               context, listen: false).updateWeek(week[0]);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (DISP_MODE != "grade" && MARK_TYPE == "checkbox")
              new Container(
                width: 150.0,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[

                    if(max_score >= 0)
                      IconButton(
                        icon: const Icon(Icons.indeterminate_check_box_rounded),
                        color: Colors.cyan,
                        onPressed: () {
                          setState(() {
                            max_score--;
                          });
                          changeMaxScore(max_score);
                        },
                      ),
                    if(max_score <= 4)
                    IconButton(
                      icon: const Icon(Icons.add_box_rounded),
                        color: Colors.cyan,
                      onPressed: () {
                        setState(() {
                          max_score++;
                        });
                        changeMaxScore(max_score);
                      },
                    ),
                  ],
                ),
              ),



//YOUR UI HERE
            if (studentModel.loading) CircularProgressIndicator() else Expanded(

              child: ListView.builder(
                  itemBuilder: (_, index) {
                    var student = studentModel.items[index];
                    var week = studentModel.weekitems;
                    //print(week);
                    var i = 0;
                    var studentGrade = "no score";
                    if(SELECTED_WEEK==""){
                      studentGrade = "";
                    }
                    if(existingMark==true){
                      studentGrade = "0";
                    }

                    //if ()
                    if (student.grade[SELECTED_WEEK] != null){
                      studentGrade = student.grade[SELECTED_WEEK]["mark"];
                      if(studentGrade == ""){
                        studentGrade ="0";
                      }
                    }



                    return Dismissible(

                        child: ListTile(

                          title: Row(
                            children: [
                              Text(student.givenName + " " + student.familyName),
                              //Text(student.givenName + " " + student.familyName),
                            ],
                          ),
                          subtitle: Text(student.studentID.toString()),
                          leading: Icon(Icons.person),

                          trailing:
                          (() {
                            if(DISP_MODE == "grade" && MARK_TYPE == "attendance"){
                              if (student.grade[SELECTED_WEEK] != null){
                                var chkResult = student.grade[SELECTED_WEEK]["checkbox"];
                                  studentGrade = createAttendanceResult(chkResult);
                              }
                              return Text(studentGrade);
                            }else if(DISP_MODE == "grade" && MARK_TYPE == "checkbox"){
                              if (student.grade[SELECTED_WEEK] != null){
                                var chkResult = student.grade[SELECTED_WEEK]["checkbox"];
                                if(chkResult == "" || chkResult == null){
                                  studentGrade ="0";
                                }else {
                                  studentGrade = createCheckBoxResult(chkResult);
                                }
                              }
                              return Text(studentGrade);
                            }else if(DISP_MODE == "grade"){
                              return Text(studentGrade);
                            } else if(max_score > 0 && MARK_TYPE == "score"){

                              if (student.grade[SELECTED_WEEK] != null){
                                  studentGrade = student.grade[SELECTED_WEEK]["mark"];
                              } else {
                                studentGrade = "0";
                              }

                              return  new Container(
                                width: 150.0,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    new Expanded(
                                      flex: 3,
                                      child: new TextField(// max score
                                        textAlign: TextAlign.end,
                                        decoration: InputDecoration(
                                          labelText: studentGrade,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),

                                        onChanged: (text) {
                                          int score;
                                          try {
                                            score = int.parse(text.toString());
                                          } catch (exception) {
                                            score = 0;
                                          }
                                          if (score > max_score || score < 0){
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text("ERROR: Score should be 0~" + max_score.toString()),
                                            ));

                                          } else {
                                            var gradeitem = {
                                              'mark': text, // Key:    Value
                                              'mark_type': MARK_TYPE,
                                            };
                                            studentModel.items[index].grade[SELECTED_WEEK] = gradeitem;

                                            Provider.of<StudentModel>(
                                                context, listen: false).updateMark(
                                                student.id, student);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (MARK_TYPE == "gradeHD" || MARK_TYPE == "gradeABC"){
                              var dropItem = HDitems;
                              var score="";
                              if (MARK_TYPE == "gradeABC"){
                                dropItem = ABCitems;
                              }

                              if (student.grade[SELECTED_WEEK] != null) {
                                if (student.grade[SELECTED_WEEK]["mark_type"] == "gradeHD" || student.grade[SELECTED_WEEK]["mark_type"] == "gradeABC") {
                                  score = studentModel.items[index]
                                      .grade[SELECTED_WEEK]["mark"];
                                }
                              }

                              return  new Container(
                               // width: 150.0,
                                child: new DropdownButton<String>(
                                  value: score,
                                  onChanged: (String mark) {
                                    var gradeitem = {
                                      'mark': mark, // Key:    Value
                                      'mark_type': MARK_TYPE,
                                    };
                                    studentModel.items[index].grade[SELECTED_WEEK] = gradeitem;

                                    Provider.of<StudentModel>(
                                        context, listen: false).updateMark(
                                        student.id, student);

                                      setState(() {
                                        _selectedItem = score;
                                      });
                                    },
                                  selectedItemBuilder: (context) {
                                    return dropItem.map((String item) {
                                      return Text(item);
                                    }).toList();
                                  },
                                  items: dropItem.map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );

                            } else if (MARK_TYPE == "checkbox" || MARK_TYPE == "attendance"){
                              List score=[false, false, false, false, false];

                              if (student.grade[SELECTED_WEEK] == null || studentModel.items[index]
                                  .grade[SELECTED_WEEK]["checkbox"] == null) {

                                var gradeitem = {
                                  'mark': "", // Key:    Value
                                  'mark_type': MARK_TYPE,
                                  "checkbox":score,
                                };
                                student.grade[SELECTED_WEEK] = gradeitem;
                                Provider.of<StudentModel>(
                                    context, listen: false).updateMark(
                                    student.id, student);
                              }
                              score = studentModel.items[index]
                              .grade[SELECTED_WEEK]["checkbox"];


                              for (int i = max_score; i < 5; i++){
                                score[i]=false;
                              }
                            print(score);
                            return new Container(
                               width: 200.0,

                                 child: new Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>
                                   [
                                    for (int i = 0; i < max_score; i++)
                                    //if(max_score >= 1)
                                    new Expanded(
                                      child: new Checkbox(
                                        activeColor: Colors.blue,
                                        value: score[i],

                                        onChanged: (bool flag) {
                                          setState(() {
                                            score[i] = !score[i];
                                          });

                                          studentModel.items[index].grade[SELECTED_WEEK]["checkbox"] = score;
                                          Provider.of<StudentModel>(
                                              context, listen: false).updateMark(
                                              student.id, student);

                                          print("checkbox: " + score[i].toString() );

                                        },
                                      ),
                                    ),
                                   ],
                              ),
                            );
                            }
                          })(),


                          onTap: () {
                            if(DISP_MODE == "grade") {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return StudentDetails(id: student.id);
                                  }));
                            }else if (MARK_TYPE=="checkbox" || MARK_TYPE=="attendance"){
                              {
                                setState(() {
                                  this.value = !value;
                                });
                                print(value);
                              }
                            }
                      },
                          //Text(student.givenName + " " + student.familyName),
                    ),

                      background: Container(
                        color: Colors.cyan,
                        child: Icon(Icons.edit_outlined),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: Icon(Icons.cancel),
                      ),
                      //key: ValueKey<int>(index),
                      key: UniqueKey(),
                    onDismissed: (DismissDirection direction){
                        setState((){
                          //swipe right to left
                          if (direction == DismissDirection.endToStart){
                            studentModel.delete(student.id);
                          } else{
                            //studentModel.delete(student.id);
                            //studentModel.update(student.id, student);
                            showDialog(context: context, builder: (context) {
                              return StudentDetails(id: student.id);
                            });
                          }
                        }
                        );
                      },
                    );

                    },
                  itemCount: studentModel.items.length
              ),

            )
          ],
        ),
      ),
    );

  }
  createAttendanceResult(chkResult) {
    var resultText="Absent";
    if (chkResult[0]){
      resultText = "Attended";
    } else {
      resultText = "Absent";
    }
    return resultText;
  }
  createCheckBoxResult(chkResult) {
    var resultText="";
    var count = 0;

    for (var i = 0; i < max_score; i++) {
      var num = i+1;
      if(chkResult[i]){
          resultText += num.toString() + ": OK   ";
          count++;
        }else{
          resultText += num.toString() + ": --   ";
      }
    }
    resultText += "     " + count.toString() + "/" + max_score.toString() ;
    return resultText;
  }

//dialog for select mark type
  void selectMarking(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: (DISP_MODE=="change") ? Text("Select Marking schema. \n\nNOTICE: If change the Marking schema, existing mark will be removed") : Text("Select Marking schema") ,
            children: <Widget>[

              if(DISP_MODE != "change" || MARK_TYPE != "score")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {

                    Navigator.pop(context);
                    setState(() {
                      MARK_TYPE = "score";
                      max_score = 0;
                      print(MARK_TYPE);
                    });
                      changeMarkingSchema(MARK_TYPE, max_score);

                    },
                  child: Text("Score"),
            ),
              ),
              if(DISP_MODE != "change" || MARK_TYPE != "attendance")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      MARK_TYPE = "attendance";
                      //DISP_MODE = "edit";
                      max_score = 1;
                      print(MARK_TYPE);
                    });
                    changeMarkingSchema(MARK_TYPE, max_score);
                    },
                  child: Text("Attendance"),
                ),
              ),
              if(DISP_MODE != "change" || MARK_TYPE != "gradeHD")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      MARK_TYPE = "gradeHD";
                      max_score = 100;
                      print(MARK_TYPE);
                    });
                    changeMarkingSchema(MARK_TYPE, max_score);
                    },

                  child: Text("Grade HD"),
                ),
              ),
              if(DISP_MODE != "change" || MARK_TYPE != "gradeABC")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      MARK_TYPE = "gradeABC";
                      //DISP_MODE = "edit";
                      max_score =100;
                      print(MARK_TYPE);
                    });
                    changeMarkingSchema(MARK_TYPE, max_score);
                    },
                  child: Text("Grade ABC"),
                ),
              ),
              if(DISP_MODE != "change" || MARK_TYPE != "checkbox")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      MARK_TYPE = "checkbox";
                      max_score = 1;
                      print(MARK_TYPE);
                    });
                    changeMarkingSchema(MARK_TYPE, max_score);
                    },
                  child: Text("Check Box"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      DISP_MODE = "grade";
                    });
                  },
                  child: Text("Cancel"),
                ),
              ),
          ],
        );
      },
    );
  }
//dialog for select mode
  void selectMode(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Select Function"),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    DISP_MODE = "edit";
                  });
                },
                child: Text("Edit mark"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    DISP_MODE = "change";
                    selectMarking(context);
                  });
                },
                child: Text("Change Marking Schema"),
              ),
            ),
          ],
        );
      },
    );
  }
  void changeMaxScore(int max_score) {
    var week = Provider.of<StudentModel>(context, listen:false).weekitems;
    var i = 0;
    var id;
    week.forEach((weekItem) {
      if(SELECTED_WEEK==weekItem.weekName){
        week[i].weekName = SELECTED_WEEK;
        week[i].markMax = max_score;
        id = i;
      }
      i++;
    });
    Provider.of<StudentModel>(
        context, listen: false).updateWeek(week[id]);
  }
  void changeMarkingSchema(String mark_type, int max_score) {
    var week = Provider.of<StudentModel>(context, listen:false).weekitems;
    var i = 0;
    var id;
    var flg = false;
    week.forEach((weekItem) {
      if(SELECTED_WEEK==weekItem.weekName){
        week[i].weekName = SELECTED_WEEK;
        week[i].markType = mark_type;
        week[i].markMax = max_score;
        id = i;
        flg = true;
      }
      i++;
    }
    );
    if(flg){
      Provider.of<StudentModel>(
          context, listen: false).updateWeek(week[id]);
    } else {
      week[0].weekName = SELECTED_WEEK;
      week[0].markType = mark_type;
      week[0].markMax = max_score;
      Provider.of<StudentModel>(
          context, listen: false).updateWeek(week[0]);
    }
      removeStudentScore(mark_type);
  }

  void removeStudentScore(String mark_type) {
    var student = Provider.of<StudentModel>(context, listen:false).items;
    var i = 0;
    student.forEach((weekItem) {
          var score = [false, false, false, false, false];
          var gradeitem = {
            'mark': "", // Key:    Value
            'mark_type': mark_type,
            "checkbox":score,
          };
          student[i].grade[SELECTED_WEEK] = gradeitem;
          Provider.of<StudentModel>(
              context, listen: false).updateMark(
              student[i].id, student[i]);
      i++;
    });

  }

}



//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {//inheritance
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}



