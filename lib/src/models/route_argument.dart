class RouteArgument {
  String id;
  String heroTag;
  dynamic param;
  String orderStatusGif;

  RouteArgument({this.id, this.heroTag, this.param, this.orderStatusGif});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}}';
  }
}
