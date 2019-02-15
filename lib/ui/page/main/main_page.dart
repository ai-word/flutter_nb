import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nb/constants/constants.dart';
import 'package:flutter_nb/ui/page/main/found_page.dart';
import 'package:flutter_nb/ui/page/main/friends_page.dart';
import 'package:flutter_nb/ui/page/login_page.dart';
import 'package:flutter_nb/ui/page/main/message_page.dart';
import 'package:flutter_nb/ui/page/main/mine_page.dart';
import 'package:flutter_nb/ui/widget/loading_widget.dart';
import 'package:flutter_nb/utils/dialog_util.dart';
import 'package:flutter_nb/utils/file_util.dart';
import 'package:flutter_nb/utils/interact_vative.dart';
import 'package:flutter_nb/utils/sp_util.dart';

/*
*  主页
*/
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'FlutterDemo'),
        routes: {
          '/LoginPage': (ctx) => LoginPage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription _subscription = null;
  Operation operation = new Operation();

  int _tabIndex = 0;
  var tabImages;
  var appBarTitles = ['消息', '朋友', '发现', '我的'];
  /*
   * 存放4个页面，跟fragmentList一样
   */
  var _pageList;

  /*
   * 根据选择获得对应的normal或是press的icon
   */
  Image getTabIcon(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImages[curIndex][1];
    }
    return tabImages[curIndex][0];
  }

  /*
   * 获取bottomTab的颜色和文字
   */
  Text getTabTitle(int curIndex) {
    if (curIndex == _tabIndex) {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(fontSize: 13.0, color: const Color(0xff1495eb)));
    } else {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(fontSize: 13.0, color: const Color(0xff929292)));
    }
  }

  /*
   * 根据image路径获取图片
   */
  Image getTabImage(path) {
    return new Image.asset(path, width: 22.0, height: 22.0);
  }

  void initData() {
    /*
     * 初始化选中和未选中的icon
     */
    tabImages = [
      [
        getTabImage(
            FileUtil.getImagePath('message', dir: 'main_page', format: 'png')),
        getTabImage(
            FileUtil.getImagePath('message_c', dir: 'main_page', format: 'png'))
      ],
      [
        getTabImage(
            FileUtil.getImagePath('friends', dir: 'main_page', format: 'png')),
        getTabImage(
            FileUtil.getImagePath('friends_c', dir: 'main_page', format: 'png'))
      ],
      [
        getTabImage(
            FileUtil.getImagePath('more', dir: 'main_page', format: 'png')),
        getTabImage(
            FileUtil.getImagePath('more_c', dir: 'main_page', format: 'png'))
      ],
      [
        getTabImage(
            FileUtil.getImagePath('mine', dir: 'main_page', format: 'png')),
        getTabImage(
            FileUtil.getImagePath('mine_c', dir: 'main_page', format: 'png'))
      ]
    ];
    /*
     * 4个子界面
     */
    _pageList = [
      new MessagePage(operation: operation, rootContext: context),
      new FriendsPage(operation: operation, rootContext: context),
      new FoundPage(operation: operation, rootContext: context),
      new MinePage(operation: operation, rootContext: context)
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    _addConnectionListener(); //添加监听
  }

  @override
  Widget build(BuildContext context) {
    return new LoadingScaffold(
        //使用有Loading的widget
        operation: operation,
        isShowLoadingAtNow: false,
        child: new WillPopScope(
          onWillPop: () {
            _backPress(); //物理返回键，返回到桌面
          },
          child: Scaffold(
              body: _pageList[_tabIndex],
              bottomNavigationBar: new BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  new BottomNavigationBarItem(
                      icon: getTabIcon(0), title: getTabTitle(0)),
                  new BottomNavigationBarItem(
                      icon: getTabIcon(1), title: getTabTitle(1)),
                  new BottomNavigationBarItem(
                      icon: getTabIcon(2), title: getTabTitle(2)),
                  new BottomNavigationBarItem(
                      icon: getTabIcon(3), title: getTabTitle(3)),
                ],
                type: BottomNavigationBarType.fixed,
                //默认选中首页
                currentIndex: _tabIndex,
                iconSize: 22.0,
                //点击事件
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
              )),
        ));
  }

  _backPress() {
    InteractNative.goNativeWithValue(InteractNative.methodNames['backPress']);
  }

  _addConnectionListener() {
    if (null == _subscription) {
      _subscription = InteractNative.dealNativeWithValue()
          .listen(_onEvent, onError: _onError);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  void _onEvent(Object event) {
    if ('onConnected' == event) {
      //已连接
//        DialogUtil.buildToast('已连接');
    } else if ('user_removed' == event) {
      //显示帐号已经被移除
      DialogUtil.buildToast('帐号已经被移除');
    } else if ('user_login_another_device' == event) {
      //显示帐号在其他设备登录
      DialogUtil.buildToast('帐号在其他设备登录');
      SPUtil.putBool(Constants.KEY_LOGIN, false);
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    } else if ('disconnected_to_service' == event) {
      //连接不到聊天服务器
      DialogUtil.buildToast('连接不到聊天服务器');
    } else if ('no_net' == event) {
      //当前网络不可用，请检查网络设置
      DialogUtil.buildToast('当前网络不可用，请检查网络设置');
    }
  }

  void _onError(Object error) {
    DialogUtil.buildToast(error.toString());
  }
}
