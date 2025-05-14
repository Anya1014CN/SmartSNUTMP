import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/AppPage/courseTable/coursetable_page.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


//最新版本下载链接
bool updateChecked = false;
String latestDownloadLink = '';

//学期信息
String termStart = '';
String termEnd = '';
int termWeeks = 0;
bool termEnded = false;

//全年课表数据
List courseTableFull = [];//一学期的完整课表
List<List> courseMonTotal = [[],[],[],[],[],[],[],[],[],[]];//周一课程（第一节到第十节）
List<List> courseTueTotal = [[],[],[],[],[],[],[],[],[],[]];//周二课程
List<List> courseWedTotal = [[],[],[],[],[],[],[],[],[],[]];//周三课程
List<List> courseThuTotal = [[],[],[],[],[],[],[],[],[],[]];//周四课程
List<List> courseFriTotal = [[],[],[],[],[],[],[],[],[],[]];//周五课程
List<List> courseSatTotal = [[],[],[],[],[],[],[],[],[],[]];//周六课程
List<List> courseSunTotal = [[],[],[],[],[],[],[],[],[],[]];//周日课程

//单周课表数据
List<List> courseMonWeek = [[],[],[],[],[],[],[],[],[],[]];//周一课程（第一节到第十节）
List<List> courseTueWeek = [[],[],[],[],[],[],[],[],[],[]];//周二课程
List<List> courseWedWeek = [[],[],[],[],[],[],[],[],[],[]];//周三课程
List<List> courseThuWeek = [[],[],[],[],[],[],[],[],[],[]];//周四课程
List<List> courseFriWeek = [[],[],[],[],[],[],[],[],[],[]];//周五课程
List<List> courseSatWeek = [[],[],[],[],[],[],[],[],[],[]];//周六课程
List<List> courseSunWeek = [[],[],[],[],[],[],[],[],[],[]];//周日课程
List<List> courseNextMonWeek = [[],[],[],[],[],[],[],[],[],[]];//下周一课程

//今日课表数据
List<List> courseToday = [[],[],[],[],[],[],[],[],[],[]];//今日课程（第一节到第十节）
bool courseIsToday = true;//判断是否读取今天的课程

//课表读取状态
bool isReadingCT = true;

//学期数据
Map semestersData = {};
int semesterTotal = 0;//学年的数量
List semestersName = [];

//当前课表学年
int currentYearInt = 0;
String currentYearName = '';

//当前课表学期
int currentTermInt = 1;
String currentTermName = '';

//当前课表信息
int currentWeekInt = 1;
late DateTime termStartDateTime;
late DateTime termEndDateTime;

//解析新闻相关变量
int newsState = 0;//用于防止反复获取新闻，0 - 未获取； 1 - 已获取
bool isLoading = true;
bool loadSuccess = false;//用于判断是否成功获取新闻
int newsType = 0;//用于判断获取 理工要闻 或 通知公告 0 - 理工要闻； 1 - 通知公告
List<Map<String, String>> newsOutput = [];
List<dynamic> jsonData = [];
String jsonOutput='';

//用于存储新闻的完整URL
Uri url = Uri.parse("uri");

//用于存储最新六条 理工要闻
Map<String,dynamic> lgyw1 ={};
Map<String,dynamic> lgyw2 ={};
Map<String,dynamic> lgyw3 ={};
Map<String,dynamic> lgyw4 ={};
Map<String,dynamic> lgyw5 ={};
Map<String,dynamic> lgyw6 ={};

//用于存储最新六条 通知公告
Map<String,dynamic> tzgg1 ={};
Map<String,dynamic> tzgg2 ={};
Map<String,dynamic> tzgg3 ={};
Map<String,dynamic> tzgg4 ={};
Map<String,dynamic> tzgg5 ={};
Map<String,dynamic> tzgg6 ={};

//用于存储智慧陕理的公告
int announcementState = 0;//用于防止反复获取公告，0 - 未获取； 1 - 已获取
List smartSNUTAnnouncements = [];

//首页为 陕西理工大学 - 理工要闻
class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>{
  TextEditingController textUrlController = TextEditingController();
  
  //读取学期相关信息
  readSemesterInfo() async {
    if(GlobalVars.globalPrefs.containsKey('semestersData')){
      String semestersDataValue = GlobalVars.globalPrefs.getString('semestersData')!;
      semestersData = jsonDecode(semestersDataValue);
      semesterTotal = semestersData.length;
    }
    for(int i = 0; i < semesterTotal; i++){
      semestersName.add({
        'name': semestersData['y$i'][0]['schoolYear']
      });
    }
    //判断是否需要切换明日课程
    if(GlobalVars.switchTomorrowCourseAfter20 == true && GlobalVars.hour >= 20 && GlobalVars.hour <= 23){
      if(mounted){
        setState(() {
          courseIsToday = false;
        });
      }
    }
    readSelectState();
  }

