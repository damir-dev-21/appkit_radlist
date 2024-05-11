import 'package:appkit/appkit.dart';
import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/app_loading_indicator.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

class _CustomListConfig<T> extends ListConfig<T> {
  final WidgetBuilder? emptyViewBuilder;

  _CustomListConfig({
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget Function(BuildContext, IndicatorStatus)? indicatorBuilder,
    ScrollController? controller,
    required Paginator<T> paginator,
    double? itemExtent,
    EdgeInsets? padding,
    this.emptyViewBuilder,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    SliverGridDelegate? gridDelegate,
    ScrollPhysics? physics,
  }) : super(
          itemBuilder: itemBuilder,
          indicatorBuilder: indicatorBuilder,
          sourceList: paginator,
          itemExtent: itemExtent,
          padding: padding ?? EdgeInsets.zero,
          controller: controller,
          gridDelegate: gridDelegate,
          keyboardDismissBehavior: keyboardDismissBehavior,
          physics: physics,
        );

  @override
  Widget buildContent(BuildContext context, LoadingMoreBase<T>? source) {
    if (source?.isEmpty == true &&
        (source?.indicatorStatus == IndicatorStatus.empty ||
            source?.indicatorStatus == IndicatorStatus.fullScreenError)) {
      return emptyViewBuilder?.call(context) ?? Appkit.emptyWidgetBuilder();
    }
    return super.buildContent(context, source);
  }
}

class AppPaginatedList<T> extends StatelessWidget {
  final Paginator<T> paginator;
  final Widget Function(T item, int index) itemBuilder;
  final ScrollController? scrollController;
  final double? itemExtent;
  final EdgeInsets? padding;
  final bool noRefreshIndicator;
  final WidgetBuilder? emptyViewBuilder;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final VoidCallback? pullToRefreshCallback;
  final Widget? shimmer;
  final SliverGridDelegate? gridDelegate;
  final Widget? endWidget;
  final Widget? loadingWidget;
  final ScrollPhysics? physics;

  const AppPaginatedList({
    Key? key,
    required this.paginator,
    required this.itemBuilder,
    this.scrollController,
    this.itemExtent,
    this.padding,
    this.noRefreshIndicator = false,
    this.emptyViewBuilder,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.pullToRefreshCallback,
    this.shimmer,
    this.gridDelegate,
    this.endWidget,
    this.loadingWidget,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = LoadingMoreList(
      _CustomListConfig<T>(
        itemBuilder: (context, item, index) => itemBuilder(item, index),
        indicatorBuilder: (context, status) => buildProgressIndicator(
          context: context,
          status: status,
          paginator: paginator,
          shimmer: shimmer,
          gridDelegate: gridDelegate,
          padding: padding,
          endWidget: endWidget,
          loadingWidget: loadingWidget,
        ),
        controller: scrollController,
        paginator: paginator,
        itemExtent: itemExtent,
        padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 0),
        emptyViewBuilder: emptyViewBuilder,
        keyboardDismissBehavior: keyboardDismissBehavior,
        gridDelegate: gridDelegate,
        physics: physics,
      ),
    );

    if (noRefreshIndicator) {
      return content;
    } else {
      return CustomRefreshIndicator(
        onRefresh: () {
          pullToRefreshCallback?.call();
          return paginator.refresh(true);
        },
        builder: MaterialIndicatorDelegate(
          backgroundColor: Colors.transparent,
          elevation: 0,
          builder: (_, __) => SizedBox.shrink(),
        ),
        child: content,
      );
    }
  }

  static Widget buildProgressIndicator({
    required BuildContext context,
    required IndicatorStatus status,
    required Paginator paginator,
    WidgetBuilder? emptyViewBuilder,
    Color? backgroundColor,
    Widget? shimmer,
    SliverGridDelegate? gridDelegate,
    EdgeInsets? padding,
    Widget? endWidget,
    Widget? loadingWidget,
  }) {
    switch (status) {
      case IndicatorStatus.empty:
        return Center(
            child: Text(
                "Nothing found")); //TranslatedText(AppkitTr.label.empty$));
      case IndicatorStatus.noMoreLoad:
        if (paginator.elementCount < 7) {
          return Container(color: backgroundColor);
        } else {
          return endWidget ??
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                color: backgroundColor,
                // child: TranslatedText(
                //   AppkitTr.label.listEnd$,
                //   textAlign: TextAlign.center,
                // ),
              );
        }
      case IndicatorStatus.loadingMoreBusying:
      case IndicatorStatus.fullScreenBusying:
        if (shimmer != null) {
          if (gridDelegate != null) {
            return GridView(
              padding: padding,
              gridDelegate: gridDelegate,
              shrinkWrap: true,
              children: [
                for (int i = 1; i <= 9; i++) shimmer,
              ],
            );
          }
          return SingleChildScrollView(
            padding: padding,
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                for (int i = 1; i <= 10; i++) shimmer,
              ],
            ),
          );
        }
        return Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppLoadingIndicator(),
              verticalSpace(10),
              loadingWidget ??
                  Text("Loading") //TranslatedText(AppkitTr.label.loading$),
            ],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }
}
