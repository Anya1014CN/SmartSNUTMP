import 'dart:convert';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:smartsnutmp/MePage/electricMeterBindPage/electricmeterbind_page.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

class Electricmeterpage extends StatefulWidget {
  const Electricmeterpage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ElectricmeterPageState();
  }
}

class _ElectricmeterPageState extends State<Electricmeterpage>{
  bool _showAppBarTitle = false;

  //查询状态相关变量
  bool isQuerying =false;
  bool querySuccess = false;
  List<dynamic> emstatetotal = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      queryem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ElectricmeterbindPage()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Row(
          children: [
            Icon(Icons.link),
            SizedBox(width: 10,),
            Text('账号管理',style: TextStyle(fontSize: GlobalVars.genericFloationActionButtonTitle),)
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
                pinned: true,
                expandedHeight: 0,
                title: _showAppBarTitle ? Text("电费查询") : null,
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
                              ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/electricity.png')
                              : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/electricity.png'),
                            height: 32,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '电费查询',
                          style: TextStyle(
                            fontSize: GlobalVars.genericPageTitle,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // 查询状态显示与电表信息展示
                  isQuerying ?
                  SizedBox() :
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      child: emstatetotal.isEmpty ? 
                        // 无电表数据时显示加载提示
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  "正在加载电表数据...", 
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: GlobalVars.genericTextMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) :
                        // 有电表数据时显示列表
                        Column(
                          children: emstatetotal.map((em) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 电表编号
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '电表编号：${em['userCode']}',
                                          style: TextStyle(
                                            fontSize: GlobalVars.genericTextLarge,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  
                                  // 电表数据卡片
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withAlpha(15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 电表剩余
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.electric_bolt,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '电表剩余：${em['emDetail']['shengyu']}',
                                              style: TextStyle(
                                                fontSize: GlobalVars.genericTextLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        
                                        // 电表累计
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.history,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '电表累计：${em['emDetail']['leiji']}',
                                              style: TextStyle(
                                                fontSize: GlobalVars.genericTextLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        
                                        // 电表状态
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '电表状态：${em['emDetail']['zhuangtai']}',
                                              style: TextStyle(
                                                fontSize: GlobalVars.genericTextLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // 地址信息
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${em['userAddress']}',
                                          style: TextStyle(
                                            fontSize: GlobalVars.genericTextMedium,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 16),
                                  Divider(height: 1),
                                  SizedBox(height: 8),
                                ],
                              ),
                            );
                          }).toList(),
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

  queryem() async {
    GlobalVars.operationCanceled = false;
    if(mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              scrollable: true,
              title: Text('请稍后...',style: TextStyle(fontSize: GlobalVars.alertdialogTitle)),
              content: Column(
                children: [
                  SizedBox(height: 10,),
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text('正在查询...',style: TextStyle(fontSize: GlobalVars.alertdialogContent))
                ],
              ),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    GlobalVars.operationCanceled = true;
                  },
                  child: Text('取消'),
                ),
              ],
            ),
          );
        },
      );
    }

      for(int i = 0;i <= GlobalVars.emNum - 1;i++){
        if(GlobalVars.operationCanceled) return;
        late String electricUserUid;
        //获取电表 id
        if(GlobalVars.globalPrefs.containsKey('emBindData-emDetail')){
          GlobalVars.emDetail = jsonDecode(await GlobalVars.globalPrefs.getString('emBindData-emDetail')!);
          electricUserUid = GlobalVars.emDetail[i]['bindMeterId'];
        }
        String userCode = GlobalVars.emDetail[i]['userCode'];
        String userAddress = GlobalVars.emDetail[i]['userAddress'];

        if(GlobalVars.operationCanceled) return;
        List queryEMResponse = await Modules.queryEM(GlobalVars.wechatUserId, electricUserUid, userCode, userAddress);
        emstatetotal.add(queryEMResponse[0]['emStateTotal'][0]);
        if(queryEMResponse[0]['statue'] == false){
          if(mounted){
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error),
                    SizedBox(width: 8),
                    Text('错误：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle))
                  ],
                ),
                content: Text('查询失败，请稍后再试',style: TextStyle(fontSize: GlobalVars.alertdialogContent)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('确定'),
                  ),
                ],
              ),
            );
            setState(() {
              isQuerying = false;
            });
          }
          return;
        }
      }

      if(mounted){
        if(GlobalVars.operationCanceled) return;
        setState(() {
          isQuerying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('电表数据查询成功'),
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