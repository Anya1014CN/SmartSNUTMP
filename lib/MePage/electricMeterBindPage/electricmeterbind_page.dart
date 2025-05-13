import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

//文本输入框
TextEditingController textEmIdController = TextEditingController();
TextEditingController textBindLinkController = TextEditingController();

//用于存储外部链接的完整URL
Uri url = Uri.parse("uri");

bool isQuerying = false;

//判断绑定状态
bool isBinding = false;

//用于存储即将解绑的电表 id
String unbindEmId = '';

class ElectricmeterbindPage extends StatefulWidget{
  const ElectricmeterbindPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ElectricmeterbindPageState();
  }
}

class _ElectricmeterbindPageState extends State<ElectricmeterbindPage>{
  TextEditingController textUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        leading: isBinding ? null : IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              // 标题部分
              Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
                child: Row(
                  children: [
                    Image.network(
                      Theme.of(context).brightness == Brightness.light 
                        ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/electricitybind.png')
                        : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/electricitybind.png'),
                      height: 40,
                    ),
                    SizedBox(width: 12,),
                    Flexible(
                      child: Text(
                        '解/绑电费账号',
                        style: TextStyle(
                          fontSize: GlobalVars.genericPageTitle,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),
              ),
              
              // 用户信息卡片
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Card(
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GlobalVars.emBinded
                    ? Container(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  child: Image.network(useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/account.png'))
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        GlobalVars.wechatUserNickname,
                                        style: TextStyle(
                                          fontSize: GlobalVars.genericTextLarge,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '电表数量：${GlobalVars.emNum}',
                                        style: TextStyle(
                                          fontSize: GlobalVars.genericTextLarge,
                                          color: Theme.of(context).colorScheme.secondary
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(20),
                        child: MPFlutterTextField(
                          controller: textBindLinkController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: '在此粘贴绑定链接',
                            prefixIcon: Icon(Icons.commit),
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                        ),
                      ),
                ),
              ),
              
              // 操作按钮区域
              GlobalVars.emBinded
                ? Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                            color: Theme.of(context).colorScheme.surfaceDim,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isQuerying 
                                ? null
                                : () {
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
                                        content: Text('您确定要刷新数据吗', style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              bindelectricmeter();
                                            },
                                            child: Text('确定'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  '刷新数据',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                            color: Theme.of(context).colorScheme.primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isQuerying
                                ? null
                                : () {
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
                                        content: Text('您确定要解绑账号吗', style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              unBindEMAccount();
                                            },
                                            child: Text('确定'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  '解绑账号',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimary
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                            color: Theme.of(context).colorScheme.surfaceDim,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                url = Uri.parse('https://smartsnut.cn/Docs/UserManual/EMBindGuide.html');
                                launchURL();
                              },
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  '如何绑定',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                            color: Theme.of(context).colorScheme.primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if(textBindLinkController.text == '') {
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
                                      content: Text('请先输入您的 openId', style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('确定'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  GlobalVars.openId = textBindLinkController.text;
                                  bindelectricmeter();
                                }
                              },
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  '绑定账号',
                                  style: TextStyle(
                                    fontSize: GlobalVars.genericTextLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimary
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

              //电表详情区域
              GlobalVars.emBinded? 
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Card(
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '电表列表',
                            style: TextStyle(
                              fontSize: GlobalVars.genericTextLarge,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        ),
                        (GlobalVars.emDetail.isEmpty)?
                        Center(
                          child: Column(
                          children: [
                            Icon(Icons.priority_high, color: Theme.of(context).colorScheme.primary, size: 40),
                            SizedBox(height: 16),
                            Text('您还未绑定电表哦~', style: TextStyle(fontSize: GlobalVars.genericTextMedium, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            SizedBox(height: 16),
                          ],
                        ),
                        ):
                        Column(
                          children: GlobalVars.emDetail.map((emDetailSingal) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emDetailSingal['bindMeterCode'].toString(),
                                            style: TextStyle(
                                              fontSize: GlobalVars.genericTextMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            emDetailSingal['userAddress'].toString(),
                                            style: TextStyle(
                                              fontSize: GlobalVars.genericTextSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.link_off, size: 24),
                                        onPressed: () {
                                          if(mounted){
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
                                                content: Text('您确定要解绑电表吗？', style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('取消'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      unbindEmId = emDetailSingal['bindId'].toString();
                                                      unBindEM();
                                                    },
                                                    child: Text('确定'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Divider(height: 0, indent: 16, endIndent: 16),
                              ],
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10,),
                        (GlobalVars.emDetail.isEmpty)? Divider(height: 16, indent: 16, endIndent: 16):SizedBox(height: 0),
                        SizedBox(height: 10,),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(double.infinity, 50), // 确保按钮宽度填满父容器
                          ),
                          onPressed: () {
                            bindEM();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '绑定电表',
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
                ),
              ):SizedBox(height: 0),
              
              // 服务说明
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '服务说明',
                            style: TextStyle(
                              fontSize: GlobalVars.genericTextLarge,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '1. 电费账号与陕西理工大学统一身份认证账号相互独立\n登录/退出陕西理工大学统一身份认证账号不会影响电费账号\n绑定电费账号不会关联到陕西理工大学统一身份认证账号',
                            style: TextStyle(
                              fontSize: GlobalVars.genericTextMedium,
                              height: 1.5
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '2. 如果您在绑定电费账号之后在陕西理工大学后勤保障部公众号进行了绑定/解绑用户（电表）操作，请务必点击上方的"刷新数据"按钮，否则可能会导致"电表查询"功能出现电表列表不准确的情况',
                            style: TextStyle(
                              fontSize: GlobalVars.genericTextMedium,
                              height: 1.5
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          )
        ],
      )
    );
  }

  // 绑定电表账号
  bindelectricmeter() async {
    bool bindelectricmeterCanceled = false;
    if(mounted){
      setState(() {
        isBinding = true;
      });
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          scrollable: true,
          title: Text('请稍后...', style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
          content: Column(
            children: [
              SizedBox(height: 10,),
              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text('正在绑定...',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                bindelectricmeterCanceled = true;
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
          ],
        ),
      );
    }

 
     // 解析用户输入的链接
     if(textBindLinkController.text != ''){
       try{
         String url = textBindLinkController.text;
         String? parseOpenId;
         
         // 处理带有#/的URL情况
         if(url.contains('#/?')) {
           // 提取#/?后面的部分
           int startIndex = url.indexOf('#/?') + 3;
           String fragmentParams = url.substring(startIndex);
           
           // 解析这部分内容作为查询参数
           Map<String, String> params = {};
           if(fragmentParams.contains('&')) {
             // 多个参数的情况
             List<String> pairs = fragmentParams.split('&');
             for(String pair in pairs) {
               List<String> keyValue = pair.split('=');
               if(keyValue.length == 2) {
                 params[keyValue[0]] = keyValue[1];
               }
             }
           } else if(fragmentParams.contains('=')) {
             // 单个参数的情况
             List<String> keyValue = fragmentParams.split('=');
             if(keyValue.length == 2) {
               params[keyValue[0]] = keyValue[1];
             }
           }
           
           parseOpenId = params['openId'];
         } else {
           // 常规URL处理
           Uri hquri = Uri.parse(url);
           parseOpenId = hquri.queryParameters['openId'];
         }
         
         if(parseOpenId == null){
           if(mounted) {
             Navigator.pop(context);
             showDialog(
               context: context, 
               builder: (BuildContext context)=>AlertDialog(
                 title: Row(
                   children: [
                     Icon(Icons.error),
                     SizedBox(width: 8),
                     Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
                   ],
                 ),
                 content: Text('无法解析链接，请确保您粘贴的链接无误！',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                 actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
               )
             );
           }
           return;
         }
         GlobalVars.openId = parseOpenId;
       }catch(e){
         if(mounted) {
           Navigator.pop(context);
           showDialog(
             context: context, 
             builder: (BuildContext context)=>AlertDialog(
               title: Row(
                 children: [
                   Icon(Icons.error),
                   SizedBox(width: 8),
                   Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
                 ],
               ),
               content: Text('无法解析链接，请确保您粘贴的链接无误！',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
               actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
             )
           );
         }
         return;
       }
     }

    if(bindelectricmeterCanceled) return;
    List bindEMAccountResponse = await Modules.bindEMAccount(GlobalVars.openId);
    if(bindEMAccountResponse[0]['statue'] == false){
      if(mounted){
        Navigator.pop(context);
        showDialog(
          context: context, 
          builder: (BuildContext context)=>AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error),
                SizedBox(width: 8),
                Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
              ],
            ),
            content: Text(bindEMAccountResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
          ));
      }
      return;
    }

    //保存电表账号信息
    List emUserData = [];
    emUserData.add({
      'emNum': bindEMAccountResponse[0]['emDetail'].length,
      'openId': bindEMAccountResponse[0]['openId'],
      'wechatId': bindEMAccountResponse[0]['wechatId'],
      'wechatUserNickname': bindEMAccountResponse[0]['wechatUserNickname'],
    });
    await GlobalVars.globalPrefs.setString('emBindData-emUserData', jsonEncode(emUserData));

    //保存电表列表
    await GlobalVars.globalPrefs.setString('emBindData-emDetail', jsonEncode(bindEMAccountResponse[0]['emDetail']));

    if(mounted){
      await Modules.readEMInfo();
      setState(() {
        GlobalVars.emBinded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('电费账号数据获取成功'),
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

  //解绑电表账号
  unBindEMAccount() async {
    if(mounted){
      setState(() {
        isBinding = true;
      });
    }

    GlobalVars.globalPrefs.remove('emBindData-emUserData');
    GlobalVars.globalPrefs.remove('emBindData-emDetail');

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('电费账号解绑成功'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      setState(() {
        isBinding = false;
        GlobalVars.emBinded = false;
      });
    }
  }

  //绑定电表
  bindEM() async {
    bool bindEMCanceled = false;
    String meterId = '';
    textEmIdController.clear();
    
    if(mounted){
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: Text('请输入电表编号：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Column(
                children: [
                  SizedBox(height: 16),
                  MPFlutterTextField(
                    controller: textEmIdController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: '电表编号',
                      prefixIcon: Icon(Icons.commit),
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    bindEMCanceled = true;
                    Navigator.pop(context);
                  },
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if(textEmIdController.text == '') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.info),
                              SizedBox(width: 8),
                              Text('提示：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
                            ],
                          ),
                          content: Text('请先输入电表编号',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('确定'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    meterId = textEmIdController.text;
                    Navigator.pop(context);
                  },
                  child: Text('确定'),
                ),
              ],
            ),
          );
        },
      );
    }
    
    if(bindEMCanceled) return;
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
                  Text('正在绑定...',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    bindEMCanceled = true;
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

    if(bindEMCanceled) return;
    List bindEMResponse = await Modules.bindEM(meterId, GlobalVars.wechatUserId);
    if(bindEMResponse[0]['statue'] == false){
      if(mounted){
        Navigator.pop(context);
        showDialog(
          context: context, 
          builder: (BuildContext context)=>AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error),
                SizedBox(width: 8),
                Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
              ],
            ),
            content: Text(bindEMResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
          ));
      }
      return;
    }
    Navigator.pop(context);
    if(bindEMCanceled) return;
    await bindelectricmeter();
    if(mounted) setState(() {});
  }

  //解绑电表
  unBindEM() async {
    bool unBindEMCanceled = false;
    
    if(mounted){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: Text('正在解绑...',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Column(
                children: [
                  SizedBox(height: 10,),
                  CircularProgressIndicator(),
                  SizedBox(height: 10,)
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    unBindEMCanceled = true;
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

    if(unBindEMCanceled) return;
    List unBindEMResponse = await Modules.unBindEM(unbindEmId, GlobalVars.wechatUserId);
    if(unBindEMResponse[0]['statue'] == false){
      if(mounted){
        Navigator.pop(context);
        showDialog(
          context: context, 
          builder: (BuildContext context)=>AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error),
                SizedBox(width: 8),
                Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
              ],
            ),
            content: Text(unBindEMResponse[0]['message'],style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('确定'))],
          ));
      }
      return;
    }
    Navigator.pop(context);
    if(unBindEMCanceled) return;
    await bindelectricmeter();
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