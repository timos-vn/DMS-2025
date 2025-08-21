import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef LoadMoreCallback = Future<void> Function();

///构建自定义状态返回
typedef LoadMoreBuilder = Widget? Function(BuildContext context, LoadStatus status);

///加载状态
enum LoadStatus {
  normal, //正常状态
  error, //加载错误
  loading, //加载中
  completed, //加载完成
}

///加载更多 Widget
class LoadAny extends StatefulWidget {
  final LoadStatus status;
  final LoadMoreCallback onLoadMore;
  final LoadMoreBuilder? loadMoreBuilder;
  final CustomScrollView child;
  final bool endLoadMore;
  final double bottomTriggerDistance;
  final double footerHeight;
  final Key _keyLastItem = const Key("__LAST_ITEM");
  final String loadingMsg;
  final String errorMsg;
  final String finishMsg;
  final Widget indicator;

  const LoadAny(
      {key,
      required this.status,
      required this.onLoadMore,
      required this.child,
      this.endLoadMore = true,
      this.bottomTriggerDistance = 200,
      this.footerHeight = 40,
      this.loadMoreBuilder,
      this.loadingMsg = 'Đang tải',
      this.errorMsg = 'Thất bại, có lỗi xảy ra',
      this.finishMsg = '',
      this.indicator = const CupertinoActivityIndicator()});

  @override
  State<StatefulWidget> createState() => _LoadAnyState();
}

class _LoadAnyState extends State<LoadAny> {
  @override
  Widget build(BuildContext context) {
    ///添加 Footer Sliver
    dynamic check = widget.child.slivers.elementAt(widget.child.slivers.length - 1);

    ///判断是否已存在 Footer
    if (check is SliverSafeArea && check.key == widget._keyLastItem) {
      widget.child.slivers.removeLast();
    }

    widget.child.slivers.add(
      SliverSafeArea(
        key: widget._keyLastItem,
        top: false,
        left: false,
        right: false,
        sliver: SliverToBoxAdapter(
          child: _buildLoadMore(widget.status),
        ),
      ),
    );
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleNotification,
        child: widget.child,
      ),
    );
  }

  ///构建加载更多 Widget
  Widget _buildLoadMore(LoadStatus status) {
    ///检查返回自定义状态
    if (widget.loadMoreBuilder != null) {
      Widget? loadMore = widget.loadMoreBuilder!(context, status);
      if (loadMore != null) {
        return loadMore;
      }
    }

    ///返回内置状态
    if (status == LoadStatus.loading) {
      return _buildLoading();
    } else if (status == LoadStatus.error) {
      return _buildLoadError();
    } else if (status == LoadStatus.completed) {
      return _buildLoadFinish();
    } else {
      return Container(height: widget.footerHeight);
    }
  }

  ///加载中状态
  Widget _buildLoading() {
    return SizedBox(
      height: widget.footerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          widget.indicator,
          SizedBox(width: widget.loadingMsg.isNotEmpty ? 10 : 0),
          Text(
            widget.loadingMsg,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  ///加载错误状态
  Widget _buildLoadError() {
    return widget.errorMsg == 'no'
        ? const SizedBox()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //点击重试加载更多
              widget.onLoadMore();
            },
            child: SizedBox(
              height: widget.footerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.errorMsg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  ///加载错误状态
  Widget _buildLoadFinish() {
    return Container(
      alignment: Alignment.center,
      height: widget.footerHeight,
      child: Text(
        widget.finishMsg,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  ///计算加载更多
  bool _handleNotification(ScrollNotification notification) {
    //current scroll distance
    double currentExtent = notification.metrics.pixels;
    //maximum scroll distance
    double maxExtent = notification.metrics.maxScrollExtent;
    //During the scrolling update, and setting non-scrolling to the bottom can trigger loading more
    if ((notification is ScrollUpdateNotification) && !widget.endLoadMore) {
      return _checkLoadMore((maxExtent - currentExtent <= widget.bottomTriggerDistance));
    }

    //Scroll to the bottom and set the scroll to the bottom to trigger loading more
    if ((notification is ScrollEndNotification) && widget.endLoadMore) {
      //When scrolled to the bottom and the loading status is normal, call to load more
      return _checkLoadMore((currentExtent >= maxExtent));
    }

    return false;
  }

  ///handle loading more
  bool _checkLoadMore(bool canLoad) {
    if (canLoad && widget.status == LoadStatus.normal) {
      widget.onLoadMore();
      return true;
    }
    return false;
  }
}
