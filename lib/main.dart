import 'package:provider/provider.dart';
import 'package:smartsnutmp/AppPage/app_page.dart' deferred as appPage;
import 'package:smartsnutmp/AppPage/courseTable/coursetable_page.dart';
import 'package:smartsnutmp/AppPage/electricMeter/electricmeter_page.dart';
import 'package:smartsnutmp/AppPage/publicFree/publicfree_page.dart';
import 'package:smartsnutmp/AppPage/schoolNetwork/schoolnetwork_page.dart';
import 'package:smartsnutmp/AppPage/stdDetail/stddetail_page.dart';
import 'package:smartsnutmp/AppPage/stdExam/stdexam_page.dart';
import 'package:smartsnutmp/AppPage/stdGrades/stdgrades_page.dart';
import 'package:smartsnutmp/Home/home.dart' deferred as home;
import 'package:smartsnutmp/LinkPage/link_page.dart' deferred as linkPage;
import 'package:smartsnutmp/MePage/electricMeterBindPage/electricmeterbind_page.dart';
import 'package:smartsnutmp/MePage/guidePage/guide_page.dart';
import 'package:smartsnutmp/MePage/me_page.dart'deferred as mePage;
import 'package:smartsnutmp/MePage/setttingsPage/settings_page.dart';
import 'package:smartsnutmp/function_modules.dart'deferred as function_Modules;
import 'package:smartsnutmp/globalvars.dart';
import 'package:smartsnutmp/login.dart';
import 'package:smartsnutmp/splash.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as mpapi;
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

//页面选择状态
int railselectedIndex = 0;

void main() async {
  await appPage.loadLibrary();
  await home.loadLibrary();
  await linkPage.loadLibrary();
  await mePage.loadLibrary();
  await function_Modules.loadLibrary();
  GlobalVars.globalPrefs = await SharedPreferences.getInstance();
  await function_Modules.Modules.readSettings();
  runMPApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const SmartSNUT(),
    )
  );

  /**
   * 务必保留这段代码，否则第一次调用 wx 接口会提示异常。
   */
  if (kIsMPFlutter) {
    try {
      mpapi.wx.$$context$$;
    } catch (e) {}
  }

  /**
   * 使用 AppDelegate 响应应用生命周期事件、分享事件。
   */
  // ignore: unused_local_variable
  final appDelegate = MyAppDelegate();
}

class MyAppDelegate {
  late MPFlutterWechatAppDelegate appDelegate;

  MyAppDelegate() {
    appDelegate = MPFlutterWechatAppDelegate(
      onShow: () {
        // print("当应用从后台回到前台，被回调。");
      },
      onHide: () {
        // print("当应用从前台切到后台，被回调。");
      },
      onShareAppMessage: (detail) {
        // print("当用户点击分享给朋友时，回调，应组装对应的 Map 信息，用于展示和回跳。");
        return onShareAppMessage(detail);
      },
      onLaunch: (query, launchptions) async {
        // print(launchptions['path']);
        // print("应用冷启动时，会收到回调，应根据 query 决定是否要跳转页面。");
        // await Future.delayed(Duration(seconds: 1)); // 加个延时，保障 navigator 已初始化。
        // onLaunchOrEnter(query);
      },
      onEnter: (query, launchptions) {
        // print("应用热启动（例如用户从分享卡片进入小程序）时，会收到回调，应根据 query 决定是否要跳转页面。");
        // onLaunchOrEnter(query);
      },
    );
  }

  /**
   * 存在两种返回 Share Info 的方法
   * - MPFlutterWechatAppShareManager.onShareAppMessage 配合 MPFlutterWechatAppShareManager.setAppShareInfo 使用
   * - 直接返回符合微信小程序要求的 Map
   */
  Map onShareAppMessage(mpjs.JSObject detail) {
    return MPFlutterWechatAppShareManager.onShareAppMessage(detail);
    // final currentRoute = MPNavigatorObserver.currentRoute;
    // if (currentRoute != null) {
    //   final routeName = currentRoute.settings.name;
    //   return {
    //     "title": (() {
    //       if (routeName == "/map_demo") {
    //         return "Map Demo";
    //       } else {
    //         return "Awesome Project";
    //       }
    //     })(),
    //     "path":
    //         "pages/index/index?routeName=${routeName}", // 这个 query 会在 onLaunch 和 onEnter 中带回来。
    //   };
    // } else {
    //   return {};
    // }
  }

  // void onLaunchOrEnter(Map query) {
  //   final navigator = MPNavigatorObserver.currentRoute?.navigator;
  //   if (navigator != null) {
  //     final routeName = query["routeName"];
  //     if (routeName == "/map_demo") {
  //       navigator.pushNamed("/map_demo");
  //     }
  //   }
  // }
}

class SmartSNUT extends StatefulWidget {
  const SmartSNUT({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SmartSNUTState();
  }
}

class _SmartSNUTState extends State<SmartSNUT>{