  //读取课表的选中状态
  readSelectState() async {
    if(GlobalVars.globalPrefs.containsKey('courseTableStd-selectedTY')){
      String selectedTYValue = GlobalVars.globalPrefs.getString('courseTableStd-selectedTY')!;
      List selectedTYList = jsonDecode(selectedTYValue);
      currentYearInt = selectedTYList[0]['selectedYear'];
      currentYearName = semestersName[currentYearInt]['name'];
      currentTermInt = selectedTYList[1]['selectedTerm'];
      if(currentTermInt == 1){
        currentTermName = '第一学期';
      }if(currentTermInt == 2){
        currentTermName = '第二学期';
      }
    }else{
      if(mounted){
        setState(() {
          currentYearInt = 0;
          currentYearName = semestersName[0]['name'];
        });
      }
      saveSelectedTY();
    }
    readSchoolCalendarInfo();
  }

  //读取校历相关信息
  readSchoolCalendarInfo() async {
    String semesterId = '';
    //使用本地选中的 semetserid 来读取对应的课表
    semesterId = semestersData['y$currentYearInt'][currentTermInt -1 ]['id'].toString();
    if(GlobalVars.globalPrefs.containsKey('schoolCalendar-$semesterId')){
      var termTimejson = jsonDecode(GlobalVars.globalPrefs.getString('schoolCalendar-$semesterId')!);
      termStart = termTimejson[0]['termStart'];
      termEnd = termTimejson[0]['termEnd'];

      final dateFormat = DateFormat(r"yyyy'-'MM'-'dd");
      termStartDateTime = dateFormat.parse(termStart);
      termEndDateTime = dateFormat.parse(termEnd);
      termWeeks = termTimejson[0]['termWeeks'];
      int currentDay = DateTime.now().difference(termStartDateTime).inDays + 1;
      if(currentDay % 7 != 0){
        if(mounted){
          if((currentDay ~/ 7) + 1 > termWeeks){
            if(mounted){
              setState(() {
                termEnded = true;
                GlobalVars.currentDOW = currentDay % 7;
              });
            }
          }else{
            if(mounted){
              setState(() {
                termEnded = false;
                currentWeekInt = (currentDay ~/ 7) + 1;
                GlobalVars.currentDOW = currentDay % 7;
              });
            }
          }
        }
        saveSelectedTY();
      }if(currentDay % 7 == 0){
        if(mounted){
          if(currentDay ~/ 7 > termWeeks){
            if(mounted){
              setState(() {
                termEnded = true;
                GlobalVars.currentDOW =  7;
              });
            }
          }else{
            if(mounted){
              setState(() {
                termEnded = false;
                currentWeekInt = currentDay ~/ 7;
                GlobalVars.currentDOW =  7;
              });
            }
          }
        }
        saveSelectedTY();
      }
    }
    if(!courseIsToday) GlobalVars.currentDOW = GlobalVars.currentDOW + 1;
    readCourseTabDetail();
  }

  ///保存选中的课表学期状态
  saveSelectedTY() async {
    List selectedTY = [];
    selectedTY.remove('selectedYear');
    selectedTY.remove('selectedTerm');
    selectedTY.remove('selectedWeek');
    selectedTY.add({
      'selectedYear': currentYearInt,
    });
    selectedTY.add({
      'selectedTerm': currentTermInt,
    });
    await GlobalVars.globalPrefs.setString('courseTableStd-selectedTY', jsonEncode(selectedTY));
  }

