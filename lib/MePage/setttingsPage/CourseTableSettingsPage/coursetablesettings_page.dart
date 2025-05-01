import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

//开源许可
String licenseTitle = '';
String licensePath = '';
String licenseContent = '';

//用于即将打开的链接的完整URL
Uri url = Uri.parse("uri");
TextEditingController textUrlController = TextEditingController();

class CourseTableSettingsPage extends StatefulWidget{
  const CourseTableSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CourseTableSettingsPage();
  }
}

class _CourseTableSettingsPage extends State<CourseTableSettingsPage>{
  bool _showAppBarTitle = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
                pinned: true,
                expandedHeight: 0,
                title: _showAppBarTitle ? Text("课表设置") : null,
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 30),
                    child: Row(
                      children: [
                        Image.network(Theme.of(context).brightness == Brightness.light? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/settings.png'):useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/settings.png'),height: 40,),
                        SizedBox(width: 12,),
                        Text('课表设置',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      shadowColor: Theme.of(context).colorScheme.onPrimary,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.calendar_view_week, color: Theme.of(context).colorScheme.primary),
                              trailing: Switch(
                                value: GlobalVars.switchNextWeekCourseAfter20,
                                onChanged: (value) {
                                  GlobalVars.switchNextWeekCourseAfter20 = value;
                                  Modules.saveSettings(context);
                                },
                              ),
                              title: Text('自动切换下周课表',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text('在每周日的晚上 20:00 之后，自动切换 “我的课表” 页面的课表到下周课表',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.calendar_view_week, color: Theme.of(context).colorScheme.primary),
                              trailing: Switch(
                                value: GlobalVars.showSatCourse,
                                onChanged: (value) {
                                  GlobalVars.showSatCourse = value;
                                  Modules.saveSettings(context);
                                },
                              ),
                              title: Text('显示周六课程',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text('在 "我的课表" 中显示周六的课程',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.calendar_view_week, color: Theme.of(context).colorScheme.primary),
                              trailing: Switch(
                                value: GlobalVars.showSunCourse,
                                onChanged: (value) {
                                  GlobalVars.showSunCourse = value;
                                  Modules.saveSettings(context);
                                },
                              ),
                              title: Text('显示周日课程',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text('在 "我的课表" 中显示周日的课程',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.color_lens, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('课程色系',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text((GlobalVars.courseBlockColorsInt == 0)? '莫兰迪色系':'马卡龙色系',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                              onTap: (){switchCourseBlockColor();},
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  //切换课程色系
  switchCourseBlockColor() {
    int groupValue = GlobalVars.courseBlockColorsInt;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            scrollable: true,
            title: Text('课程色系',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 0,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 0;
                        if(mounted){
                          setState((){
                            GlobalVars.courseBlockColorsInt = 0;
                          });
                        }
                        Modules.saveSettings(context);
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('莫兰迪色系',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 1,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 1;
                        if(mounted){
                          setState((){
                            GlobalVars.courseBlockColorsInt = 1;
                          });
                        }
                        Modules.saveSettings(context);
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('马卡龙色系',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Modules.saveSettings(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}