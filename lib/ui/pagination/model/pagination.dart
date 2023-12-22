class Pagination<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  Pagination({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;

  int get nextPage => currentPage + 1;

  factory Pagination.fromData(List<T> data) {
    return Pagination(
      data: data,
      currentPage: 1,
      lastPage: 1,
      total: data.length,
    );
  }
}