  @override
  void initState() {
    super.initState();
    MPFlutterDarkmodeManager.addThemeListener(() {
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '智慧陕理',
          theme: FlexThemeData.light(
            scheme: themeProvider.colorScheme,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              useM2StyleDividerInM3: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              alignedDropdown: true,
              navigationRailUseIndicator: true,
              navigationRailLabelType: NavigationRailLabelType.all,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          ),
          darkTheme: FlexThemeData.dark(
            scheme: themeProvider.colorScheme,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              blendOnColors: true,
              useM2StyleDividerInM3: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              alignedDropdown: true,
              navigationRailUseIndicator: true,
              navigationRailLabelType: NavigationRailLabelType.all,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          ),
          themeMode: themeProvider.themeMode,
          home: SplashPage(),
          routes: {
            '/LoginPage': (context) => LoginPage(),
            '/home': (context) => HomePage(),
            '/appPage': (context) => appPage.AppPage(),
            '/linkPage': (context) => linkPage.LinkPage(),
            '/mePage': (context) => mePage.MePage(),
            // AppPage
            '/AppPage/CourseTablePage': (context) => CourseTablePage(),
            '/AppPage/Electricmeterpage': (context) => Electricmeterpage(),
            '/AppPage/PublicFreePage': (context) => PublicFreePage(),
            '/AppPage/SchoolNetworkPage': (context) => SchoolNetworkPage(),
            '/AppPage/StdDetailPage': (context) => StdDetailPage(),
            '/AppPage/StdExamPage': (context) => StdExamPage(),
            '/AppPage/StdGradesPage': (context) => StdGradesPage(),
            // MePage
            '/MePage/ElectricmeterbindPage': (context) => ElectricmeterbindPage(),
            '/MePage/Guidepage': (context) => Guidepage(),
            '/MePage/SettingsPage': (context) => SettingsPage(),
          },
          /**
           * 务必保留 MPNavigatorObserver，否则小程序的路由会出问题。
           */
          navigatorObservers: [MPNavigatorObserver()],
        );
      } ,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedHomeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      //底部 Tab
      bottomNavigationBar: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.desktop || sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
              return SizedBox(width: 0,height: 0,);
            }
            else{
              return NavigationBar(
                onDestinationSelected: (int index) {
                  if(mounted){
                    setState(() {
                      selectedHomeIndex = index;
                    });
                  }
                },
                indicatorColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                selectedIndex: selectedHomeIndex,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: '首页',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.touch_app_outlined),
                    selectedIcon: Icon(Icons.touch_app),
                    label: '校内应用',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.link_outlined),
                    selectedIcon: Icon(Icons.link),
                    label: '常用链接',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: '我的',
                  ),
                ],
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                height: 70,
                elevation: 3,
                shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(76),
              );
            }
          },
        ),
      body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.desktop || sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
              return Row(
                children: [
                  NavigationRail(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                    selectedIndex: railselectedIndex,
                    onDestinationSelected: (int index) {
                      if(mounted){
                        setState(() {
                          railselectedIndex = index;
                        });
                      }
                    },
                    labelType: NavigationRailLabelType.selected,
                    selectedLabelTextStyle: TextStyle(
                      fontSize: GlobalVars.bottonbarSelectedTitle,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      fontSize: GlobalVars.bottonbarUnselectedTitle,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    leading:sizingInformation.isDesktop? 
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 20, 10),
                      child: Row(
                      children: [
                       Image.network(useNativeCodec('${GlobalVars.cloudAssets}images/logo.png'),width: 60,height: 60,),
                       SizedBox(width: 10,),
                       Text('智慧陕理',style: TextStyle(
                         fontSize: GlobalVars.bottonbarAppnameTitle,
                         fontWeight: FontWeight.bold,
                         color: Theme.of(context).colorScheme.primary,
                       ),)
                        ],
                      ),
                    ):
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Image(image: AssetImage('assets/images/logo.png'),width: 60,height: 60,),
                    ),
                    useIndicator: true,
                    minWidth: 80,
                    minExtendedWidth: 180,
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('首页',style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.touch_app_outlined),
                        selectedIcon: Icon(Icons.touch_app),
                        label: Text('校内应用',style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.link_outlined),
                        selectedIcon: Icon(Icons.link),
                        label: Text('常用链接',style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('我的',style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      ),
                    ],
                  ),
                  <Widget>[
                    Expanded(child: home.Home(),),
                    Expanded(child: appPage.AppPage(),),
                    Expanded(child: linkPage.LinkPage(),),
                    Expanded(child: mePage.MePage(),),
                  ][railselectedIndex],
                ],
              );
            }
            else{
              return <Widget>[
                home.Home(),
                appPage.AppPage(),
                linkPage.LinkPage(),
                mePage.MePage(),
              ][selectedHomeIndex];
            }
          },
        )
    );
  }
}

// 主题管理类
class ThemeProvider extends ChangeNotifier {
  int _themeColor = GlobalVars.themeColor;
  int _darkModeInt = GlobalVars.darkModeint;
  
  ThemeMode get themeMode {
    if (_darkModeInt == 0) {
      return MPFlutterDarkmodeManager.isDarkmode() ? ThemeMode.dark : ThemeMode.light;
    } else {
      return _darkModeInt == 1 ? ThemeMode.dark : ThemeMode.light;
    }
  }
  
  FlexScheme get colorScheme {
    switch (_themeColor) {
      case 0: return FlexScheme.amber;
      case 1: return FlexScheme.deepOrangeM3;
      case 2: return FlexScheme.mandyRed;
      case 3: return FlexScheme.deepBlue;
      case 4: return FlexScheme.mallardGreen;
      case 5: return FlexScheme.pinkM3;
      case 6: return FlexScheme.espresso;
      case 7: return FlexScheme.shark;
      default: return FlexScheme.amber;
    }
  }
  
  void updateSettings() {
    if (_themeColor != GlobalVars.themeColor || _darkModeInt != GlobalVars.darkModeint) {
      _themeColor = GlobalVars.themeColor;
      _darkModeInt = GlobalVars.darkModeint;
      notifyListeners();
    }
  }
}