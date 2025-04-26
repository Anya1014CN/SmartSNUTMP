import 'dart:convert';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:smartsnutmp/globalvars.dart';
import 'package:dio/dio.dart';

class Modules {
  static final String apiUrl = 'https://apis.smartsnut.cn/WebAPI';
  //刷新动态信息
  static refreshState() async {
    // 处理首页和应用页的问候语
    if(GlobalVars.hour >= 0 && GlobalVars.hour <= 5){
      GlobalVars.greeting = '晚上好';
    }if(GlobalVars.hour >= 6 && GlobalVars.hour <= 11){
      GlobalVars.greeting = '早上好';
    }if(GlobalVars.hour >= 12 && GlobalVars.hour <= 13){
      GlobalVars.greeting = '中午好';
    }if(GlobalVars.hour >= 14 && GlobalVars.hour <= 18){
      GlobalVars.greeting = '下午好';
    }if(GlobalVars.hour >= 19 && GlobalVars.hour <= 23){
      GlobalVars.greeting = '晚上好';
    }
    //处理我的页的问候语
    if(GlobalVars.hour >= 0 && GlobalVars.hour <= 5){
      GlobalVars.hint = '劳逸结合，注意休息';
    }if(GlobalVars.hour >= 6 && GlobalVars.hour <= 8){
      GlobalVars.hint = '新的一天，元气满满';
    }if(GlobalVars.hour >= 9 && GlobalVars.hour <= 11){
      GlobalVars.hint = '专心学习，高效进步';
    }if(GlobalVars.hour >= 12 && GlobalVars.hour <= 13){
      GlobalVars.hint = '适量休息，补充能量';
    }if(GlobalVars.hour >= 14 && GlobalVars.hour <= 17){
      GlobalVars.hint = '专注实践，提升自我';
    }if(GlobalVars.hour >= 18 && GlobalVars.hour <= 19){
      GlobalVars.hint = '总结反思，调整步伐';
    }if(GlobalVars.hour >= 20 && GlobalVars.hour < 24){
      GlobalVars.hint = '适时放松，迎接明天';
    }
    // 获取今天的日期
    DateTime now = DateTime.now();
            
    // 月和日强制转换为两位数字
    int month = DateTime.now().month;
    GlobalVars.monthString = month.toString().padLeft(2, '0');
    int day = DateTime.now().day;
    GlobalVars.dayString = day.toString().padLeft(2, '0');
            
    GlobalVars.hour = DateTime.now().hour;
            
    // 初始化中文日期格式
    initializeDateFormatting("zh_CN");
    GlobalVars.weekDay = intl.DateFormat('EEEE', "zh_CN").format(now);
            
    // 获取明天的日期和星期
    DateTime tomorrow = now.add(Duration(days: 1));
    int tomorrowMonth = tomorrow.month;
    GlobalVars.tomorrowMonthString = tomorrowMonth.toString().padLeft(2, '0');
    int tomorrowDay = tomorrow.day;
    GlobalVars.tomorrowDayString = tomorrowDay.toString().padLeft(2, '0');
    GlobalVars.tomorrowWeekDay = intl.DateFormat('EEEE', "zh_CN").format(tomorrow);
  }

  //登录
  static Future<List> loginAuth(String userName, String passWord,String loginService) async {
    //存储返回的信息
    List message = [];

    late Response loginAuthResponse;
    try{
      loginAuthResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "Login","Content": [{"UserName": "$userName","PassWord": "$passWord"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }

    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'stdDetail': loginAuthResponse.data[0]['studentInfo'],
      'semestersData': loginAuthResponse.data[0]['semestersData'],
    });
    return message;
  }
  
