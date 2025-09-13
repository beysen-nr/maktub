abstract class PromoEvent {}

class FetchPromoByCode extends PromoEvent {
  final String code;
  final int supplierId;
  final int organizationId;
  final int regionId;

  FetchPromoByCode({required this.code, required this.supplierId, required this.organizationId, required this.regionId});
}


class UpdatePromo extends PromoEvent {
  final String code;
  final int supplierId;
  final int organizationId;
  final int regionId;
  final int newCount;

  UpdatePromo({required this.code, required this.supplierId, required this.organizationId, required this.regionId, required this.newCount});
}
