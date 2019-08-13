import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gsy_github_app_flutter/bloc/dynamic_bloc.dart';
import 'package:gsy_github_app_flutter/common/dao/repos_dao.dart';
import 'package:gsy_github_app_flutter/common/model/Event.dart';
import 'package:gsy_github_app_flutter/common/redux/gsy_state.dart';
import 'package:gsy_github_app_flutter/common/utils/event_utils.dart';
import 'package:gsy_github_app_flutter/widget/event_item.dart';
import 'package:gsy_github_app_flutter/widget/pull/gsy_pull_new_load_widget.dart';
import 'package:redux/redux.dart';

/**
 * 主页动态tab页
 * Created by guoshuyu
 * Date: 2018-07-16
 */
class DynamicPage extends StatefulWidget {
  @override
  _DynamicPageState createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage>
    with AutomaticKeepAliveClientMixin<DynamicPage>, WidgetsBindingObserver {
  final DynamicBloc dynamicBloc = new DynamicBloc();

  ///控制列表滚动和监听
  final ScrollController scrollController = new ScrollController();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  /// 模拟IOS下拉显示刷新
  showRefreshLoading() {
    ///直接触发下拉
    new Future.delayed(const Duration(milliseconds: 500), () {
      scrollController.animateTo(-141,
          duration: Duration(milliseconds: 600), curve: Curves.linear);
      return true;
    });
  }

  /// 下拉刷新数据
  Future<void> requestRefresh() async {
    //await Future.delayed(Duration(seconds: 1));
    return await dynamicBloc.requestRefresh(_getStore().state.userInfo?.login);
  }

  /// 上拉更多请求数据
  Future<void> requestLoadMore() async {
    return await dynamicBloc.requestLoadMore(_getStore().state.userInfo?.login);
  }

  // 布局
  _renderEventItem(Event e) {
    EventViewModel eventViewModel = EventViewModel.fromEventMap(e);
    return new EventItem(
      eventViewModel,
      onPressed: () {
        print('按钮， 单元格触发事件, event.type: ${e.type}');
        EventUtils.ActionUtils(context, e, "");
      },
    );
  }

  Store<GSYState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  void initState() {
    print('>>>>>>>>>>>>>>>>>>>>>> initState <<<<<<<<<<<<<<<<<<<<');

    super.initState();
    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
    WidgetsBinding.instance.addObserver(this);

    ///获取网络端新版信息
    ReposDao.getNewsVersion(context, false);
  }

  @override
  void didChangeDependencies() {
    print('>>>>>>>>>>>>>>>>>>>>>> didChangeDependencies <<<<<<<<<<<<<<<<<<<<');
    ///请求更新
    if (dynamicBloc.getDataLength() == 0) {
      dynamicBloc.changeNeedHeaderStatus(false);
      print('请求动态列表数据');
      /// 先读数据库
      dynamicBloc.requestRefresh(_getStore().state.userInfo?.login,
          doNextFlag: false).then((_) {
            // print(' showRefreshLoading');
        showRefreshLoading();
      });

    }
    super.didChangeDependencies();
  }

  ///监听生命周期，主要判断页面 resumed 的时候触发刷新
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('>>>>>>>>>>>>>>>>>>>>>> didChangeAppLifecycleState <<<<<<<<<<<<<<<<<<<<');

    if (state == AppLifecycleState.resumed) {
      if (dynamicBloc.getDataLength() != 0) {
        showRefreshLoading();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    print('>>>>>>>>>>>>>>>>>>>>>> dispose <<<<<<<<<<<<<<<<<<<<');
    WidgetsBinding.instance.removeObserver(this);
    dynamicBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('>>>>>>>>>>>>>>>>>>>>>> build <<<<<<<<<<<<<<<<<<<<');

    super.build(context); // See AutomaticKeepAliveClientMixin.
    return GSYPullLoadWidget(
      dynamicBloc.pullLoadWidgetControl,
      // 列表单元格, 根据数据源动态创建
      (BuildContext context, int index) =>
          _renderEventItem(dynamicBloc.dataList[index]),
      requestRefresh,
      requestLoadMore,
      refreshKey: refreshIndicatorKey,
      scrollController: scrollController,

      ///使用ios模式的下拉刷新
      userIos: true,
    );
  }
}
