import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/models/home_screen_widget.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/category_repo.dart';
import 'package:maktub/presentation/user/blocs/home/home_event.dart';
import 'package:maktub/presentation/user/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeWidgets>(_onLoadWidgets);
  }

     Future<Map<Category, List<Category>>> _loadCategories()  async {
    final all = await CategoryService().fetchAllCategories();
    final sections =
        all.where((c) => c.parentId == null).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    final children = all.where((c) => c.parentId != null).toList();

    final Map<Category, List<Category>> result = {};
    for (var section in sections) {
      result[section] =
          children.where((c) => c.parentId == section.id).toList();
    }

    return result;  
  }

  Future<void> _onLoadWidgets(LoadHomeWidgets event, Emitter<HomeState> emit) async {
    emit(HomeLoading());


try {

      final categories = await _loadCategories();
      final all = await CategoryService().fetchAllCategories();
      final sections =
          all.where((c) => c.parentId == null).toList()
            ..sort((a, b) => a.id.compareTo(b.id));

      final children = all.where((c) => c.parentId != null).toList();

      final Map<Category, List<Category>> result = {};
      for (var section in sections) {
        result[section] =
            children.where((c) => c.parentId == section.id).toList();
      }

  final data = await SupabaseService.client
      .from('home_screen_widgets')
      .select()
      .inFilter('region_id', [event.regionId, 777])
      .order('position', ascending: true);
  final widgets = (data as List<dynamic>)
      .map((e) => HomeScreenWidgetModel.fromJson(e))
      .toList();


      emit(HomeLoaded(widgets, categories));
    } catch (e) {
      emit(HomeError('Ошибка загрузки виджетов: $e'));
    }
  }
}
