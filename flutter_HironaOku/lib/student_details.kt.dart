import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
//import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'student.dart';
import 'week.dart';


class StudentDetails extends StatefulWidget
{
  final String id;

  const StudentDetails({Key key, this.id}) : super(key: key);

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {

  final _formKey = GlobalKey<FormState>();
  final familyNameController = TextEditingController();
  final givenNameController = TextEditingController();
  final studentIDController = TextEditingController();
  final durationController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    var week = Provider.of<StudentModel>(context, listen:false).weekitems;
    var student = Provider.of<StudentModel>(context, listen:false).get(widget.id);
    var shareText = "";
    var adding = student == null;
    if (!adding) {
      shareText = student.givenName + " " + student.familyName + " Student ID: " + student.studentID.toString();
      familyNameController.text = student.familyName;
      givenNameController.text = student.givenName;
      studentIDController.text = student.studentID.toString();
      //durationController.text = student.duration.toString();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(adding ? "Add Student" : "Edit Student"),
        ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (!adding) IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Colors.blue,
              ),
              onPressed: ()  {
                print(shareText);
                Share.share(
                    shareText
                );

              }),
        ],
      ),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //if (adding == false) Text("Student Index ${widget.id}"), //check out this dart syntax, lets us do an if as part of an argument list
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(labelText: "Family Name"),
                              controller: familyNameController,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: "Given Name"),
                              controller: givenNameController,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: "Student ID"),
                              controller: studentIDController,
                            ),
                            // TextFormField(
                            //   decoration: InputDecoration(labelText: "Duration"),
                            //   controller: durationController,
                            // ),
                            ElevatedButton.icon(onPressed: () {
                              if (_formKey.currentState.validate())
                              {
                                if (adding)
                                {
                                  student = Student();
                                }

                                //update the student object
                                student.familyName = familyNameController.text;
                                student.givenName = givenNameController.text;
                                student.studentID = int.parse(studentIDController.text); //good code would validate these
                                //student.duration = double.parse(durationController.text); //good code would validate these

                                //TODO: update the model

                                if (adding) {
                                  var score = [false, false, false, false, false];
                                  student.grade = {
                                    'week' : '',
                                    'mark': "", // Key:    Value
                                    'mark_type': "",
                                    "checkbox":score,
                                  };
                                  Provider.of<StudentModel>(
                                      context, listen: false).add(student);
                                }else {
                                  Provider.of<StudentModel>(
                                      context, listen: false).update(
                                      widget.id, student);
                                }

                                //return to previous screen
                                Navigator.pop(context);
                              }
                            }, icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.save),
                            ), label: Text("Save"))

                          ],
                        ),
                      ),
                    ),
                    if (!adding)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (adding == false) Text("Grades"),
                          //if(adding){}
                          //Text("Grades"),
                          LimitedBox(
                            maxHeight: 350,
                            child: ListView.builder(
                              //shrinkWrap: true,
                              //scrollDirection: Axis.vertical,
                              itemCount: WEEK_NAME.length,
                              //physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                var score = "";
                                var markType = "No Mark";
                                var maxScore;
                                week.forEach((weekItem) {
                                  if (weekItem.weekName == WEEK_NAME[index]){
                                    markType = weekItem.markType;
                                    maxScore = weekItem.markMax;
                                  }
                                });

                                if(markType == "No Mark"){
                                  score = "-";
                                } else if (student.grade[WEEK_NAME[index]] != null){
                                  var mark_type = student.grade[WEEK_NAME[index]]["mark_type"];
                                  if (mark_type == "gradeHD" || mark_type == "gradeABC" ) {
                                    var result  = student.grade[WEEK_NAME[index]]["mark"];
                                    score = gradeToNum(result, mark_type);
                                  } else if (mark_type == "attendance" || mark_type == "checkbox"){
                                    var result = student.grade[WEEK_NAME[index]]["checkbox"];
                                    score = checkToScore(result, maxScore);
                                  } else if (mark_type == "score"){
                                    var result =student.grade[WEEK_NAME[index]]["mark"];
                                    score = scoreToScore(result, maxScore);
                                  }

                                  print (score);
                                } else {
                                  score = "0";
                                }

                                shareText += "\n" + WEEK_NAME[index];
                                shareText += "\n" + markType + " : " + score;

                                return ListTile(

                                  //return _messageItem(WEEK_NAME[index]leading:
                                  title: Row(
                                    children:
                                    [
                                      Text(WEEK_NAME[index] + "     "),
                                      Text(markType),
                                    ],
                                  ),
                                  leading:Icon(Icons.arrow_right_rounded),
                                  trailing: Text(score),

                                );
                              },
                              ),
                          ),
                        ],
                      ),
                    ),
                  ]
              ),

            ),


        ),


    );
  }
  Widget _messageItem(String title) {
    return Container(
      decoration: new BoxDecoration(
          border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        dense:true,
        title: Text(
          title,
          style: TextStyle(
            color:Colors.black38,
            //fontSize: 18.0
          ),
        ),
        // onTap: () {
        //   print("onTap called.");
        // }, // tap
        // onLongPress: () {
        //   print("onLongTap called.");
        // }, // long tap
      ),
    );
  }


  String checkToScore(result, maxScore) {
    String scoredisp;
    var count = 0;
    double scoreNum = 0;
    for (var i = 0; i < maxScore; i++) {
      if(result[i]){
        count++;
      }
    }
    scoreNum = (100/maxScore) * count;
    var scoreInt = scoreNum.toInt();

    scoredisp = count.toString() + "/" + maxScore.toString() + "     " + scoreInt.toString() + " %" ;
    return scoredisp;
  }

  String scoreToScore(result, maxScore) {
    var score;
    double scoreNum = 0;

    try {
      score = int.parse(result.toString());
    } catch (exception) {
      score = 0;
    }
    scoreNum = (score/maxScore) * 100;
    var scoreInt = scoreNum.toInt();
    var scoredisp = score.toString() + "/" + maxScore.toString() + "     " + scoreInt.toString() + " %" ;
    return scoredisp;
  }

  String gradeToNum(result, mark_type) {
    double scoreNum = 0;
    if(mark_type == "gradeHD"){
      switch(result) {
        case "HD+": {
          scoreNum = 100;
        }
        break;
        case "HD": {
          scoreNum = 80;
        }
        break;
        case "DN": {
          scoreNum = 70;
        }
        break;
        case "CR": {
          scoreNum = 60;
        }
        break;
        case "PP": {
          scoreNum = 50;
        }
        break;
        case "NN": {
          scoreNum = 0;
        }
        break;

        default: {
          scoreNum = 0;
        }
        break;
      }
    }
    if(mark_type == "gradeABC"){
      switch(result) {
        case "A": {
          scoreNum = 100;
        }
        break;
        case "B": {
          scoreNum = 80;
        }
        break;
        case "C": {
          scoreNum = 70;
        }
        break;
        case "D": {
          scoreNum = 60;
        }
        break;
        case "F": {
          scoreNum = 0;
        }
        break;

        default: {
          scoreNum = 0;
        }
        break;
      }
    }
    var scoreInt = scoreNum.toInt();
    var scoredisp = result + "     " + scoreInt.toString() + " %" ;
    return scoredisp;

}}



// Future share(String shareText) {
//   var data_dict = null;
//   if (shareText != null) {
//     data_dict = convertDartToNative_Dictionary(shareText);
//   }
//   return promiseToFuture(JS("", "#.share(#)", this, data_dict));
// }

