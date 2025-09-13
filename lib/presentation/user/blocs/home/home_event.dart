abstract class HomeEvent {}

class LoadHomeWidgets extends HomeEvent {
  final int regionId;
  LoadHomeWidgets(this.regionId);
}
