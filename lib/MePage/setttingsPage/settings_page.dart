import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPage();
  }
}

class _SettingsPage extends State<SettingsPage>{
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
                title: _showAppBarTitle ? Text("应用设置") : null,
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
                        Text('应用设置',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
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
                              leading: Icon(Icons.settings_applications, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('通用设置',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              onTap: (){
                                Navigator.pushNamed(context, '/SettingsPage/GeneralSettingsPage');
                              },
                            ),
                          ],
                        )
                      ),
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
                              leading: Icon(Icons.dashboard_customize, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('首页设置',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              onTap: (){
                                Navigator.pushNamed(context, '/SettingsPage/HomePageSettingsPage');
                              },
                            ),
                          ],
                        )
                      ),
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
                              trailing: Icon(Icons.chevron_right),
                              title: Text('课表设置',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              onTap: (){
                                Navigator.pushNamed(context, '/SettingsPage/CourseTableSettingsPage');
                              },
                            ),
                          ],
                        )
                      ),
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
                              leading: Icon(Icons.manage_accounts, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('账号设置',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              onTap: (){
                                Navigator.pushNamed(context, '/SettingsPage/AccountSettingsPage');
                              },
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
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
                              leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('关于智慧陕理',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              onTap: (){
                                Navigator.pushNamed(context, '/SettingsPage/AboutPage');
                              },
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