import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/MePage/electricMeterBindPage/electricmeterbind_page.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//开源许可
String licenseTitle = '';
String licensePath = '';
String licenseContent = '';

//用于即将打开的链接的完整URL
Uri url = Uri.parse("uri");
TextEditingController textUrlController = TextEditingController();

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPage();
  }
}

class _SettingsPage extends State<SettingsPage>{
  bool _showAppBarTitle = false;

  //判断用户是否绑定电表账号
  emBindRead() async {
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

  //保存设置到本地
  saveSettings() async {
    GlobalVars.settingsTotal.clear();
    GlobalVars.settingsTotal.add({
      'fontSize': GlobalVars.fontsizeint,
      'DarkMode': GlobalVars.darkModeint,
      'ThemeColor': GlobalVars.themeColor,
      'showSatCourse': GlobalVars.showSatCourse,
      'showSunCourse': GlobalVars.showSunCourse,
      'courseBlockColorsint': GlobalVars.courseBlockColorsInt,
      'switchTomorrowCourseAfter20': GlobalVars.switchTomorrowCourseAfter20,
      'switchNextWeekCourseAfter20': GlobalVars.switchNextWeekCourseAfter20,
      'showTzgg': GlobalVars.showTzgg,
      'betaDialogShowCount': GlobalVars.betaDialogShowCount,
    });
    if(mounted){
      setState(() {});
    }
    await GlobalVars.globalPrefs.setString('Settings', jsonEncode(GlobalVars.settingsTotal));
  }

  @override
  void initState() {
    emBindRead();
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
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('通用设置',style: TextStyle(fontSize: GlobalVars.dividerTitle,color:Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                              leading: Icon(Icons.format_size, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('字体大小',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text((GlobalVars.fontsizeint == 0)? '极小':(GlobalVars.fontsizeint == 1)? '超小':(GlobalVars.fontsizeint == 2)? '较小':(GlobalVars.fontsizeint == 3)? '适中':(GlobalVars.fontsizeint == 4)? '较大':(GlobalVars.fontsizeint == 5)? '超大':'极大',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                              onTap: (){
                                switchTextSize();
                              },
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('主题颜色',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text((GlobalVars.themeColor == 0)? '琥珀色':(GlobalVars.themeColor == 1)? '深橙色':(GlobalVars.themeColor == 2)? '曼迪红':(GlobalVars.themeColor == 3)? '深紫色':(GlobalVars.themeColor == 4)? '野鸭绿':(GlobalVars.themeColor == 5)? '粉红色':(GlobalVars.themeColor == 6)? '咖啡色':'鲨鱼灰',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                              onTap: (){
                                switchThemeColor();
                              },
                            ),
                            Divider(height: 5,indent: 20,endIndent: 20,),
                            ListTile(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('深色模式',style: TextStyle(fontSize: GlobalVars.listTileTitle),),
                              subtitle: Text((GlobalVars.darkModeint == 0)? '跟随系统':(GlobalVars.darkModeint == 1)? '始终开启':'始终关闭',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary,fontSize: GlobalVars.listTileSubtitle),),
                              onTap: (){
                                switchThemeMode();
                              },
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('首页设置',style: TextStyle(fontSize: GlobalVars.dividerTitle,color:Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                                  saveSettings();
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
                                  saveSettings();
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
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('课表设置',style: TextStyle(fontSize: GlobalVars.dividerTitle,color:Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                                  saveSettings();
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
                                  saveSettings();
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
                                  saveSettings();
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
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('账号设置',style: TextStyle(fontSize: GlobalVars.dividerTitle,color: Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                              leading: Icon(Icons.electric_bolt, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('电费账号', style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text(GlobalVars.emBinded ? '已绑定：${GlobalVars.wechatUserNickname}' : '未绑定',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ElectricmeterbindPage())).then((value) => emBindRead());
                              },
                            ),
                            Divider(height: 1, indent: 20, endIndent: 20),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('退出登录', style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text(GlobalVars.userName,style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.help),
                                        SizedBox(width: 8),
                                        Text('询问：', style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('您确定要退出登录吗？', style: TextStyle(fontSize: GlobalVars.alertdialogContent, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text('退出登录后将会：', style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                        SizedBox(height: 5),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text('解绑电费账号',
                                                style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text('清除字体大小、深色模式等设置',
                                                style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text('删除所有本地保存的数据',
                                                style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('取消'),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: (){
                                          logout();
                                          Navigator.pop(context);
                                        },
                                        child: Text('确定退出'),
                                      ),
                                    ],
                                  ),
                                );    
                              },
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('关于智慧陕理',style: TextStyle(fontSize: GlobalVars.dividerTitle,color:Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                              leading: Icon(Icons.commit_outlined, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('当前版本', 
                                style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text('${GlobalVars.versionCodeString} （${GlobalVars.versionReleaseDate}）', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                            ),
                            Divider(height: 1, indent: 20, endIndent: 20),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('官方网站', 
                                style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text('https://SmartSNUT.cn', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                url = Uri.parse('https://SmartSNUT.cn');
                                launchURL();
                              },
                            ),
                            Divider(height: 1, indent: 20, endIndent: 20),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('Github 开源地址', 
                                style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text('https://github.com/Anya1014CN/SmartSNUTMP', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                url = Uri.parse('https://github.com/Anya1014CN/SmartSNUTMP');
                                launchURL();
                              },
                            ),
                            Divider(height: 1, indent: 20, endIndent: 20),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('Gitee 开源地址', 
                                style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text('https://gitee.com/Anya1014CN/SmartSNUTMP', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                url = Uri.parse('https://gitee.com/Anya1014CN/SmartSNUTMP');
                                launchURL();
                              },
                            ),
                            Divider(height: 1, indent: 20, endIndent: 20),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                              leading: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.chevron_right),
                              title: Text('小程序备案号', 
                                style: TextStyle(fontSize: GlobalVars.listTileTitle)),
                              subtitle: Text('陕ICP备2024023952号-4X', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: GlobalVars.listTileSubtitle)),
                              onTap: () {
                                url = Uri.parse('https://beian.miit.gov.cn/');
                                launchURL();
                              },
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('声明',style: TextStyle(fontSize: GlobalVars.dividerTitle,color: Theme.of(context).colorScheme.primary),),
                        Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
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
                            ExpansionTile(
                              leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                              title: Text('非官方声明', style: TextStyle(fontSize: GlobalVars.listTileTitle, fontWeight: FontWeight.bold)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('智慧陕理并非陕西理工大学官方APP',
                                              style: TextStyle(fontSize: GlobalVars.genericTextSmall)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('智慧陕理APP与陕西理工大学无任何从属关系',
                                              style: TextStyle(fontSize: GlobalVars.genericTextSmall)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text('智慧陕理从未有意标榜或冒充是陕西理工大学官方APP',
                                              style: TextStyle(fontSize: GlobalVars.genericTextSmall)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  //开放源代码许可
  showLicense(BuildContext context) async{
    licenseContent = await rootBundle.loadString('assets/credits/License/$licensePath.txt');
    if(context.mounted){
      showDialog(
        context: context,
        builder:(BuildContext context) => AlertDialog(
          title: Text('$licenseTitle - License',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
          content: Text(licenseContent,style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  //退出登录
  logout() async {
    await GlobalVars.globalPrefs.clear();

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
          content: Text('退出登录成功'),
        ),
      );
    }

    if(mounted){
      Navigator.pushReplacementNamed(context, '/LoginPage');
    }
  }

  //切换字体大小
  switchTextSize() {
    int groupValue = GlobalVars.fontsizeint;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            scrollable: true,
            title: Text('字体大小',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
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
                            GlobalVars.fontsizeint = 0;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('极小',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
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
                            GlobalVars.fontsizeint = 1;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('超小',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 2,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 2;
                        if(mounted){
                          setState((){
                            GlobalVars.fontsizeint = 2;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('较小',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 3,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 3;
                        if(mounted){
                          setState((){
                            GlobalVars.fontsizeint = 3;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('适中',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 4,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 4;
                        if(mounted){
                          setState((){
                            GlobalVars.fontsizeint = 4;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('较大',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 5,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 5;
                        if(mounted){
                          setState((){
                            GlobalVars.fontsizeint = 5;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('超大',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 6,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 6;
                        if(mounted){
                          setState((){
                            GlobalVars.fontsizeint = 6;
                            Modules.setFontSize();
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('极大',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  saveSettings();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  //切换主题颜色
  switchThemeColor() {
    int groupValue = GlobalVars.themeColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            scrollable: true,
            title: Text('主题颜色',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
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
                            GlobalVars.themeColor = 0;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('琥珀色',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFFE65100)),),)
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
                            GlobalVars.themeColor = 1;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('深橙色',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFFBF360C)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 2,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 2;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 2;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('曼迪红',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFFCD5758)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 3,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 3;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 3;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('深紫色',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFF4527A0)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 4,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 4;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 4;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('野鸭绿',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFF2D4421)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 5,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 5;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 5;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('粉红色',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFFBC004B)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 6,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 6;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 6;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('咖啡色',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFF452F2B)),),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 7,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 7;
                        if(mounted){
                          setState((){
                            GlobalVars.themeColor = 7;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('鲨鱼灰',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                    SizedBox(width: 10,),
                    SizedBox(height: 15,width: 15,child: Container(decoration: BoxDecoration(color: Color(0xFF1D2228)),),)
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  saveSettings();
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
  
  //切换主题模式
  switchThemeMode() {
    int groupValue = GlobalVars.darkModeint;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            scrollable: true,
            title: Text('深色模式',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
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
                            GlobalVars.darkModeint = 0;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('跟随系统设置',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
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
                            GlobalVars.darkModeint = 1;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('始终开启',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 2,
                      groupValue: groupValue,
                      onChanged: (value){
                        groupValue = 2;
                        if(mounted){
                          setState((){
                            GlobalVars.darkModeint = 2;
                            GlobalVars.settingsApplied = false;
                          });
                        }
                        saveSettings();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('始终关闭',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  saveSettings();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
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
                        saveSettings();
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
                        saveSettings();
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
                  saveSettings();
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
  
  //打开链接
  void launchURL() async{
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