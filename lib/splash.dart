import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget{
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage>{

  //测试版弹窗
  betaDialog() async {
    if(GlobalVars.globalPrefs.containsKey('Settings')){
      GlobalVars.settingsTotal = jsonDecode(await GlobalVars.globalPrefs.getString('Settings')!);
      GlobalVars.betaDialogShowCount = GlobalVars.settingsTotal[0]['betaDialogShowCount']?? 0;
    }else{
      GlobalVars.betaDialogShowCount = 0;
    }

    if(GlobalVars.betaDialogShowCount < 3){
      GlobalVars.betaDialogShowCount++;
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
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('你好呀~',style: TextStyle(fontSize: GlobalVars.alertdialogTitle),),
            content: Text('欢迎欢迎！！！感谢体验 “智慧陕理” 小程序版\n\n目前小程序版仍处于内测状态，可能存在轻微的卡顿以及稳定性问题，若您有任何意见和建议，请关注 “智慧陕理” 公众号发送反馈、获取更多信息\n\n官方网站：https://smartsnut.cn\n\n此弹窗总共展示 3 次，目前已展示 ${GlobalVars.betaDialogShowCount} 次',style: TextStyle(fontSize: GlobalVars.alertdialogContent),),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    loadPage();
  }

  //根据登录状态加载页面
  loadPage(){
    if(GlobalVars.loginState == 1){
      Navigator.pushReplacementNamed(context, '/LoginPage');
    }if(GlobalVars.loginState == 2){
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //读取登录状态
      if(GlobalVars.globalPrefs.containsKey('LoginSuccess')){
        String loginSuccessValue = GlobalVars.globalPrefs.getString('LoginSuccess')!;
        GlobalVars.loginState = int.parse(loginSuccessValue);
      }else{
        GlobalVars.loginState = 1;
      }
      if(GlobalVars.loginState == 2){
        await Modules.readStdAccount();
        await Modules.readEMInfo();
      }
      await Modules.refreshState();
      betaDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(useNativeCodec('${GlobalVars.cloudAssets}images/logo.png'),width: (MediaQuery.of(context).size.width)*0.3,),
              SizedBox(height: 10,),
              Text('智慧陕理',style: TextStyle(color: Colors.white,fontSize: GlobalVars.splashPageTitle),)
            ],
          ),
        ),
      ),
    );
  }
}