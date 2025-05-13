import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/function_modules.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

//用于存储外部链接的完整URL
Uri url = Uri.parse("uri");

bool loginstate = false;

class LinkPage extends StatefulWidget {
  const LinkPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LinkPageState();
  }
}

class _LinkPageState extends State<LinkPage> {
  TextEditingController textUrlController = TextEditingController();
  
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
              // 校内链接标题
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
                      '校内链接',
                      style: TextStyle(
                          fontSize: GlobalVars.dividerTitle,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              // 校内链接卡片
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
                                '图书检索',
                                'library',
                                () {
                                  url = Uri.parse('https://findsnut.libsp.com/');
                                  launchURL();
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '人脸信息采集系统',
                                'face',
                                () {
                                  url = Uri.parse(
                                      'https://faceid.snut.edu.cn/cflms-opencas/cas/v1/collection/');
                                  launchURL();
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
                                'WebVPN',
                                'vpn',
                                () {
                                  url = Uri.parse('https://sec.snut.edu.cn/');
                                  launchURL();
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '一网通办',
                                'museum',
                                () {
                                  url = Uri.parse('https://newehall.snut.edu.cn/');
                                  launchURL();
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
                                '南区全景',
                                'city',
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      scrollable: true,
                                      title: Row(
                                        children: [
                                          Icon(Icons.info),
                                          SizedBox(width: 8,),
                                          Text('提示：',
                                          style: TextStyle(
                                              fontSize: GlobalVars.alertdialogTitle))
                                        ],
                                      ),
                                      content: Text(
                                          '此页面可能包含背景音乐\n如果您正在公共场所，请注意控制设备声音',
                                          style: TextStyle(
                                              fontSize: GlobalVars.alertdialogTitle)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            url = Uri.parse(
                                                'http://720yun.com/t/728jOreO5n0?scene_id=2641644');
                                            launchURL();
                                          },
                                          child: Text('确定'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '北区全景',
                                'mountain-city',
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      scrollable: true,
                                      title: Row(
                                        children: [
                                          Icon(Icons.info),
                                          SizedBox(width: 8,),
                                          Text('提示：',
                                          style: TextStyle(
                                              fontSize: GlobalVars.alertdialogTitle))
                                        ],
                                      ),
                                      content: Text(
                                          '此页面可能包含背景音乐\n如果您正在公共场所，请注意控制设备声音',
                                          style: TextStyle(
                                              fontSize: GlobalVars.alertdialogTitle)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            url = Uri.parse(
                                                'http://720yun.com/t/271jO0uyOv2?scene_id=2712476');
                                            launchURL();
                                          },
                                          child: Text('确定'),
                                        ),
                                      ],
                                    ),
                                  );
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
                                '陕西理工大学校报',
                                'newspaper',
                                () {
                                  url = Uri.parse('https://sxlgxyb.ihwrm.com/?userId=1859970247021375490&tag=wzxy&school=%E9%99%95%E8%A5%BF%E7%90%86%E5%B7%A5%E5%A4%A7%E5%AD%A6');
                                  launchURL();
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
              SizedBox(height: 10),

              //考证链接标题
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
                      '考证链接',
                      style: TextStyle(
                          fontSize: GlobalVars.dividerTitle,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              //考证链接卡片
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
                                '英语四、六级考试',
                                'english',
                                () {
                                  url = Uri.parse('https://cet-bm.neea.edu.cn/');
                                  launchURL();
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '教师资格考试',
                                'teacher',
                                () {
                                  url = Uri.parse('https://ntce.neea.edu.cn/');
                                  launchURL();
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
                                '计算机等级考试',
                                'computer',
                                () {
                                  url = Uri.parse('https://ncre.neea.edu.cn/');
                                  launchURL();
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: buildFunctionButton(
                                context,
                                '普通话水平测试',
                                'speak',
                                () {
                                  url = Uri.parse('https://bm.cltt.org/');
                                  launchURL();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // 底部间隔
              SizedBox(height: 20),
            ]),
          ),
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