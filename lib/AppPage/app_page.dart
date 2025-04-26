import 'package:mpflutter_core/image/mpflutter_use_native_codec.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

//用于存储外部链接的完整URL
Uri url = Uri.parse("uri");
TextEditingController textUrlController = TextEditingController();

bool loginstate = false;

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppPageState();
  }
}

class _AppPageState extends State<AppPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Modules.refreshState();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              // 问候语区域
              Container(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Text(
                  '${GlobalVars.greeting}，${GlobalVars.realName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: GlobalVars.genericGreetingTitle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // 教务功能标题
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 4,
                      height: 18,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text(
                      '教务功能',
                      style: TextStyle(
                          fontSize: GlobalVars.dividerTitle,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              // 教务功能卡片
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '我的课表',
                                'schedule',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/CourseTablePage');
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '学籍信息',
                                'account',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/StdDetailPage');
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '我的考试',
                                'exam',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/StdExamPage');
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '我的成绩',
                                'grade',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/StdGradesPage');
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '空闲教室查询',
                                'classroom',
                                () {
                                  Navigator.pushNamed(context, '/AppPage/PublicFreePage');
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 后勤功能标题
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 4,
                      height: 18,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text(
                      '后勤功能',
                      style: TextStyle(
                          fontSize: GlobalVars.dividerTitle,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              // 后勤功能卡片
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: buildFunctionButton(
                            context,
                            '网费查询',
                            'web',
                            () {
                              Navigator.pushNamed(context, '/AppPage/SchoolNetworkPage');
                              
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: buildFunctionButton(
                            context,
                            '电费查询',
                            'electricity',
                            () {
                              if(GlobalVars.emBinded == false){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.info),
                                        SizedBox(width: 8),
                                        Text('提示：',style: TextStyle(fontSize: GlobalVars.alertdialogTitle),)
                                      ],
                                    ),
                                    content: Text('您还没有绑定电费账号，\n请先前往 "我的 -> 解/绑电费账号" 绑定后再试',style: TextStyle(fontSize: GlobalVars.alertdialogContent),),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('确定'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }else{
                                Navigator.pushNamed(context, '/AppPage/Electricmeterpage');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 底部间隔
              SizedBox(height: 20),
            ]),
          )
        ],
      ),
    );
  }

  // 功能按钮构建辅助方法
  Widget buildFunctionButton(
      BuildContext context, String title, String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              Theme.of(context).brightness == Brightness.light
                  ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/$iconName.png')
                  : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/$iconName.png'),
              height: 40,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: GlobalVars.genericFunctionsButtonTitle,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
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
}