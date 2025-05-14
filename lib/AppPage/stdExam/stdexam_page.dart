import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';
//验证码输入框
TextEditingController textCaptchaController = TextEditingController();

//学期信息
String termStart = '';
String termEnd = '';
int termWeeks = 0;
bool termEnded = false;

//菜单 Controller
final menuYearController = MenuController();
final menuTermController = MenuController();
final menuExamBatchController = MenuController();

//用户数据
List stdAccount = [];
String userName = '';
String passWord = '';

//学期数据
Map semestersData = {};
int semesterTotal = 0;//学年的数量
List semestersName = [];

//当前考试学年
int currentYearInt = 1;
String currentYearName = '';

//当前考试学期
int currentTermInt = 1;
String currentTermName = '';

//当前考试批次
int currentExamBatch = 1;
int currentExamBatchid = 000;
String currentExamBatchName = '';

//当前学期考试信息
List stdExamTotal = [];
bool noExam = false;//用于判断该学期是否有考试

class StdExamPage extends StatefulWidget{
  const StdExamPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StdExamPageState();
  }
}

class _StdExamPageState extends State<StdExamPage>{
  bool _showAppBarTitle = false;

  //读取用户信息并保存在变量中
  readStdAccount() async {
    if(mounted){
      setState(() {
        userName = GlobalVars.stdAccount[0]['UserName'];
        passWord = GlobalVars.stdAccount[0]['PassWord'];
      });
    }
  }

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
    readSelectState();
  }

  //读取学期的选中状态
  readSelectState() async {
    if(GlobalVars.globalPrefs.containsKey('stdExam-selectedTY')){
      String selectedTYValue = GlobalVars.globalPrefs.getString('stdExam-selectedTY')!;
      List selectedTYList = jsonDecode(selectedTYValue);
      if(mounted){
        setState(() {
          currentYearInt = selectedTYList[0]['selectedYear'];
          currentYearName = semestersName[currentYearInt]['name'];
          currentTermInt = selectedTYList[1]['selectedTerm'];
          if(currentTermInt == 1){
            currentTermName = '第一学期';
          }if(currentTermInt == 2){
            currentTermName = '第二学期';
          }
          currentExamBatch = selectedTYList[2]['examBatch'];
          if(currentExamBatch == 0){
            currentExamBatchName = '期末考试';
          }if(currentExamBatch == 1){
            currentExamBatchName = '重修考试';
          }
        });
      }
    }else{
      if(mounted){
        setState(() {
          currentYearInt = 0;
          currentYearName = semestersName[0]['name'];
          currentExamBatch = 0;
          currentExamBatchName = '期末考试';
        });
      }
      saveSelectedTY();
    }
    readSchoolCalendarInfo();
  }

  //读取校历相关信息
  readSchoolCalendarInfo() async {
    String semesterId = '';
    //使用本地选中的 semetserid 来读取对应的校历
    semesterId = semestersData['y$currentYearInt'][currentTermInt -1 ]['id'].toString();
    if(GlobalVars.globalPrefs.containsKey('schoolCalendar-$semesterId')){
      var termTimejson = jsonDecode(GlobalVars.globalPrefs.getString('schoolCalendar-$semesterId')!);
      termStart = termTimejson[0]['termStart'];
      termEnd = termTimejson[0]['termEnd'];
    }
    readstdExam();
  }

  //读取考试信息
  readstdExam() async  {
    //使用本地选中的 semetserid 来读取对应的课表
    late List stdExamBatchInfo;
    String semesterId = semestersData['y$currentYearInt'][currentTermInt -1 ]['id'].toString();
    if(GlobalVars.globalPrefs.containsKey('stdExam-stdExamBatch-$semesterId')){
      stdExamBatchInfo = jsonDecode(GlobalVars.globalPrefs.getString('stdExam-stdExamBatch-$semesterId')!);
      if(currentExamBatch == 0){
        if(stdExamBatchInfo[0]['normalExam'] == ''){
          if(mounted){
            setState(() {
              noExam = true;
            });
          }
        }else{
          currentExamBatchid = int.parse(stdExamBatchInfo[0]['normalExam']);
          if(mounted){
            setState(() {
              noExam = false;
            });
          }
        }
      }if(currentExamBatch == 1){
        if(stdExamBatchInfo[0]['retakeExam'] == ''){
          if(mounted){
            setState(() {
              noExam = true;
            });
          }
        }else{
          currentExamBatchid = int.parse(stdExamBatchInfo[0]['retakeExam']);
          if(mounted){
            setState(() {
              noExam = false;
            });
          }
        }
      }
    }else{
      if(mounted){
        setState(() {
          noExam = true;
        });
      }
    }

    if(GlobalVars.globalPrefs.containsKey('stdExam-stdExam-$semesterId-$currentExamBatchid')){
      var readexamTotal = jsonDecode(GlobalVars.globalPrefs.getString('stdExam-stdExam-$semesterId-$currentExamBatchid')!);
      if(readexamTotal.isEmpty){
        if(mounted){
          setState(() {
            noExam = true;
          });
        }
      }else{
        if(mounted){
          setState(() {
            stdExamTotal = readexamTotal;
            noExam = false;
          });
        }
      }
    }else{
      if(mounted){
        setState(() {
          noExam = true;
        });
      }
    }
  }
  
  ///保存选中的考试学期状态
  saveSelectedTY() async {
    List selectedTY = [];
    selectedTY.remove('selectedYear');
    selectedTY.remove('selectedTerm');
    selectedTY.remove('examBatch');
    selectedTY.add({
      'selectedYear': currentYearInt,
    });
    selectedTY.add({
      'selectedTerm': currentTermInt,
    });
    selectedTY.add({
      'examBatch': currentExamBatch,
    });
    //保存完成后刷新状态，防止出现参数更新不及时的情况
    setState(() {});
    await GlobalVars.globalPrefs.setString('stdExam-selectedTY', jsonEncode(selectedTY));
  }

  //切换考试学期
  switchTerm() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            scrollable: true,
            title: Text('切换考试时间',style: TextStyle(fontSize: GlobalVars.alertdialogTitle),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 学年选择
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MenuAnchor(
                    controller: menuYearController,
                    menuChildren: semestersName.map((item) {
                      return MenuItemButton(
                        onPressed: () async {
                          int yearSelectedIndex = semestersName.indexOf(item);
                          if(mounted){
                            setState(() {
                              currentYearInt = yearSelectedIndex;
                              currentYearName = item['name'];
                            });
                          }
                          saveSelectedTY();
                          readSemesterInfo();
                          menuYearController.close();
                        },
                        child: Text('${item['name']} 学年',style: TextStyle(fontSize: GlobalVars.genericSwitchMenuTitle),),
                      );
                    }).toList(),
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (menuYearController.isOpen) {
                            menuYearController.close();
                          } else {
                            menuYearController.open();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '学年：$currentYearName',
                              style: TextStyle(
                                fontSize: GlobalVars.genericSwitchMenuTitle,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 学期选择
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MenuAnchor(
                    controller: menuTermController,
                    menuChildren: [
                      MenuItemButton(
                        child: Text('第一学期',style: TextStyle(fontSize: GlobalVars.genericSwitchMenuTitle),),
                        onPressed: () async {
                          if(mounted){
                            setState(() {
                              currentTermInt = 1;
                              currentTermName = '第一学期';
                            });
                          }
                          saveSelectedTY();
                          readSemesterInfo();
                          menuTermController.close();
                        },
                      ),
                      MenuItemButton(
                        child: Text('第二学期',style: TextStyle(fontSize: GlobalVars.genericSwitchMenuTitle),),
                        onPressed: () async {
                          if(mounted){
                            setState(() {
                              currentTermInt = 2;
                              currentTermName = '第二学期';
                            });
                          }
                          saveSelectedTY();
                          readSemesterInfo();
                          menuTermController.close();
                        },
                      ),
                    ],
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (menuTermController.isOpen) {
                            menuTermController.close();
                          } else {
                            menuTermController.open();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '学期：$currentTermName', 
                              style: TextStyle(
                                fontSize: GlobalVars.genericSwitchMenuTitle,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确定'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await readStdAccount();
      await readSemesterInfo();
      await readstdExam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          getStdExam();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Row(
          children: [
            Icon(Icons.refresh),
            SizedBox(width: 10,),
            Text('刷新数据',style: TextStyle(fontSize: GlobalVars.genericFloationActionButtonTitle),)
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels > 80 && !_showAppBarTitle) {
            setState(() {
              _showAppBarTitle = true;
            });
          } else if (scrollNotification.metrics.pixels <= 80 &&
              _showAppBarTitle) {
            setState(() {
              _showAppBarTitle = false;
            });
          }
          return true;
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                actions: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 100, 0),
                    child: IconButton(
                      onPressed: () => switchTerm(),
                      icon: Icon(Icons.date_range),
                      tooltip: '切换考试时间',
                    ),
                  )
                ],
                pinned: true,
                expandedHeight: 0,
                title: _showAppBarTitle ? Text("我的考试") : null,
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 30),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            Theme.of(context).brightness == Brightness.light
                              ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/exam.png')
                              : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/exam.png'),
                            height: 32,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '我的考试',
                          style: TextStyle(
                            fontSize: GlobalVars.genericPageTitle,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // 考试类型选择卡片
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.type_specimen,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: MenuAnchor(
                                controller: menuExamBatchController,
                                menuChildren: [
                                  MenuItemButton(
                                    child: Text('期末考试',style: TextStyle(fontSize: GlobalVars.genericSwitchMenuTitle),),
                                    onPressed: () async {
                                      if(mounted){
                                        setState(() {
                                          currentExamBatch = 0;
                                          currentExamBatchName = '期末考试';
                                        });
                                      }
                                      saveSelectedTY();
                                      readSemesterInfo();
                                      menuExamBatchController.close();
                                    },
                                  ),
                                  MenuItemButton(
                                    child: Text('重修考试',style: TextStyle(fontSize: GlobalVars.genericSwitchMenuTitle),),
                                    onPressed: () async {
                                      if(mounted){
                                        setState(() {
                                          currentExamBatch = 1;
                                          currentExamBatchName = '重修考试';
                                        });
                                      }
                                      saveSelectedTY();
                                      readSemesterInfo();
                                      menuExamBatchController.close();
                                    },
                                  ),
                                ],
                                child: SizedBox(
                                  height: 50,
                                  child: TextButton(
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: Theme.of(context).colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (menuExamBatchController.isOpen) {
                                        menuExamBatchController.close();
                                      } else {
                                        menuExamBatchController.open();
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '类型：$currentExamBatchName', 
                                          style: TextStyle(
                                            fontSize: GlobalVars.genericSwitchContainerTitle,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis
                                        ),
                                        Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 考试信息内容区域
                  noExam ? 
                  // 无考试信息显示
                  Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: Card(
                        shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                        color: Theme.of(context).colorScheme.surfaceDim,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                Theme.of(context).brightness == Brightness.light? 
                                  useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/empty.png'):
                                  useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/empty.png'),
                                height: MediaQuery.of(context).size.height / 4,
                              ),
                              Divider(height: 24, indent: 20, endIndent: 20,),
                              Text(
                                '暂无 $currentYearName $currentTermName 的 $currentExamBatchName 信息',
                                style: TextStyle(
                                  fontSize: GlobalVars.listTileTitle,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '请尝试在右上角切换学期或在右下角刷新',
                                style: TextStyle(
                                  fontSize: GlobalVars.listTileSubtitle,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) : 
                  // 有考试信息显示
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Card(
                      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '$currentYearName $currentTermName $currentExamBatchName',
                                      style: TextStyle(
                                        fontSize: GlobalVars.listTileTitle,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 24, indent: 16, endIndent: 16),
                            Column(
                              children: stdExamTotal.map((exam) {
                                return buildExamItem(context, exam);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 底部间隔
                  Container(padding: EdgeInsets.fromLTRB(0, 80, 0, 0),)
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 考试项构建辅助方法
  Widget buildExamItem(BuildContext context, Map exam) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${exam['CourseName']}', 
              style: TextStyle(
                fontSize: GlobalVars.listTileTitle, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event, 
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  '考试日期：${exam['CourseExamDate']}', 
                  style: TextStyle(
                    fontSize: GlobalVars.genericTextMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time, 
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  '考试时间：${exam['CourseExamTime']}', 
                  style: TextStyle(
                    fontSize: GlobalVars.genericTextMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on, 
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '考试地点：${exam['CourseExamLocation']}', 
                    style: TextStyle(
                      fontSize: GlobalVars.genericTextMedium,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event_seat, 
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  '座位号：${exam['CourseExamSeatNo']}', 
                  style: TextStyle(
                    fontSize: GlobalVars.genericTextMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.category, 
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  '考试类型：${exam['CourseExamType']}', 
                  style: TextStyle(
                    fontSize: GlobalVars.genericTextMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getStdExam() async {
    GlobalVars.operationCanceled = false;
    GlobalVars.loadingHint = '正在刷新考试数据...';
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

    if(GlobalVars.operationCanceled) return;
    List getStdExamResponse = await Modules.getStdExam(userName, passWord,currentYearInt, currentTermInt, currentExamBatchid);
    if(getStdExamResponse[0]['statue'] == false){
      if(mounted){
        if(GlobalVars.operationCanceled) return;
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('错误',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Text(getStdExamResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
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
    
    //保存考试批次信息
    await GlobalVars.globalPrefs.setString('stdExam-stdExamBatch-${getStdExamResponse[0]['semesterId']}', jsonEncode(getStdExamResponse[0]['stdExamBatchID']));

    //保存考试信息
    await GlobalVars.globalPrefs.setString('stdExam-stdExam-${getStdExamResponse[0]['semesterId']}-${getStdExamResponse[0]['currentExamBatchId']}', jsonEncode(getStdExamResponse[0]['stdExamTotal']));

    readSchoolCalendarInfo();
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('考试数据刷新成功'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      Navigator.pop(context);
    }
  }

}