  //读取学期课表信息
  readCourseTabDetail() async {
    String semesterId = '';
    //使用本地选中的 semetserid 来读取对应的课表
    semesterId = semestersData['y$currentYearInt'][currentTermInt -1 ]['id'].toString();
    if(GlobalVars.globalPrefs.containsKey('courseTableStd-courseTable-$semesterId')){
      String courseTableValue = GlobalVars.globalPrefs.getString('courseTableStd-courseTable-$semesterId')!;
      courseTableFull = jsonDecode(courseTableValue);
      if(mounted){
        setState(() {
          noCourseTable = false;
        });
      }
    }else{
      if(mounted){
        setState(() {
          noCourseTable = true;
        });
      }
    }
    //请求刷新课表之前先初始化课表
    courseMonTotal = [[],[],[],[],[],[],[],[],[],[]];//周一课程（第一节到第十节）
    courseTueTotal = [[],[],[],[],[],[],[],[],[],[]];//周二课程
    courseWedTotal = [[],[],[],[],[],[],[],[],[],[]];//周三课程
    courseThuTotal = [[],[],[],[],[],[],[],[],[],[]];//周四课程
    courseFriTotal = [[],[],[],[],[],[],[],[],[],[]];//周五课程
    courseSatTotal = [[],[],[],[],[],[],[],[],[],[]];//周六课程
    courseSunTotal = [[],[],[],[],[],[],[],[],[],[]];//周日课程
    for(int courseint = 0; courseint < courseTableFull.length; courseint++){

      //处理课程的周数数据
        List<int> onePositions = [];

        // 记录所有 '1' 的索引
        for (int index = 0; index < courseTableFull[courseint]['CourseWeeks'].length; index++) {
          if (courseTableFull[courseint]['CourseWeeks'][index] == '1') {
            onePositions.add(index);
          }
        }

        // 处理相邻 '1' 的索引
        List<String> formattedResult = [];
        int rangeStart = onePositions[0];
        int rangeEnd = rangeStart;

        for (int position = 1; position < onePositions.length; position++) {
          if (onePositions[position] == onePositions[position - 1] + 1) {
            rangeEnd = onePositions[position];
          } else {
            formattedResult.add(rangeStart == rangeEnd ? "$rangeStart" : "$rangeStart-$rangeEnd");
            rangeStart = onePositions[position];
            rangeEnd = rangeStart;
          }
        }
        //最终的处理结果
        formattedResult.add(rangeStart == rangeEnd ? "$rangeStart" : "$rangeStart-$rangeEnd");

      //先判断课程在每一天的第几节
      for(int timesint = 1; timesint <= courseTableFull[courseint]['CourseTimes'].length; timesint++){
        //如果是每一天的第一节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 0){
          //如果是周一的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第一节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[0].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第二节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 1){
          //如果是周一的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第二节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[1].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第三节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 2){
          //如果是周一的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第三节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[2].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第四节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 3){
          //如果是周一的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第四节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[3].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第五节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 4){
          //如果是周一的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第五节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[4].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第六节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 5){
          //如果是周一的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第六节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[5].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第七节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 6){
          //如果是周一的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第七节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[6].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第八节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 7){
          //如果是周一的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第八节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[7].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第九节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 8){
          //如果是周一的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第九节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[8].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
        //如果是每一天的第十节课
        if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['TimeOfDay'] == 9){
          //如果是周一的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 0){
            courseMonTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周二的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 1){
            courseTueTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周三的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 2){
            courseWedTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周四的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 3){
            courseThuTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周五的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 4){
            courseFriTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周六的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 5){
            courseSatTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
          //如果是周日的第十节课
          if(courseTableFull[courseint]['CourseTimes'][timesint - 1]['DayOfWeek'] == 6){
            courseSunTotal[9].add({
              'CourseName': courseTableFull[courseint]['CourseName'],
              'CourseLocation': courseTableFull[courseint]['CourseLocation'],
              'CourseTeacher': courseTableFull[courseint]['CourseTeacher'],
              'CourseWeeks': courseTableFull[courseint]['CourseWeeks'],
              'FormattedWeeks': formattedResult.join(" 周, "),
            });
          }
        }
      }
    }
    readWeeklyCourseTableDetail();
  }

  //读取单周课表信息
  readWeeklyCourseTableDetail() async {
    String semesterId = '';
    //使用本地选中的 semetserid 来读取对应的课表
    semesterId = semestersData['y$currentYearInt'][currentTermInt -1 ]['id'].toString();
    if(GlobalVars.globalPrefs.containsKey('courseTableStd-courseTable-$semesterId')){
      String courseTableFullValue = GlobalVars.globalPrefs.getString('courseTableStd-courseTable-$semesterId')!;
      courseTableFull = jsonDecode(courseTableFullValue);
      if(mounted){setState(() {});}
    }
    //请求刷新课表之前先初始化课表
    courseMonWeek = [[],[],[],[],[],[],[],[],[],[]];//周一课程（第一节到第十节）
    courseTueWeek = [[],[],[],[],[],[],[],[],[],[]];//周二课程
    courseWedWeek = [[],[],[],[],[],[],[],[],[],[]];//周三课程
    courseThuWeek = [[],[],[],[],[],[],[],[],[],[]];//周四课程
    courseFriWeek = [[],[],[],[],[],[],[],[],[],[]];//周五课程
    courseSatWeek = [[],[],[],[],[],[],[],[],[],[]];//周六课程
    courseSunWeek = [[],[],[],[],[],[],[],[],[],[]];//周日课程

    //加载本周周一课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseMonTotal[courseTODInt].length;courseInt++){
        if(courseMonTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseMonWeek[courseTODInt].add({
              'CourseName': courseMonTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseMonTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseMonTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseMonTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周二课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseTueTotal[courseTODInt].length;courseInt++){
        if(courseTueTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseTueWeek[courseTODInt].add({
              'CourseName': courseTueTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseTueTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseTueTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseTueTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周三课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseWedTotal[courseTODInt].length;courseInt++){
        if(courseWedTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseWedWeek[courseTODInt].add({
              'CourseName': courseWedTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseWedTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseWedTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseWedTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周四课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseThuTotal[courseTODInt].length;courseInt++){
        if(courseThuTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseThuWeek[courseTODInt].add({
              'CourseName': courseThuTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseThuTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseThuTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseThuTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周五课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseFriTotal[courseTODInt].length;courseInt++){
        if(courseFriTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseFriWeek[courseTODInt].add({
              'CourseName': courseFriTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseFriTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseFriTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseFriTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周六课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseSatTotal[courseTODInt].length;courseInt++){
        if(courseSatTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseSatWeek[courseTODInt].add({
              'CourseName': courseSatTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseSatTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseSatTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseSatTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }

    //加载本周周日课程
    for(int courseTODInt = 0; courseTODInt <= 9;courseTODInt++){
      for(int courseInt = 0;courseInt < courseSunTotal[courseTODInt].length;courseInt++){
        if(courseSunTotal[courseTODInt][courseInt]['CourseWeeks'][currentWeekInt] == '1'){
          courseSunWeek[courseTODInt].add({
              'CourseName': courseSunTotal[courseTODInt][courseInt]['CourseName'],
              'CourseLocation': courseSunTotal[courseTODInt][courseInt]['CourseLocation'],
              'CourseTeacher': courseSunTotal[courseTODInt][courseInt]['CourseTeacher'],
              'FormattedWeeks': courseSunTotal[courseTODInt][courseInt]['FormattedWeeks']
          });
        }
      }
    }
    readDailyCourseTable();
  }

  //读取每日课表信息
  readDailyCourseTable() async {
    //读取之前清空课表，防止与前一天的课表叠加
    courseToday = [[],[],[],[],[],[],[],[],[],[]];
    
    if(GlobalVars.currentDOW == 1){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseMonWeek[courseTODInt].isEmpty == false){
          courseToday[courseTODInt].add({
            'CourseName': courseMonWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseMonWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseMonWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 2){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseTueWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseTueWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseTueWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseTueWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 3){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseWedWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseWedWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseWedWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseWedWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 4){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseThuWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseThuWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseThuWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseThuWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 5){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseFriWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseFriWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseFriWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseFriWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 6){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseSatWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseSatWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseSatWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseSatWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 7){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseSunWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseSunWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseSunWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseSunWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(GlobalVars.currentDOW == 8){
      for(int courseTODInt = 0;courseTODInt < 10;courseTODInt++){
        if(courseNextMonWeek[courseTODInt].isEmpty != true){
          courseToday[courseTODInt].add({
            'CourseName': courseNextMonWeek[courseTODInt][0]['CourseName'],
            'CourseLocation': courseNextMonWeek[courseTODInt][0]['CourseLocation'],
            'CourseTeacher': courseNextMonWeek[courseTODInt][0]['CourseTeacher'],
          });
        }
      }
    }
    if(mounted){
      setState(() {
        isReadingCT = false;
      });//全部解析完成之后刷新
    }
  }

  //控件被创建的时候，执行 initState
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      readSemesterInfo();
      if(GlobalVars.showTzgg && newsState == 0){
        getNewsList();
      }
      if(announcementState == 0){
        getSmartSNUTAnnouncement();
      }
       //判断是否需要刷新课表
       if(GlobalVars.autoRefreshCourseTable == true && DateTime.now().millisecondsSinceEpoch - GlobalVars.lastCourseTableRefreshTime >= 86400000){
         getCourseTable();
       }
      await Modules.refreshState();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context)  {
    //加载首页之前立即刷新一次日期，解决进入首页后，日期信息延迟出现的问题
    DateTime now = DateTime.now();
          
    // 月和日强制转换为两位数字
    int month = DateTime.now().month;
    GlobalVars.monthString = month.toString().padLeft(2, '0');
    int day = DateTime.now().day;
    GlobalVars.dayString = day.toString().padLeft(2, '0');
          
    GlobalVars.hour = DateTime.now().hour;
          
    // 初始化中文日期格式
    initializeDateFormatting("zh_CN");
    GlobalVars.weekDay = DateFormat('EEEE', "zh_CN").format(now);
          
    // 获取明天的日期和星期
    DateTime tomorrow = now.add(Duration(days: 1));
    int tomorrowMonth = tomorrow.month;
    GlobalVars.tomorrowMonthString = tomorrowMonth.toString().padLeft(2, '0');
    int tomorrowDay = tomorrow.day;
    GlobalVars.tomorrowDayString = tomorrowDay.toString().padLeft(2, '0');
    GlobalVars.tomorrowWeekDay = DateFormat('EEEE', "zh_CN").format(tomorrow);
    
    //渲染首页
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              FilledButton.tonal(
                onPressed: () => getCourseTable(),
                child: Text('manual'),
              ),
              // 问候语区域
              Container(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Text(
                  '${GlobalVars.greeting}，${GlobalVars.realName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: GlobalVars.genericGreetingTitle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              SizedBox(height: 10),
              
              // 公告区域
              (smartSNUTAnnouncements.isEmpty)? 
              SizedBox():
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text('${smartSNUTAnnouncements[0]['Content']}',
                            style: TextStyle(
                              fontSize: GlobalVars.listTileTitle,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            url = Uri.parse(smartSNUTAnnouncements[0]['Link']);
                            launchURL();
                          },
                        ),
                        (smartSNUTAnnouncements.length >= 2)? ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text('${smartSNUTAnnouncements[1]['Content']}',
                            style: TextStyle(
                              fontSize: GlobalVars.listTileTitle,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            url = Uri.parse(smartSNUTAnnouncements[1]['Link']);
                            launchURL();
                          },
                        ):SizedBox(),
                        (smartSNUTAnnouncements.length >= 3)? ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text('${smartSNUTAnnouncements[2]['Content']}',
                            style: TextStyle(
                              fontSize: GlobalVars.listTileTitle,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            url = Uri.parse(smartSNUTAnnouncements[2]['Link']);
                            launchURL();
                          },
                        ):SizedBox(),
                      ],
                    )
                  )
                ),
              ),
              
              // 今日课表标题
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 4,
                      height: 18,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text(
                      (courseIsToday)? '今日课表':'明日课表',
                      style: TextStyle(
                        fontSize: GlobalVars.dividerTitle,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ),
              
              // 今日课表卡片
              Container(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: isReadingCT? 
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("正在加载课表...", 
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: GlobalVars.listTileSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  :Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 当前日期显示
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (courseIsToday)? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '今 | ${GlobalVars.monthString} 月 ${GlobalVars.dayString} 日 | ${GlobalVars.weekDay}',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: (!courseIsToday)? null:(){
                                  if(mounted){
                                    setState(() {
                                      courseIsToday = false;
                                      readSchoolCalendarInfo();
                                    });
                                  }
                                },
                                icon: Icon(Icons.arrow_forward,
                                  color: (currentWeekInt == 1)? Theme.of(context).colorScheme.onSurface.withAlpha(97) : Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: '明日课表',
                              ),
                            ],
                          ):Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '明 | ${GlobalVars.tomorrowMonthString} 月 ${GlobalVars.tomorrowDayString} 日 | ${GlobalVars.tomorrowWeekDay}',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: (courseIsToday)? null:(){
                                  if(mounted){
                                    setState(() {
                                      courseIsToday = true;
                                      readSchoolCalendarInfo();
                                    });
                                  }
                                },
                                icon: Icon(Icons.arrow_back,
                                  color: (currentWeekInt == 1)? Theme.of(context).colorScheme.onSurface.withAlpha(97) : Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: '今日课表',
                              ),
                            ],
                          )
                        ),
                        Divider(height: 24, indent: 20, endIndent: 20),
                        // 课表内容
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //第一节
                            (courseToday[0].isEmpty)?
                            SizedBox()
                            :buildCourseTile(context, courseToday, 0),
                            //第二节
                            (courseToday[1].isEmpty)? (courseToday[0].isEmpty == courseToday[1].isEmpty)? SizedBox(width: 0,height: 0,) :
                            SizedBox()
                            :(((courseToday[0].isEmpty)? false:(courseToday[0][0]['CourseName'] == courseToday[1][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[1][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 1),
                            //第三节
                            (courseToday[2].isEmpty)? 
                            SizedBox()
                            :(((courseToday[0].isEmpty)? false:(courseToday[0][0]['CourseName'] == courseToday[2][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[2][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 2),
                            //第四节
                            (courseToday[3].isEmpty)? (courseToday[2].isEmpty == courseToday[3].isEmpty)? SizedBox(width: 0,height: 0,) :
                            SizedBox()
                            :(((courseToday[0].isEmpty)? false:(courseToday[0][0]['CourseName'] == courseToday[3][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[3][0]['CourseLocation'])) || ((courseToday[2].isEmpty)? false:(courseToday[2][0]['CourseName'] == courseToday[3][0]['CourseName'] && courseToday[2][0]['CourseLocation'] == courseToday[3][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 3),
                            //第五节
                            (courseToday[4].isEmpty)? 
                            SizedBox()
                            :buildCourseTile(context, courseToday, 4),
                            //第六节
                            (courseToday[5].isEmpty)?  (courseToday[4].isEmpty == courseToday[5].isEmpty)? SizedBox(width: 0,height: 0,):
                            SizedBox()
                            :(((courseToday[4].isEmpty)? false:(courseToday[4][0]['CourseName'] == courseToday[5][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[5][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 5),
                            //第七节
                            (courseToday[6].isEmpty)? 
                            SizedBox()
                            :(((courseToday[4].isEmpty)? false:(courseToday[4][0]['CourseName'] == courseToday[6][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[6][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 6),
                            //第八节
                            (courseToday[7].isEmpty)? (courseToday[6].isEmpty == courseToday[7].isEmpty)? SizedBox(width: 0,height: 0,):
                            SizedBox()
                            :(((courseToday[4].isEmpty)? false:(courseToday[4][0]['CourseName'] == courseToday[7][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[7][0]['CourseLocation'])) || ((courseToday[6].isEmpty)? false:(courseToday[6][0]['CourseName'] == courseToday[7][0]['CourseName'] || courseToday[6][0]['CourseLocation'] == courseToday[7][0]['CourseLocation'])))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 7),
                            //第九节
                            (courseToday[8].isEmpty)? 
                            SizedBox()
                            :buildCourseTile(context, courseToday, 8),
                            //第十节
                            (courseToday[9].isEmpty)? (courseToday[8].isEmpty == courseToday[9].isEmpty)? SizedBox(width: 0,height: 0,):
                            SizedBox()
                            :((courseToday[8].isEmpty)? false:(courseToday[8][0]['CourseName'] == courseToday[9][0]['CourseName'] || courseToday[8][0]['CourseLocation'] == courseToday[9][0]['CourseLocation']))? SizedBox(width: 0,height: 0,)
                            :buildCourseTile(context, courseToday, 9),
                            // 今日无课提示
                            ((courseToday[0].isEmpty == true) && (courseToday[1].isEmpty == true) && (courseToday[2].isEmpty == true) && (courseToday[3].isEmpty == true) && (courseToday[4].isEmpty == true) && (courseToday[5].isEmpty == true) && (courseToday[6].isEmpty == true) && (courseToday[7].isEmpty == true) && (courseToday[8].isEmpty == true) && (courseToday[9].isEmpty == true))?
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.primary.withAlpha(179),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    (courseIsToday)?'今日无课，尽情享受休闲时光':'明日无课，今天上完课可以休息啦',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: GlobalVars.genericTextLarge,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ):SizedBox()
                          ],
                        ),
                        Divider(height: 24, indent: 20, endIndent: 20),
                        // 查看本周课表按钮
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, '/AppPage/CourseTablePage').then((value) => readSemesterInfo());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '查看本周课表、切换学年、刷新数据',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: GlobalVars.listTileTitle,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 便捷生活卡片
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildFunctionButton(
                                context, 
                                '网费查询', 
                                'web',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/SchoolNetworkPage');
                                }
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context, 
                                '电费查询', 
                                'electricity',
                                () {
                                  if(GlobalVars.emBinded == false){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(Icons.info),
                                            SizedBox(width: 8),
                                            Text('提示：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle),)
                                          ],
                                        ),
                                        content: Text('您还没有绑定电费账号，\n请先前往 "我的 -> 解/绑电费账号" 绑定后再试',style: TextStyle(fontSize: GlobalVars.alertdialogContent),),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('确定'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }else{
                                    Navigator.pushNamed(context, '/AppPage/Electricmeterpage');
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFunctionButton(
                                context, 
                                '我的考试', 
                                'exam',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/StdExamPage');
                                }
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context, 
                                '我的成绩', 
                                'grade',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/StdGradesPage');
                                }
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 通知公告标题
              (GlobalVars.showTzgg)? Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 4,
                      height: 18,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text(
                      '通知公告',
                      style: TextStyle(
                        fontSize: GlobalVars.dividerTitle,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ):SizedBox(),
              
              // 通知公告卡片
              (GlobalVars.showTzgg)? Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: isLoading? 
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("正在加载通知公告...", 
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: GlobalVars.listTileSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ):
                    loadSuccess? Column(
                      children: [
                        buildNewsItem(context, tzgg1),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        buildNewsItem(context, tzgg2),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        buildNewsItem(context, tzgg3),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        buildNewsItem(context, tzgg4),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        buildNewsItem(context, tzgg5),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        buildNewsItem(context, tzgg6),
                      ],
                    ):
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          SizedBox(width: 8),
                          Text(
                            '无法连接网络，点击刷新',
                            style: TextStyle(
                              fontSize: GlobalVars.listTileTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: (){
                        getNewsList();
                      },
                    )
                  ),
                ),
              ):SizedBox(),
              
              // 底部间隔
              SizedBox(height: 20),
            ]),
          )
        ],
      ),
    );
  }
  
  // 课程卡片构建辅助方法
  Widget buildCourseTile(BuildContext context, List<List> courseToday, int index) {
    String title = '';
    
    if (index == 0) {
      if (courseToday[3].isNotEmpty && courseToday[0][0]['CourseName'] == courseToday[3][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[3][0]['CourseLocation']) {
        title = '[1 - 4 节] ${courseToday[0][0]['CourseName']}';
      } else if (courseToday[2].isNotEmpty && courseToday[0][0]['CourseName'] == courseToday[2][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[2][0]['CourseLocation']) {
        title = '[1 - 3 节] ${courseToday[0][0]['CourseName']}';
      } else if (courseToday[1].isNotEmpty && courseToday[0][0]['CourseName'] == courseToday[1][0]['CourseName'] && courseToday[0][0]['CourseLocation'] == courseToday[1][0]['CourseLocation']) {
        title = '[1 - 2 节] ${courseToday[0][0]['CourseName']}';
      } else {
        title = '[第 1 节] ${courseToday[0][0]['CourseName']}';
      }
    } else if (index == 2) {
      if (courseToday[3].isNotEmpty && courseToday[2][0]['CourseName'] == courseToday[3][0]['CourseName'] && courseToday[2][0]['CourseLocation'] == courseToday[3][0]['CourseLocation']) {
        title = '[3 - 4 节] ${courseToday[2][0]['CourseName']}';
      } else {
        title = '[第 3 节] ${courseToday[2][0]['CourseName']}';
      }
    } else if (index == 4) {
      if (courseToday[7].isNotEmpty && courseToday[4][0]['CourseName'] == courseToday[7][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[7][0]['CourseLocation']) {
        title = '[5 - 8 节] ${courseToday[4][0]['CourseName']}';
      } else if (courseToday[6].isNotEmpty && courseToday[4][0]['CourseName'] == courseToday[6][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[6][0]['CourseLocation']) {
        title = '[5 - 7 节] ${courseToday[4][0]['CourseName']}';
      } else if (courseToday[5].isNotEmpty && courseToday[4][0]['CourseName'] == courseToday[5][0]['CourseName'] && courseToday[4][0]['CourseLocation'] == courseToday[5][0]['CourseLocation']) {
        title = '[5 - 6 节] ${courseToday[4][0]['CourseName']}';
      } else {
        title = '[第 5 节] ${courseToday[4][0]['CourseName']}';
      }
    } else if (index == 6) {
      if (courseToday[7].isNotEmpty && courseToday[6][0]['CourseName'] == courseToday[7][0]['CourseName'] && courseToday[6][0]['CourseLocation'] == courseToday[7][0]['CourseLocation']) {
        title = '[7 - 8 节] ${courseToday[6][0]['CourseName']}';
      } else {
        title = '[第 7 节] ${courseToday[6][0]['CourseName']}';
      }
    } else if (index == 8) {
      if (courseToday[9].isNotEmpty && courseToday[8][0]['CourseName'] == courseToday[9][0]['CourseName'] && courseToday[8][0]['CourseLocation'] == courseToday[9][0]['CourseLocation']) {
        title = '[9 - 10 节] ${courseToday[8][0]['CourseName']}';
      } else {
        title = '[第 9 节] ${courseToday[8][0]['CourseName']}';
      }
    } else {
      title = '[第 ${index + 1} 节] ${courseToday[index][0]['CourseName']}';
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withAlpha(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: GlobalVars.listTileTitle,
                color: Theme.of(context).colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${courseToday[index][0]['CourseTeacher']}',
                    style: TextStyle(
                      fontSize: GlobalVars.listTileSubtitle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${(courseToday[index][0]['CourseLocation'] == '')? '无地点信息' : courseToday[index][0]['CourseLocation']}',
                    style: TextStyle(
                      fontSize: GlobalVars.listTileSubtitle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 功能按钮构建辅助方法
  Widget buildFunctionButton(BuildContext context, String title, String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              Theme.of(context).brightness == Brightness.light
                ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/$iconName.png')
                : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/$iconName.png'),
              height: 40,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: GlobalVars.genericFunctionsButtonTitle,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  // 新闻项目构建辅助方法
  Widget buildNewsItem(BuildContext context, Map<String, dynamic> news) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        '${news['title']}',
        style: TextStyle(
          fontSize: GlobalVars.listTileTitle,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   Icons.calendar_today,
                  //   size: 14,
                  //   color: Theme.of(context).colorScheme.secondary,
                  // ),
                  // SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${news['date']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: GlobalVars.listTileSubtitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              '点击查看',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: GlobalVars.listTileSubtitle,
              ),
            ),
          ],
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onTap: () {
        url = Uri.parse('https://www.snut.edu.cn${news['location']}');
        launchURL();
      },
    );
  }

  //获取公告
  getSmartSNUTAnnouncement() async {
    smartSNUTAnnouncements = [];
    Dio dio = Dio();
    late Response smartSNUTNotifyResponse;
    try{
      smartSNUTNotifyResponse = await dio.get('https://apis.smartsnut.cn/MP/Announcement/Announcement.json');
    }catch(e){
      return;
    }
    if(mounted){
      smartSNUTAnnouncements = jsonDecode(jsonEncode(smartSNUTNotifyResponse.data));
      setState(() {
        announcementState = 1;
      });
    }
  }

  //获取新闻并解析，便于首页渲染
  getNewsList() async {
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }

    List getNewsListResponse = await Modules.getNewsList();
    if(getNewsListResponse[0]['statue'] == false){
      if(mounted){
        setState(() {
          newsState = 0;
          isLoading = false;
          loadSuccess = false;
        });
      }
      return;
    }
    tzgg1 = getNewsListResponse[0]['tzgg1'];
    tzgg2 = getNewsListResponse[0]['tzgg2'];
    tzgg3 = getNewsListResponse[0]['tzgg3'];
    tzgg4 = getNewsListResponse[0]['tzgg4'];
    tzgg5 = getNewsListResponse[0]['tzgg5'];
    tzgg6 = getNewsListResponse[0]['tzgg6'];

    if(mounted){
      setState(() {
        newsState = 1;
        isLoading = false;
        loadSuccess = true;
      });
    }
  }

  getCourseTable() async {
    GlobalVars.operationCanceled = false;
    GlobalVars.loadingHint = '正在刷新课表数据...';
    if(mounted){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: Text('请稍后...',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Column(
                children: [
                  SizedBox(height: 10,),
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text(GlobalVars.loadingHint,style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    GlobalVars.operationCanceled = true;
                    Navigator.pop(context);
                  },
                  child: Text('取消'),
                ),
              ],
            ),
          );
        },
      );
    }
    
    List getCourseTableResponse = await Modules.getCourseTable(GlobalVars.userName, GlobalVars.passWord,currentYearInt, currentTermInt);
    if(getCourseTableResponse[0]['statue'] == false){
      if(mounted){
        setState(() {});
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('错误',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Text(getCourseTableResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    //保存课表
    await GlobalVars.globalPrefs.setString('courseTableStd-courseTable-${getCourseTableResponse[0]['semesterId']}', jsonEncode(getCourseTableResponse[0]['courseTableData']));

    //保存校历
    List schoolCalendar = [];
    schoolCalendar.clear();
    schoolCalendar.add({
      'termStart': getCourseTableResponse[0]['termStart'],
      'termEnd': getCourseTableResponse[0]['termEnd'],
      'termWeeks': getCourseTableResponse[0]['termWeeks'],
    });
    GlobalVars.globalPrefs.setString('schoolCalendar-${getCourseTableResponse[0]['semesterId']}', jsonEncode(getCourseTableResponse[0]['schoolCalendarData']));

    weekDiff = 0;
    currentWeekInt = userSelectedWeekInt;
    
    GlobalVars.lastCourseTableRefreshTime = DateTime.now().millisecondsSinceEpoch;
    await Modules.saveSettings(context);
    readSchoolCalendarInfo();
    if(mounted){
      Navigator.pop(context);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('课表数据刷新成功'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }
  //打开链接
  void launchURL() async {
    textUrlController.text = url.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Icon(Icons.info),
            SizedBox(width: 8),
            Text('提示：', style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
          ],
        ),
        content: Column(
          children: [
            Text('由于小程序能力受限，请手动复制链接后粘贴到浏览器访问',
            style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
            MPFlutterTextField(
              controller: textUrlController,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.link_off_outlined),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}
