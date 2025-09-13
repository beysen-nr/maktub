import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/presentation/blocs/auth/auth_state.dart';
import 'package:maktub/data/models/address.dart'; // << подключить модель адреса

class AppState {
  final String phone;
  final int workplaceId;
  final bool isActive;
  final String fullName;
  final String role;
  final String organizationName;
  final String ownerName;
  int regionId;
  final Address? selectedAddress; // << добавляем выбранный адрес
  final Map<Category, List<Category>>? categories;
  final String cityName;

  AppState({
    required this.ownerName,
    required this.regionId,
    required this.phone,
    required this.workplaceId,
    required this.fullName,
    required this.isActive,
    required this.role,
    required this.organizationName,
    this.selectedAddress,
    this.categories,
    required this.cityName,
    // << не забываем
  });
  AppState copyWith({
    String? ownerName,
    String? phone,
    int? workplaceId,
    String? fullName,
    String? role,
    int? regionId,
    Address? selectedAddress,
    String? organizationName,
    bool? isActive,
    String? cityName,
    Map<Category, List<Category>>? categories, // 👈 добавлено
  }) {
    return AppState(
      ownerName: ownerName ?? this.ownerName,
      organizationName: organizationName ?? this.organizationName,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      workplaceId: workplaceId ?? this.workplaceId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      regionId: regionId ?? this.regionId,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      cityName: cityName ?? this.cityName,
      categories: categories ?? this.categories, // 👈 добавлено
    );
  }
}

class AppStateCubit extends Cubit<AppState?> {
  AppStateCubit() : super(null);

  void updateCategories(Map<Category, List<Category>> categories) {
    if (state != null) {
      emit(state!.copyWith(categories: categories));
    }
  }

  void setFromAuth(AuthAuthenticated auth) {
    emit(
      AppState(
        ownerName: auth.ownerName,
        organizationName: auth.organizationName,
        isActive: auth.isActive,
        regionId: auth.regionId,
        phone: auth.phone,
        workplaceId: auth.workplaceId,
        fullName: auth.fullName,
        role: auth.role.name,
        cityName: auth.cityName,
      ),
    );
  }

  void setFromAuthSuccess(AuthSuccess auth) {
    emit(
      AppState(
        ownerName: auth.ownerName,
        organizationName: auth.organizationName,
        isActive: auth.isActive,
        regionId: auth.regionId,
        phone: auth.phone,
        workplaceId: auth.workplaceId,
        fullName: auth.fullName,
        role: auth.role.name,
        cityName: auth.cityName,
      ),
    );
  }

  Future<void> updateRegion(int regionId) async {
    if (state != null) {
      final response = await SupabaseService.client
          .from('region')
          .select('name')
          .eq('id', regionId);
      final data = response[0];
      String name = data['name'];
      emit(
        state!.copyWith(
          regionId: regionId,
          cityName: name,
          selectedAddress:
              null, // Когда регион меняется, сбрасываем выбранный адрес
        ),
      );
    }
  }

  void updateSelectedAddress(Address address) {
    if (state != null) {
      emit(state!.copyWith(selectedAddress: address));
    }
  }

  void clear() => emit(null);
}
