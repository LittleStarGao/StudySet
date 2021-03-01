import 'package:flutter/material.dart';

//import 'package:two_user_frineds/pages/common/web_view_page.dart';
import 'package:two_user_frineds/util/struct/router.dart';

/// app 协议头
const String appScheme = "two_user_frineds";

/// 路由配置信息
/// widget 为组件
/// entranceIndex 为首页位置，如果非首页则为-1
/// params 为组件需要的参数数组
const Map<String, StructRouter> routerMapping = {
  //'homepage': StructRouter(HomePageIndex(), 0, null, true),
};

/// 处理APP内的跳转
class Router {
  /// 执行页面跳转
  ///
  /// 需要特别注意以下逻辑
  /// -1 不在首页，则执行跳转
  /// 大于 -1 则为首页，需要在首页进行 tab 切换，而不是进行跳转
  int open(BuildContext context, String url, [String title]) {
    // 非entrance入口标识
    int notEntrancePageIndex = -1;

    if (url.startsWith('https://') || url.startsWith('http://')) {
      // 打开网页
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        //return CommonWebViewPage(url: url); // 请注意，打开这部分注释，需要在 pubspec.yaml 中增加 flutter_webview_plugin 库的依赖，不然会报错，同时打开上面 import 的注释即可使用，具体请查看 pages/common/web_view_page.dart 文件
      }));
      return notEntrancePageIndex;
    }
    Map<String, dynamic> urlParseRet = _parseUrl(url);

    if (routerMapping[urlParseRet['action']] == null) {
      // 处理未找到的路由
      return notEntrancePageIndex;
    }

    int entranceIndex = routerMapping[urlParseRet['action']].entranceIndex;
    if (entranceIndex > notEntrancePageIndex) {
      // 判断为首页，返回切换的tab信息
      return entranceIndex;
    }

    Navigator.pushNamedAndRemoveUntil(context, urlParseRet['action'].toString(),
        (route) {
      if (route.settings.name == urlParseRet['action'].toString()) {
        return false;
      }
      return true;
    }, arguments: urlParseRet['params']);
    // 执行跳转，非首页
    return notEntrancePageIndex;
  }

  /// 解析跳转的url，并且分析其内部参数
  Map<String, dynamic> _parseUrl(String url) {
    if (url.startsWith(appScheme)) {
      url = url.substring(9);
    }

    int placeIndex = url.indexOf('?');

    if (url == '' || url == null) {
      return {'action': 'default', 'params': null};
    }
    if (placeIndex < 0) {
      return {'action': url, 'params': null};
    }

    String action = url.substring(0, placeIndex);
    String paramStr = url.substring(placeIndex + 1);

    if (paramStr == null) {
      return {'action': action, 'params': null};
    }

    Map params = {};
    List<String> paramsStrArr = paramStr.split('&');
    for (String singleParamsStr in paramsStrArr) {
      List<String> singleParamsArr = singleParamsStr.split('=');
      // 获取组件参数
      if (routerMapping[action].params != null) {
        List<String> paramsList = routerMapping[action].params;
        if (paramsList.contains(singleParamsArr[0])) {
          params[singleParamsArr[0]] = singleParamsArr[1];
        }
      }
    }
    return {'action': action, 'params': params};
  }

  /// 增加 scaffold
  Widget _buildPage(Widget widgetPage) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: widgetPage,
        ));
  }

  /// 注册路由事件
  Map<String, Widget Function(BuildContext)> registerRouter() {
    Map<String, Widget Function(BuildContext)> routerInfo = {};

    routerMapping.forEach((routerName, routerData) {
      if (routerName.toString() == 'default') {
        // 默认逻辑不处理
        return;
      }
      if (routerData.needScaffold) {
        routerInfo[routerName.toString()] =
            (context) => _buildPage(routerData.widget);
      } else {
        routerInfo[routerName.toString()] = (context) => routerData.widget;
      }
    });
    return routerInfo;
  }

  /// 根据页面路由，获取页面信息
  Widget getPageByRouter(String pageName) {
    Widget pageWidget;
    if (routerMapping[pageName] != null) {
      pageWidget = routerMapping[pageName].widget;
    } else {
      pageWidget = routerMapping['default'].widget;
    }
    return pageWidget;
  }
}
