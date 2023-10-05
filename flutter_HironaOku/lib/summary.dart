import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'student.dart';
import 'week.dart';

class WeeklyPage extends StatefulWidget
{
  WeeklyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyWeeklyPageState createState() => _MyWeeklyPageState();

}
//for marking scheme
class _MyWeeklyPageState extends State<WeeklyPage>
{

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentModel>(
        builder:buildScaffold
    );

  }

  Scaffold buildScaffold(BuildContext context, StudentModel studentModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
          style: TextStyle(color: Colors.black26),
        ),
        backgroundColor: Colors.white70,
      ),
      body:
      ListView.builder(
        itemCount: WEEK_NAME.length,
        itemBuilder: (BuildContext context, int index) {
          var week = studentModel.weekitems;
          var student = studentModel.items;
          var markType = "No Mark";
          var max_mark = 100;
          var average = "";

          week.forEach((weekItem) {
            if (weekItem.weekName == WEEK_NAME[index]){
              markType = weekItem.markType;
              max_mark = weekItem.markMax;
            }
          });

          var i = 0;
          var score;
          double scoreNum =0;
          double scoreavg = 0;

          student.forEach((students) {
            if (student[i].grade[WEEK_NAME[index]] != null){
              score = student[i].grade[WEEK_NAME[index]]["mark"];

              if(markType == "gradeHD" || markType == "gradeABC"){
                scoreNum = gradeToNum(score, markType);
              } else if (markType =="score"){
                scoreNum = scoreToNum(score, max_mark) as double;
              } else if (markType == "attendance" || markType == "checkbox"){
                var chkresult = student[i].grade[WEEK_NAME[index]]["checkbox"];
                scoreNum = checkBoxToNum(chkresult, max_mark) as double;
              }
              print (markType);
              print (scoreNum);
              try {
                scoreavg += scoreNum;
              } catch (exception) {
                scoreavg = 0;
              }
            }
            i++;
          });
          print (WEEK_NAME[index]);
          var avg = scoreavg/student.length;
          const base_number = 10;
          avg =(avg * base_number).round() / base_number;
          average = avg.toString();
          if (markType == "No Mark"){
            average = "-";
          }
          return ListTile(

          //return _messageItem(WEEK_NAME[index]leading:
            title: Row(
              children:
              [
                Padding(
                  padding: const EdgeInsets.all(8.20),
                  child: Text(WEEK_NAME[index]),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(markType),
                ),
              ],
            ),
            leading:Icon(Icons.arrow_right_rounded),
            trailing: Text("Average : " + average),

          );
        },
        ),
    );
  }

  Widget _messageItem(String title) {
    return Container(
      decoration: new BoxDecoration(
          border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
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

  gradeToNum(score, String markType) {
    double scoreNum = 0;
    if(markType == "gradeHD"){
      switch(score) {
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
    if(markType == "gradeABC"){
      switch(score) {
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
    return scoreNum;
  }

  int scoreToNum(score, int max_mark) {
    double scoreNum = 0;

    try {
      var scoreA = int.parse(score.toString());
     scoreNum = scoreA/max_mark * 100;
      //const base_number = 1;
      //scoreNum =(scoreNum * base_number).round() / base_number;
    } catch (exception) {
      scoreNum = 0;
    }

    return scoreNum.toInt();
  }

  checkBoxToNum(chkresult, int max_mark) {
    var count = 0;
    double scoreNum = 0;
    for (var i = 0; i < max_mark; i++) {
      if(chkresult[i]){
        count++;
      }
    }
    scoreNum = (100/max_mark) * count;
    return scoreNum.toInt();
  }
}
