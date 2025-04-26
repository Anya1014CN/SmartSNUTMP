import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
import 'package:smartsnutmp/globalvars.dart';
import 'package:flutter/material.dart';

//功能说明
String describeTitle = '';
String describePath = '';
String describeContent = '';

//用于即将打开的链接的完整URL
Uri url = Uri.parse("uri");
TextEditingController textUrlController = TextEditingController();

class Guidepage extends StatefulWidget{
  const Guidepage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return _GuidePageState();
  }
}

class _GuidePageState extends State<Guidepage>{
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
                title: _showAppBarTitle ? Text("教程&说明") : null,
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  // 标题区域
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
                    child: Row(
                      children: [
                        Image.network(
                          Theme.of(context).brightness == Brightness.light
                              ? useNativeCodec('${GlobalVars.cloudAssets}icons/lighttheme/guide.png')
                              : useNativeCodec('${GlobalVars.cloudAssets}icons/darktheme/guide.png'),
                          height: 40,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '教程&说明',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // 使用说明标题区
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
                          '使用说明',
                          style: TextStyle(
                            fontSize: GlobalVars.dividerTitle,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 使用说明卡片
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            '电费账号绑定教程',
                            style: TextStyle(
                              fontSize: GlobalVars.listTileTitle,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: (){
                            url = Uri.parse('https://smartsnut.cn/Docs/UserManual/EMBindGuide.html');
                            launchURL();
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // 功能说明标题区
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
                          '功能说明',
                          style: TextStyle(
                            fontSize: GlobalVars.dividerTitle,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 功能说明卡片
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Theme.of(context).colorScheme.surfaceDim,
                      shadowColor: Theme.of(context).colorScheme.onPrimary.withAlpha(77),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            buildGuideItem(
                              context, 
                              '我的课表',
                              'https://smartsnut.cn/Docs/UserManual/Functions/JiaoWu/CourseTableForStd.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '学籍信息',
                              'https://smartsnut.cn/Docs/UserManual/Functions/JiaoWu/StdDetail.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '我的考试',
                              'https://smartsnut.cn/Docs/UserManual/Functions/JiaoWu/StdExam.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '我的成绩',
                              'https://smartsnut.cn/Docs/UserManual/Functions/JiaoWu/StdExam.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '绩点计算器',
                              'https://smartsnut.cn/Docs/UserManual/Functions/JiaoWu/GPACalculator.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '网费查询',
                              'https://smartsnut.cn/Docs/UserManual/Functions/HouQin/SchoolNetworkQuery.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '电费查询',
                              'https://smartsnut.cn/Docs/UserManual/Functions/HouQin/ElectricMeterQuery.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '图书检索',
                              'http://smartsnut.cn/Docs/UserManual/Functions/ExternalLink/Library.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '人脸信息采集系统',
                              'http://smartsnut.cn/Docs/UserManual/Functions/ExternalLink/Face.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              'WebVPN',
                              'http://smartsnut.cn/Docs/UserManual/Functions/ExternalLink/WebVPN.html'
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            buildGuideItem(
                              context, 
                              '一网通办',
                              'http://smartsnut.cn/Docs/UserManual/Functions/ExternalLink/NewHall.html'
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 底部空间
                  SizedBox(height: 20),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  // 辅助方法：构建指南项目
  Widget buildGuideItem(BuildContext context, String title, String urlString) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontSize: GlobalVars.listTileTitle,
          fontWeight: FontWeight.bold
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onTap: (){
        url = Uri.parse(urlString);
        launchURL();
      },
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