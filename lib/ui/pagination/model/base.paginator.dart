import 'package:appkit/data/operation_result.dart';
import 'package:appkit/ui/util/executor.dart';
import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'pagination.dart';
import 'paginator.dart';

abstract class BasePaginator<T> extends Paginator<T> {
  /// Function used to check if the two objects [a] and [b] are equal.
  /// When refreshing the paginator contents silently, we need to determine
  /// whether the newly retrieved data is different from the
  /// old data. This function is used to do that. If not provided, regular equality
  /// check is performed.
  final bool Function(T a, T b)? _equalityFunction;

  /// Passes this to  underlying [Executor.run] functions.
  final bool ignoreError;

  BasePaginator({
    bool Function(T a, T b)? equalityFunction,
    this.ignoreError = false,
  }) : _equalityFunction = equalityFunction;

  @protected
  Pagination<T>? previousPage;

  Future<OperationResult<Pagination<T>?>> requestPage(Pagination<T>? previousPage);

  /// Cached future while a request in [loadData] is in progress.
  /// Set to null when [loadData] request completes.
  Future<bool>? _loadDataRequestFuture;
  Future<bool>? _loadDataSilentlyFuture;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (value != _isLoading) {
      _isLoading = value;
      _loadingListeners.forEach((listener) => listener(value));
    }
  }

  final _listeners = <void Function(List<T> items)>[];
  final _pageListeners = <void Function(Pagination<T> page)>[];
  final _loadingListeners = <void Function(bool loading)>[];

  void addListener(void Function(List<T> items) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(List<T> items) listener) {
    _listeners.remove(listener);
  }

  void addPageListener(void Function(Pagination<T> page) listener) {
    _pageListeners.add(listener);
  }

  void removePageListener(void Function(Pagination<T> page) listener) {
    _pageListeners.remove(listener);
  }

  void addLoadingListener(void Function(bool loading) listener) {
    _loadingListeners.add(listener);
  }

  void removeLoadingListener(void Function(bool loading) listener) {
    _loadingListeners.remove(listener);
  }

  @override
  bool get hasMore => previousPage == null || previousPage?.hasNextPage == true;

  @override
  void onRefresh() {
    previousPage = null;
    _loadDataSilentlyFuture = null;
    _loadDataRequestFuture = null;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    final loadDataRequestFuture = _loadDataRequestFuture;
    if (loadDataRequestFuture != null) {
      return loadDataRequestFuture;
    }

    return _loadDataRequestFuture = Executor.run<Pagination<T>>(
      request: requestPage(previousPage),
      onResult: (page) {
        if (previousPage == null) {
          clear();
        }
        if (page != null) {
          addAll(page.data);
          previousPage = page;
          _listeners.forEach((it) => it(this));
          _pageListeners.forEach((it) => it(page));
        }
      },
      ignoreError: ignoreError,
    ).then((result) {
      return result.isSuccessful;
    }).whenComplete(() {
      _loadDataRequestFuture = null;
    });
  }

  /// Refresh the first page of the pagination without updating the loading state.
  ///
  /// If the first item of the first page is different from the first item in the
  /// current list or [forceClear] is true, then the entire list is replaced with the first page.
  Future<bool>? refreshSilently({bool forceClear = false}) {
    final loadDataSilentlyFuture = _loadDataSilentlyFuture;
    if (loadDataSilentlyFuture != null) {
      return loadDataSilentlyFuture;
    }

    return _loadDataSilentlyFuture = Executor.run<Pagination<T>>(
      request: requestPage(null),
      onResult: (page) {
        if (page != null) {
          if (forceClear || _isPageDifferent(page)) {
            clear();
            addAll(page.data);
            previousPage = page;
          } else {
            // Replace the first page.
            replaceRange(0, page.data.length, page.data);
          }
          onStateChanged(this);
          _listeners.forEach((it) => it(this));
          _pageListeners.forEach((it) => it(page));
        }
      },
      ignoreError: ignoreError,
    ).then((result) {
      return result.isSuccessful;
    }).whenComplete(() {
      _loadDataSilentlyFuture = null;
    });
  }

  /// Return true if [newPage]'s data is equivalent to the beginning of this paginator's data.
  bool _isPageDifferent(Pagination<T>? newPage) {
    if (newPage != null)
      for (int i = 0; i < newPage.data.length; i++) {
        if (!_equals(newPage.data[i], this[i])) {
          return true;
        }
      }
    return false;
  }

  /// Return true if [a] is equal to [b].
  bool _equals(T a, T b) {
    if (a == null || b == null) {
      return a == b;
    }
    final equalityFunction = _equalityFunction;
    if (equalityFunction != null) {
      return equalityFunction(a, b);
    }
    return a == b;
  }

  bool get isInitializing => indicatorStatus == IndicatorStatus.fullScreenBusying;
}
