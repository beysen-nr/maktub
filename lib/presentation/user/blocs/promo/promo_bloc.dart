import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/models/promo.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/presentation/user/blocs/promo/promo_event.dart';
import 'package:maktub/presentation/user/blocs/promo/promo_state.dart';

class PromoRepository {

  Future<PromoModel> fetchPromo({required String code, required int supplierId, required int regionId}) async {
    final response = await SupabaseService.client
        .from('promocodes')
        .select()
        .eq('promocode', code)
        .eq('supplier_id', supplierId)
        .eq('region_id', regionId)
        .limit(1)
        .single();

       
            return PromoModel.fromJson(response);
  }

  Future<void> setOrganizationToPromo(int organizationId, int supplierId, String promocode, )async{
    await SupabaseService.client.from('promocodes').update({'organization_id':organizationId}).eq('supplier_id', supplierId).eq('promocode', promocode);

  }

  Future<void> updateUsecountPromo(int organizationId, int supplierId, String promocode, int newQuantity, int useCount)async{

    if(useCount > newQuantity){
    await SupabaseService.client.from('promocodes').update({'used_times':newQuantity}).eq('supplier_id', supplierId).eq('promocode', promocode);
    }else{
    await SupabaseService.client.from('promocodes').update({'used_times':newQuantity, 'is_active':false}).eq('supplier_id', supplierId).eq('promocode', promocode);
      
    }

  }
}






class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final PromoRepository repository;

  PromoBloc(this.repository) : super(PromoInitial()) {
     on<UpdatePromo>((event, emit) async {
  emit(PromoLoading());

  try {
    final promo = await repository.fetchPromo(
      code: event.code,
      supplierId: event.supplierId,
      regionId: event.regionId,
    );

    // Если organizationId не совпадает — ошибка
      await repository.updateUsecountPromo(event.organizationId, event.supplierId, event.code, promo.usedTimes!+1, promo.useCount!);

  } catch (e) {
    emit(PromoError(code: e.toString()));
  }
});
 
    on<FetchPromoByCode>((event, emit) async {
  emit(PromoLoading());

  try {
    final promo = await repository.fetchPromo(
      code: event.code,
      supplierId: event.supplierId,
      regionId: event.regionId,
    );


    // Если organizationId не совпадает — ошибка
    if (promo.organizationId != null && promo.organizationId != event.organizationId) {
      emit(PromoError(code: 'Промокод лимит'));
      return;
    }

    if(promo.usedTimes==promo.useCount){
      emit(PromoError(code: 'Лимит аяқталды'));
      return;
    }
    
      if(!promo.isActive!){
      emit(PromoError(code: 'Промокод жарамсыз'));
      return;
    }

    // Если organizationId == null — установим его и загрузим заново
    if (promo.organizationId == null) {
      await repository.setOrganizationToPromo(
        event.organizationId,
        event.supplierId,
        event.code,
      );
      emit(PromoLoaded(promo));
    } else {

      emit(PromoLoaded(promo));
    }
  } catch (e) {
    emit(PromoError(code: 'Промокод лимит'));
  }
});
 
 }


   double calculateDiscountedPrice(double originalPrice, PromoModel promo) {
    if (promo.fixedDiscount == true) {
      return originalPrice - (promo.discount ?? 0);
    } else {
      return originalPrice * (1 - (promo.discount ?? 0) / 100);
    }
  }
}