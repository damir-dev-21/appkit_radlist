import 'package:appkit/common/model/timestamped.dart';
import 'package:appkit/common/util/format.dart';
import 'package:appkit/ui/pagination/model/base.paginator.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'app_paginated_list.widget.dart';

class AppTimestampedList<T extends Timestamped> extends StatefulWidget {
  final List<T>? items;
  final Widget Function(T item) itemBuilder;
  final Widget Function()? separatorBuilder;
  final EdgeInsets? padding;

  final ScrollController? controller;
  final ScrollPhysics? physics;

  final BasePaginator<T>? paginator;
  final double? itemExtent;

  final bool noRefreshIndicator;

  AppTimestampedList({
    required this.itemBuilder,
    this.items,
    this.separatorBuilder,
    this.padding,
    this.paginator,
    this.controller,
    this.physics,
    this.itemExtent,
    this.noRefreshIndicator = false,
  });

  @override
  _AppTimestampedListState<T> createState() => _AppTimestampedListState<T>();
}

class _AppTimestampedListState<T extends Timestamped> extends State<AppTimestampedList<T>> {
  final _itemsGroupedByDate = <TimestampedGroup<T>>[];
  _TimestampedPaginator<T>? _paginator;

  _AppTimestampedListState();

  @override
  void initState() {
    super.initState();
    _groupItemsByDate();
    final paginator = widget.paginator;
    if (paginator != null) {
      _paginator = _TimestampedPaginator(source: paginator);
    }
  }

  @override
  void dispose() {
    _paginator?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppTimestampedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_paginator == null) {
      _groupItemsByDate();
    }
  }

  void _groupItemsByDate() {
    Timestamped.groupItemsByDate(widget.items, _itemsGroupedByDate);
  }

  @override
  Widget build(BuildContext context) {
    final paginator = _paginator;
    if (paginator != null) {
      return AppPaginatedList<TimestampedGroup<T>>(
        paginator: paginator,
        scrollController: widget.controller,
        itemBuilder: _buildItem,
        itemExtent: widget.itemExtent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        noRefreshIndicator: widget.noRefreshIndicator,
      );
    } else {
      return ListView.builder(
        itemCount: _itemsGroupedByDate.length,
        padding: widget.padding,
        itemBuilder: (context, index) => _buildItem(_itemsGroupedByDate[index], index),
        controller: widget.controller,
        physics: widget.physics,
      );
    }
  }

  Widget _buildItem(TimestampedGroup<T> group, int index) {
    final children = <Widget>[];
    for (int i = 0; i < group.items.length; i++) {
      children.add(widget.itemBuilder(group.items[i]));
      final separatorBuilder = widget.separatorBuilder;
      if (i < group.items.length - 1 && separatorBuilder != null) {
        children.add(separatorBuilder());
      }
    }

    return StickyHeader(
      header: _buildHeader(group.timestamp),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildHeader(DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      color: theme(context).backgroundColor,
      child: Text(
        Format.dateWithWeekday(timestamp),
        style: TextStyle(
          fontSize: 16,
          color: theme(context).disabledTextColor,
        ),
      ),
    );
  }
}

class _TimestampedPaginator<T extends Timestamped> extends Paginator<TimestampedGroup<T>> {
  final BasePaginator<T> _sourcePaginator;

  _TimestampedPaginator({required BasePaginator<T> source}) : _sourcePaginator = source {
    source.refreshListener = refresh;

    _sourcePaginator.addListener(_onSourcePaginatorUpdated);
  }

  void dispose() {
    _sourcePaginator.removeListener(_onSourcePaginatorUpdated);
  }

  void _onSourcePaginatorUpdated(List<T> items) {
    _updateItems(items);
    onStateChanged(this);
  }

  int _elementCount = 0;

  @override
  bool get hasMore => _sourcePaginator.hasMore;

  @override
  void onRefresh() {}

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    _sourcePaginator.onRefresh();
    return super.refresh(notifyStateChanged);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) {
    return _sourcePaginator.loadData(isLoadMoreAction).then((isSuccessful) {
      if (isSuccessful) {
        _updateItems(_sourcePaginator);
      }
      return isSuccessful;
    });
  }

  void _updateItems(List<T> sourceItems) {
    Timestamped.groupItemsByDate(sourceItems, this);
    _elementCount = fold(0, (count, it) => count + it.items.length + 1);
  }

  @override
  int get elementCount => _elementCount;
}
