import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/MePage/electricMeterBindPage/electricmeterbind_page.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget{
  const AccountSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccountSettingsPage();
  }
}

class _AccountSettingsPage extends State<AccountSettingsPage>{
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
                title: _showAppBarTitle ? Text("账号设置") : null,
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
                        Text('账号设置',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
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
                ]),
              )
            ],
          ),
        ),
      ),
    );
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
}