  //设置字体大小
  static setFontSize() {
    double changevalue = 0;
    if(GlobalVars.fontsizeint == 0)changevalue = -6;
    if(GlobalVars.fontsizeint == 1)changevalue = -4;
    if(GlobalVars.fontsizeint == 2)changevalue = -2;
    if(GlobalVars.fontsizeint == 3)changevalue = 0;
    if(GlobalVars.fontsizeint == 4)changevalue = 2;
    if(GlobalVars.fontsizeint == 5)changevalue = 4;
    if(GlobalVars.fontsizeint == 6)changevalue = 6;

    //弹出对话框字体
    GlobalVars.alertdialogTitle = DefaultfontSize.alertdialogTitle + changevalue;
    GlobalVars.alertdialogContent = DefaultfontSize.alertdialogContent + changevalue;

    //通用页面字体
    GlobalVars.splashPageTitle = DefaultfontSize.splashPageTitle + changevalue;
    GlobalVars.bottonbarAppnameTitle = DefaultfontSize.bottonbarAppnameTitle + changevalue;
    GlobalVars.bottonbarSelectedTitle = DefaultfontSize.bottonbarSelectedTitle + changevalue;
    GlobalVars.bottonbarUnselectedTitle = DefaultfontSize.bottonbarUnselectedTitle + changevalue;
    GlobalVars.genericPageTitle = DefaultfontSize.genericPageTitle + changevalue;
    GlobalVars.genericPageTitleSmall = DefaultfontSize.genericPageTitleSmall + changevalue;
    GlobalVars.genericGreetingTitle = DefaultfontSize.genericGreetingTitle + changevalue;
    GlobalVars.genericFloationActionButtonTitle = DefaultfontSize.genericFloationActionButtonTitle + changevalue;
    GlobalVars.dividerTitle = DefaultfontSize.dividerTitle + changevalue;
    GlobalVars.listTileTitle = DefaultfontSize.listTileTitle + changevalue;
    GlobalVars.listTileSubtitle = DefaultfontSize.listTileSubtitle + changevalue;
    GlobalVars.genericFunctionsButtonTitle = DefaultfontSize.genericFunctionsButtonTitle + changevalue;
    GlobalVars.genericSwitchContainerTitle = DefaultfontSize.genericSwitchContainerTitle + changevalue;
    GlobalVars.genericSwitchMenuTitle = DefaultfontSize.genericSwitchMenuTitle + changevalue;
    GlobalVars.genericTextSmall = DefaultfontSize.genericTextSmall + changevalue;
    GlobalVars.genericTextMedium = DefaultfontSize.genericTextMedium + changevalue;
    GlobalVars.genericTextLarge = DefaultfontSize.genericTextLarge + changevalue;
  }

