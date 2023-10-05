import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tutorial_3/week.dart';

class Student
{
  String id;
  String familyName;
  String givenName;
  int studentID;
  Map <String,dynamic> grade;
  //num duration;
  //String image;
  //Map grade;

  Student({this.familyName, this.givenName, this.studentID});

// wk13 tutorial Getting the Student Data Class Database-Ready
  Student.fromJson(Map<String, dynamic> json)
      :
        familyName = json['family_name'],
        givenName = json['given_name'],
        grade = json['grade'],
        studentID = json['studentID'];

  Map<String, dynamic> toJson() =>
      {
        'given_name': givenName,
        'family_name': familyName,
        'studentID': studentID,
        'grade': grade
      };
  //END wk13 tutorial Getting the student Data Class Database-Ready
}

class StudentModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Student> items = [];
  final List<Week> weekitems = [];

//wk13 tutorial Converting the StudentModel Class to use a Database
  //added this
  CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  CollectionReference weeksCollection = FirebaseFirestore.instance.collection('weeks');
  //CollectionReference weeksCollection2 = FirebaseFirestore.instance.collection('weeks').doc(SELECTED_WEEK);
  //added this
  bool loading = false;


  //Normally a model would get from a database here, we are just hardcoding some data for this week
  StudentModel()
  {
    fetch();//upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg"));
  }

  // void add(Student item) {
  //   items.add(item);
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }

  void add(Student item) async
  {
    loading = true;
    notifyListeners();

    await studentsCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }



  void update(String id, Student item) async
  {
    
    loading = true;
    notifyListeners();

    await studentsCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  //void updateWeek(String id, Student item) async
  Future<void> updateMark(String id, Student item)
  {
    var result;
    return studentsCollection

      .doc(id)
      .set(item.toJson())
        .then((value) => result = true)
        .catchError((error) => result = false);
  }
  Future<void> updateWeek(Week item)
  {
    print(item);
    return weeksCollection
        .doc(SELECTED_WEEK)
        .set(item.toJson())
        .then((value) => print("week updated"))
        .catchError((error) => print("Failed to update week: $error"));
  }
  Future<void> addWeek(Week item)
  {
    print(item);
    return weeksCollection

        //.doc(SELECTED_WEEK)
        .add(item.toJson())
        .then((value) => print("week added"))
        .catchError((error) => print("Failed to add week: $error"));
  }
  void delete(String id) async
  {
    loading = true;
    notifyListeners();

    await studentsCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }
  //added this
  void fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all students
    var querySnapshot = await studentsCollection.orderBy("given_name").get();

    //iterate over the students and add them to the list
    querySnapshot.docs.forEach((doc) {
      //note not using the add(Student item) function, because we don't want to add them to the db
      var student = Student.fromJson(doc.data());
      student.id = doc.id;
      items.add(student);
    });

    weekitems.clear();
    var weekquerySnapshot = await weeksCollection.get();
    weekquerySnapshot.docs.forEach((doc) {
      var week = Week.fromJson(doc.data());
      //week.id = doc.id;
      weekitems.add(week);
    });

    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying
    await Future.delayed(Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    notifyListeners();
  }
  Student get(String id)
  {
    if (id == null) return null;
    return items.firstWhere((student) => student.id == id);
  }
}