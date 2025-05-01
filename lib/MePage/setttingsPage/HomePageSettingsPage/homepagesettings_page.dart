import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

class HomePageSettingsPage extends StatefulWidget{
  const HomePageSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageSettingsPage();
  }
}

class _HomePageSettingsPage extends State<HomePageSettingsPage>{
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
                title: _showAppBarTitle ? Text("首页设置") : null,
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
                        Text('首页设置',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
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
                                value: GlobalVars.switchTomorrowCourseAfter20,
                                onChanged: (value) {
                                  GlobalVars.switchTomorrowCourseAfter20 = value;
                                  Modules.saveSettings(context);
                                },
                              ),
                              title: Text('自动切换明日课程',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text('在每天晚上的 20:00 之后，自动切换首页的课表到明日课表',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                              trailing: Switch(
                                value: GlobalVars.showTzgg,
                                onChanged: (value) {
                                  GlobalVars.showTzgg = value;
                                  Modules.saveSettings(context);
                                },
                              ),
                              title: Text('在首页显示 “通知公告” 栏目',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text('展示学校官网的通知公告',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
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
}