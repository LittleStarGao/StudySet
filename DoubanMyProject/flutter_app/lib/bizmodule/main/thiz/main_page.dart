import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    var tabs = ['精选', '发现', '分类', '社区'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: buildTabBar(tabs), //通过设置 AppBar 的 title 属性，传入一个 TabBar 可以将 TabBar 组件设置到顶部的 AppBar 中
          elevation: 2.0
        ),
        drawer: Drawer(
          child: Text('侧滑边栏'),
        ),
        body: TabBarView(//然后只需要在 body 中配置对应的 TabBarView
          children: tabs.map((tab) => Center(child: Text(tab))).toList(),//目前每个页面仅仅配置了一个居中的 Text 文本
        ),
      ),
    );
  }

  Widget buildTabBar(List<String> tabs) {
    return TabBar(
      isScrollable: true,
      indicator: BoxDecoration(color: Colors.transparent),
      indicatorSize: TabBarIndicatorSize.label,
      tabs: tabs.map((textStr) => Tab(text: textStr)).toList(),
      labelStyle: TextStyle(
        color: Color(0xff333333),
        fontSize: 15,
        fontFamily: 'NotoSansHans-Medium',
      ),
      unselectedLabelStyle: TextStyle(
        color: Color(0xff666666),
        fontSize: 15,
        fontFamily: 'NotoSansHans-Regular',
      ),
    );
  }
}
