import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/models/home_screen_widget.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<HomeScreenWidgetModel> widgets;
  final Map<Category, List<Category>> categories;
  
  HomeLoaded(this.widgets, this.categories);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