  //我的课表
  static Future<List> getNewsList() async {
    //存储返回的信息
    List message = [];

    late Response getNewsListResponse;
    try{
      getNewsListResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "SNUTtzgg"}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    List getNewsListResponseList = jsonDecode(getNewsListResponse.data);

    if(getNewsListResponseList[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getNewsListResponseList[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'tzgg1': getNewsListResponseList[0]['tzgg1'],
      'tzgg2': getNewsListResponseList[0]['tzgg2'],
      'tzgg3': getNewsListResponseList[0]['tzgg3'],
      'tzgg4': getNewsListResponseList[0]['tzgg4'],
      'tzgg5': getNewsListResponseList[0]['tzgg5'],
      'tzgg6': getNewsListResponseList[0]['tzgg6'],
    });
    return message;
  }

  //读取设置
  static readSettings() async {
    if(GlobalVars.globalPrefs.containsKey('Settings')){
      GlobalVars.settingsTotal = jsonDecode(await GlobalVars.globalPrefs.getString('Settings')!);
      GlobalVars.fontsizeint = GlobalVars.settingsTotal[0]['fontSize']?? 3;
      GlobalVars.darkModeint = GlobalVars.settingsTotal[0]['DarkMode']?? 0;
      GlobalVars.themeColor = GlobalVars.settingsTotal[0]['ThemeColor']?? 1;
      GlobalVars.showSatCourse = GlobalVars.settingsTotal[0]['showSatCourse']?? true;
      GlobalVars.showSunCourse = GlobalVars.settingsTotal[0]['showSunCourse']?? true;
      GlobalVars.courseBlockColorsInt = GlobalVars.settingsTotal[0]['courseBlockColorsint']?? 0;
      GlobalVars.switchTomorrowCourseAfter20 = GlobalVars.settingsTotal[0]['switchTomorrowCourseAfter20']?? true;
      GlobalVars.switchNextWeekCourseAfter20 = GlobalVars.settingsTotal[0]['switchNextWeekCourseAfter20']?? true;
      GlobalVars.showTzgg = GlobalVars.settingsTotal[0]['showTzgg']?? false;
    }else{
      GlobalVars.fontsizeint = 3;
      GlobalVars.darkModeint = 0;
      GlobalVars.themeColor = 1;
      GlobalVars.showSatCourse = true;
      GlobalVars.showSunCourse = true;
      GlobalVars.courseBlockColorsInt = 0;
      GlobalVars.switchTomorrowCourseAfter20 = true;
      GlobalVars.switchNextWeekCourseAfter20 = true;
      GlobalVars.showTzgg = false;
    }
  }

  //读取用户信息并保存在变量中
  static readStdAccount() async {
    if(GlobalVars.globalPrefs.containsKey('stdAccount')){
      String stdAccountValue = GlobalVars.globalPrefs.getString('stdAccount')!;
      GlobalVars.stdAccount = jsonDecode(stdAccountValue);
    }
    
    if(GlobalVars.globalPrefs.containsKey('stdDetail')){
      String stdDetailValue = GlobalVars.globalPrefs.getString('stdDetail')!;
      GlobalVars.stdDetail = jsonDecode(stdDetailValue);
    }
    
    GlobalVars.realName = GlobalVars.stdDetail['姓名：'];
    GlobalVars.userName = GlobalVars.stdAccount[0]['UserName'];
    GlobalVars.passWord = GlobalVars.stdAccount[0]['PassWord'];

    if(GlobalVars.globalPrefs.containsKey('stdDetail')){
      String stdDetailValue = GlobalVars.globalPrefs.getString('stdDetail')!;
      Map<String, dynamic> jsonData = jsonDecode(stdDetailValue);
      GlobalVars.stdDetail = jsonData.map((key, value) => MapEntry(key, value.toString()));
    }

    GlobalVars.enrollTime = GlobalVars.stdDetail['入校时间：']!;
    GlobalVars.graduationTime = GlobalVars.stdDetail['毕业时间：']!;
  }

  //读取电表信息
  static readEMInfo() async {
    if(GlobalVars.globalPrefs.containsKey('emBindData-emUserData')){
      GlobalVars.emUserData = jsonDecode(await GlobalVars.globalPrefs.getString('emBindData-emUserData')!);
      GlobalVars.openId = GlobalVars.emUserData[0]['openId'];
      GlobalVars.wechatUserId = GlobalVars.emUserData[0]['wechatId'];
      GlobalVars.wechatUserNickname = GlobalVars.emUserData[0]['wechatUserNickname'];
      GlobalVars.emNum = GlobalVars.emDetail.length;
      if(GlobalVars.openId == '' || GlobalVars.wechatUserId == '' || GlobalVars.wechatUserNickname == ''){
        GlobalVars.emBinded = false;
        return;
      }
      GlobalVars.emBinded = true;
    }else{
      GlobalVars.emBinded = false;
    }
    
    //读取电表详情
    if(GlobalVars.globalPrefs.containsKey('emBindData-emDetail')){
      GlobalVars.emDetail = jsonDecode(await GlobalVars.globalPrefs.getString('emBindData-emDetail')!);
      GlobalVars.emNum = GlobalVars.emDetail.length;
    }
  }

  //我的课表
  static Future<List> getCourseTable(String userName, String passWord, int currentYearInt, int currentTermInt) async {
    //存储返回的信息
    List message = [];

    late Response getCourseTableResponse;
    try{
      getCourseTableResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "CourseTable","Content": [{"UserName": "$userName","PassWord": "$passWord","currentYearInt": "$currentYearInt","currentTermInt": "$currentTermInt"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(getCourseTableResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getCourseTableResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'semesterId': getCourseTableResponse.data[0]['semesterId'],
      'termStart': getCourseTableResponse.data[0]['termStart'],
      'termEnd': getCourseTableResponse.data[0]['termEnd'],
      'termWeeks': getCourseTableResponse.data[0]['termWeeks'],
      'schoolCalendarData': getCourseTableResponse.data[0]['schoolCalendarData'],
      'courseTableData': getCourseTableResponse.data[0]['courseTableData'],
    });
    return message;
  }

  //我的考试
  static Future<List> getStdExam(String userName, String passWord, int currentYearInt, int currentTermInt, int currentExamBatch) async {
    //存储返回的信息
    List message = [];

    late Response getStdExamResponse;
    try{
      getStdExamResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "StdExam","Content": [{"UserName": "$userName","PassWord": "$passWord","currentYearInt": "$currentYearInt","currentTermInt": "$currentTermInt","currentExamBatch": "$currentExamBatch"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(getStdExamResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getStdExamResponse.data[0]['message'],
      });
      return message;
    }
    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'stdExamBatchID': getStdExamResponse.data[0]['stdExamBatchID'],
      'currentExamBatchId': getStdExamResponse.data[0]['currentExamBatchId'],
      'semesterId': getStdExamResponse.data[0]['semesterId'],
      'stdExamTotal': getStdExamResponse.data[0]['stdExamTotal'],
    });
    return message;
  }

  //我的成绩
  static Future<List> getStdGrades(String userName, String passWord, int currentYearInt, int currentTermInt) async {
    //存储返回的信息
    List message = [];

    late Response getStdGradesResponse;
    try{
      getStdGradesResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "StdGrades","Content": [{"UserName": "$userName","PassWord": "$passWord","currentYearInt": "$currentYearInt","currentTermInt": "$currentTermInt"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(getStdGradesResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getStdGradesResponse.data[0]['message'],
      });
      return message;
    }
    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'semesterId': getStdGradesResponse.data[0]['semesterId'],
      'stdGradesTotal': getStdGradesResponse.data[0]['stdGradesTotal'],
    });
    return message;
  }

  //校园网查询
  static Future<List> schoolNetworkQuery(String userName) async {
    //存储返回的信息
    List message = [];

    late Response schoolNetworkQueryResponse;
    try{
      schoolNetworkQueryResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "schoolNetworkQuery","Content": [{"UserName": "$userName"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(schoolNetworkQueryResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': schoolNetworkQueryResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'realName': schoolNetworkQueryResponse.data[0]['realName'],
      'balance': schoolNetworkQueryResponse.data[0]['balance'],
      'state': schoolNetworkQueryResponse.data[0]['state'],
      'expire': schoolNetworkQueryResponse.data[0]['expire']
    });
    return message;
  }

  //绑定电表账号
  static Future<List> queryEM(String wechatUserId, String electricUserUid, String userCode, String userAddress) async {
    //存储返回的信息
    List message = [];

    late Response queryEMResponse;
    try{
      queryEMResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "queryEM","Content": [{"wechatUserId": "$wechatUserId","electricUserUid": "$electricUserUid","UserCode": "$userCode","UserAddress": "$userAddress"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(queryEMResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': queryEMResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'emStateTotal': queryEMResponse.data[0]['emStateTotal'],
    });
    return message;
  }

  //绑定电表账号
  static Future<List> bindEMAccount(String openId) async {
    //存储返回的信息
    List message = [];

    late Response bindEMAccountResponse;
    try{
      bindEMAccountResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "bindEMAccount","Content": [{"openId": "$openId"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(bindEMAccountResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': bindEMAccountResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'openId': bindEMAccountResponse.data[0]['openId'],
      'wechatId': bindEMAccountResponse.data[0]['wechatId'],
      'wechatUserNickname': bindEMAccountResponse.data[0]['wechatUserNickname'],
      'emDetail': bindEMAccountResponse.data[0]['emDetail'],
    });
    return message;
  }

  //绑定电表
  static Future<List> bindEM(String meterId, String wechatUserId) async {
    //存储返回的信息
    List message = [];

    late Response bindEMResponse;
    try{
      bindEMResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "bindEM","Content": [{"meterId": "$meterId","wechatUserId": "$wechatUserId"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(bindEMResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': bindEMResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
    });
    return message;
  }

  //解绑电表
  static Future<List> unBindEM(String wechatBindId, String wechatUserId) async {
    //存储返回的信息
    List message = [];

    late Response bindEMResponse;
    try{
      bindEMResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "unBindEM","Content": [{"wechatBindId": "$wechatBindId","wechatUserId": "$wechatUserId"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(bindEMResponse.data[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': bindEMResponse.data[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
    });
    return message;
  }

  //初始化空闲教室数据
  static Future<List> initPublicFreeData() async {
    //存储返回的信息
    List message = [];

    late Response publicFreeResponse;
    try{
      publicFreeResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "initPublicFreeData"}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    List publicFreeResponseList = jsonDecode(publicFreeResponse.data);
    if(publicFreeResponseList[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': publicFreeResponseList[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '获取空闲教室初始数据成功',
      'campusList': publicFreeResponseList[0]['campusList'],
      'buildingList': publicFreeResponseList[0]['buildingList'],
      'classroomTypeList': publicFreeResponseList[0]['classroomTypeList'],
    });
    return message;
  }

  //查询空闲教室
  static Future<List> queryPublicFreeData(String classroomType,  String campus, String building,  String seats,  String classroomName, String cycleCount, String cycleType, String dateStart, String dateEnd, String roomApplyType, String timeBegin, String timeEnd,int pageNo) async {
    GlobalVars.loadingHint = '正在查询空闲教室...';

    //存储返回的信息
    List message = [];

    //查询信息
    late Response publicFreeResponse;
    try {
      if(GlobalVars.operationCanceled) {
        message.clear();
        message.add({
          'statue': true,
          'message': '操作已取消',
        });
        return message;
      }
      var response = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "queryPublicFreeData","Content": [{"classroom.type.id": "$classroomType","classroom.campus.id": "$campus","classroom.building.id": "$building","seats": "$seats","classroom.name": "$classroomName","cycleTime.cycleCount": "$cycleCount","cycleTime.cycleType": "$cycleType","cycleTime.dateBegin": "$dateStart","cycleTime.dateEnd": "$dateEnd","roomApplyTimeType": "$roomApplyType","timeBegin": "$timeBegin","timeEnd": "$timeEnd","pageNo":"$pageNo"}]}]'
      );
      publicFreeResponse = response;
    } catch(e) {
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    if(publicFreeResponse.data[0]['statue'] == false) {
      message.clear();
      message.add({
        'statue': false,
        'message': publicFreeResponse.data[0]['message'],
      });
      return message;
    }

    message.clear();
    message.add({
      'statue': true,
      'message': '查询空闲教室成功',
      'currentPage': publicFreeResponse.data[0]['currentPage'],
      'pageSize': publicFreeResponse.data[0]['pageSize'],
      'totalItems': publicFreeResponse.data[0]['totalItems'],
      'publicFreeData': publicFreeResponse.data[0]['publicFreeData'],
    });

    return message;
  }

  //获取班级列表
  static Future<List> getClassList() async {
    //存储返回的信息
    List message = [];

    late Response getClassListResponse;
    try{
      getClassListResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "classList","Content": [{"UserName": "${GlobalVars.userName}","PassWord": "${GlobalVars.passWord}"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    List getClassListResponseList = jsonDecode(getClassListResponse.data);
    if(getClassListResponseList[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getClassListResponseList[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'classList': getClassListResponseList[0]['classList'],
      'classMemberList': getClassListResponseList[0]['classMemberList'],
    });
    return message;
  }

  //获取班级列表
  static Future<List> getClassMemberList(String classId) async {
    //存储返回的信息
    List message = [];

    late Response getClassMemberListResponse;
    try{
      getClassMemberListResponse = await GlobalVars.globalDio.post(
        apiUrl,
        data: '[{"OperationType": "classMemberList","Content": [{"UserName": "${GlobalVars.userName}","PassWord": "${GlobalVars.passWord}","classId": "$classId"}]}]'
      );
    }catch(e){
      message.clear();
      message.add({
        'statue': false,
        'message': '无法连接服务器，请稍后再试',
      });
      return message;
    }
    List getClassMemberListResponseList = jsonDecode(getClassMemberListResponse.data);
    if(getClassMemberListResponseList[0]['statue'] == false){
      message.clear();
      message.add({
        'statue': false,
        'message': getClassMemberListResponseList[0]['message'],
      });
      return message;
    }

    // 返回成功信息和提取的数据
    message.clear();
    message.add({
      'statue': true,
      'message': '',
      'classList': getClassMemberListResponseList[0]['classList']
    });
    return message;
  }

}