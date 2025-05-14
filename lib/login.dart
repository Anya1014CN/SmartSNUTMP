import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mpflutter_core/image/mpflutter_use_native_codec.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

//用于存储要打开的URL
Uri url = Uri.parse("uri");

class LoginPage extends StatefulWidget{
  const LoginPage ({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>{
  
  //创建 TextEditingController
  final textUsernameController = TextEditingController();
  final textPasswordController = TextEditingController();
  final textCaptchaController = TextEditingController();
  final textUrlController = TextEditingController();

  @override
  void initState() {
    Modules.readSettings();
    super.initState();
  }

  Widget _buildCardContent() {
    return Column(
      children: [
        Text('请使用陕西理工大学统一身份认证平台的账号登录',style: TextStyle(fontSize: GlobalVars.genericTextSmall),),
        SizedBox(height: 10),
        Divider(height: 15,indent: 20,endIndent: 20,),
        SizedBox(height: 10),
        MPFlutterTextField(
          controller: textUsernameController,
          decoration: InputDecoration(
            labelText: '用户名',
            hintText: '请在此输入您的学号/工号',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 10),
        MPFlutterTextField(
          controller: textPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '密码',
            hintText: '请在此输入您的统一身份认证平台的密码',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50), // 确保按钮宽度填满父容器
                ),
                onPressed: () {
                  if (textUsernameController.text == '' ) {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context)=>AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 8,),
                            Text('提示：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
                          ],
                        ),
                        content: Text('用户名不能为空，请输入您的学号/工号',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
                      ));
                    return;
                  }if (textPasswordController.text == '') {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context)=>AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 8,),
                            Text('提示：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
                          ],
                        ),
                        content: Text('密码不能为空，请输入您的密码',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
                      ));
                    return;
                  }else{
                    if(textUsernameController.text == 'miniprogramTest' && textPasswordController.text == 'miniprogramTest0000'){
                      loginTestAccount();
                      return;
                    }
                    loginAuth();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '登录智慧陕理',
                      style: TextStyle(
                        fontSize: GlobalVars.genericTextMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Divider(height: 15,indent: 20,endIndent: 20,),
        SizedBox(height: 10),
        Text('如忘记密码，请点击下方按钮进行找回',style: TextStyle(fontSize: GlobalVars.genericTextSmall),),
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: [
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50), // 确保按钮宽度填满父容器
                ),
                onPressed: () {
                  url = Uri.parse('https://authserver.snut.edu.cn/retrieve-password/retrievePassword/index.html');
                  launchURL();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '忘记密码？',
                      style: TextStyle(
                        fontSize: GlobalVars.genericTextMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Container(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 30),
                  child: Row(
                    children: [
                      Image.network(Theme.of(context).brightness == Brightness.light? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/hand.png'):useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/hand.png'),height: 40,),
                      SizedBox(width: 12,),
                      Text('欢迎',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('登录智慧陕理',style: TextStyle(fontSize: GlobalVars.genericTextMedium,color: Theme.of(context).colorScheme.primary),),
                      Divider(height: 5,indent: 20,endIndent: 20,color: Theme.of(context).colorScheme.primary,),
                    ],
                  ),
                ),
                Container(
                  padding:EdgeInsets.fromLTRB(15, 20, 15, 10),
                  child: ScreenTypeLayout.builder(
                    mobile: (BuildContext context) => Card(
                      shadowColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.surfaceDim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 30, 0, MediaQuery.of(context).size.width / 30, 10), // 手机端边距
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: _buildCardContent(),
                      ),
                    ),
                    desktop: (BuildContext context) => Card(
                      shadowColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.surfaceDim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 10, MediaQuery.of(context).size.width / 5, 10), // 手机端边距
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: _buildCardContent(),
                      ),
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
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

  //测试账号
  loginTestAccount() async {
    GlobalVars.operationCanceled = false;
    GlobalVars.loadingHint = '正在加载...';
    if(mounted){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: Text('模拟登录（测试账号）...',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
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

    await Future.delayed(Duration(seconds: 2), () {});

    String userName = textUsernameController.text;
    String passWord = textPasswordController.text;

    GlobalVars.loadingHint = '正在登录...';

    //保存账号密码
    List stdAccount = [];
    stdAccount.add({
      'UserName': userName,
      'PassWord': passWord,
    });
    await GlobalVars.globalPrefs.setString('stdAccount', jsonEncode(stdAccount));

    //获取并保存模拟学籍信息
    await GlobalVars.globalPrefs.setString('stdDetail', await rootBundle.loadString('assets/emulateAccount/stdDetail.json'));

    //添加登录成功的标记
    await GlobalVars.globalPrefs.setString('LoginSuccess', '2');

    if(mounted){
      await Modules.readStdAccount();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录成功'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  //从 authserver 登录
  loginAuth() async {
    GlobalVars.operationCanceled = false;
    GlobalVars.loadingHint = '正在加载...';
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
    String userName = textUsernameController.text;
    String passWord = textPasswordController.text;

    GlobalVars.loadingHint = '正在登录...';
    List loginAuthResponse = await Modules.loginAuth(userName, passWord,'jwgl');
    if(loginAuthResponse[0]['statue'] == false){
      if(mounted){
        Navigator.pop(context);
        showDialog(
          context: context, 
          builder: (BuildContext context)=>AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error),
                SizedBox(width: 8,),
                Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
              ],
            ),
            content: Text(loginAuthResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
          ));
      }
      return;
    }

    //保存账号密码
    List stdAccount = [];
    stdAccount.add({
      'UserName': userName,
      'PassWord': passWord,
    });
    await GlobalVars.globalPrefs.setString('stdAccount', jsonEncode(stdAccount));

    //保存学籍信息
    await GlobalVars.globalPrefs.setString('stdDetail', jsonEncode(loginAuthResponse[0]['stdDetail']));

    //保存学期信息
    await GlobalVars.globalPrefs.setString('semestersData', jsonEncode(loginAuthResponse[0]['semestersData']));

    //更新课表刷新时间（不刷新课表）
    GlobalVars.lastCourseTableRefreshTime = DateTime.now().millisecondsSinceEpoch;
    await Modules.saveSettings(context);

    //添加登录成功的标记
    await GlobalVars.globalPrefs.setString('LoginSuccess', '2');

    if(mounted){
      await Modules.readStdAccount();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录成功'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}