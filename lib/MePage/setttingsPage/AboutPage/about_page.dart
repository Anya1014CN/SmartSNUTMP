import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';
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

class AboutPage extends StatefulWidget{
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AboutPage();
  }
}

class _AboutPage extends State<AboutPage>{
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
                title: _showAppBarTitle ? Text("关于智慧陕理") : null,
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
                        Text('关于智慧陕理',style: TextStyle(fontSize: GlobalVars.genericPageTitle),)
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