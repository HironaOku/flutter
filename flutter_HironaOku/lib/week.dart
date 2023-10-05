import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> WEEK_NAME = ["week1",
  "week2",
  "week3",
  "week4",
  "week5",
  "week6",
  "week7",
  "week8",
  "week9",
  "week10",
  "week11",
  "week12",
];

const List<String> MARK_TYPE = ["score",
  "gradeHD",
  "gradeABC",
  "attendance",
  "checkbox",
];

var SELECTED_WEEK = "";

class Week
{
  String weekName;
  String markType;
  int markMax;

  Week({this.weekName, this.markType, this.markMax});

// wk13 tutorial Getting the Week Data Class Database-Ready
  Week.fromJson(Map<String, dynamic> json)
      :
        markType = json['mark_type'],
        weekName = json['week_name'],
        markMax = json['max'];

  Map<String, dynamic> toJson() =>
      {
        'mark_type': markType,
        'week_name': weekName,
        'max': markMax,
      };
//END wk13 tutorial Getting the week Data Class Database-Ready
}

class WeekModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Week> items = [];

//wk13 tutorial Converting the WeekModel Class to use a Database
  //added this
  CollectionReference weeksCollection = FirebaseFirestore.instance.collection('weeks');

  //added this
  bool loading = false;


  //Normally a model would get from a database here, we are just hardcoding some data for this week
  WeekModel()
  {
    fetchWeeklyData();//upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg"));
  }


  // void add(Week item) {
  //   items.add(item);
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }

  void add(Week item) async
  {
    loading = true;
    notifyListeners();

    await weeksCollection.add(item.toJson());

    //refresh the db
    await fetchWeeklyData();
  }

  void update(String id, Week item) async
  {
    loading = true;
    notifyListeners();

    await weeksCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetchWeeklyData();
  }

  void delete(String id) async
  {
    loading = true;
    notifyListeners();

    await weeksCollection.doc(id).delete();

    //refresh the db
    await fetchWeeklyData();
  }
  //added this
  void fetchWeeklyData() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all weeks
    var querySnapshot = await weeksCollection.orderBy("week_name").get();

    //iterate over the weeks and add them to the list
    querySnapshot.docs.forEach((doc) {
      //note not using the add(Week item) function, because we don't want to add them to the db
      var week = Week.fromJson(doc.data());
      //week.id = doc.id;
      items.add(week);
    });

    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying
    await Future.delayed(Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    notifyListeners();
  }
  Week get(String weekname)
  {
    if (weekname == null) return null;
    return items.firstWhere((week) => week.weekName == weekname);
  }
}