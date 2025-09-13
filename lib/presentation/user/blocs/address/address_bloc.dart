import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/address_repo.dart';
import 'package:maktub/presentation/user/blocs/address/address_event.dart';
import 'package:maktub/presentation/user/blocs/address/address_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository repository;

  AddressBloc(this.repository) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoad);
    on<DeleteAddress>(_onDelete);
    on<CreateOrUpdateAddress>(_onCreateOrUpdate);
    on<LoadRegions>(_onLoadRegions);
    on<SearchAddressChanged>(
      _onSearchAddressChanged,
      transformer: debounce(const Duration(milliseconds: 1000)),
    );
    on<SearchAddressByPoint>(
      _onSearchAddressByPoint);

    on<AddressAdded>((event, emit) async {
      emit(AddressAddedState());
    });

    on<AddAddress>((event, emit) async {
      emit(AddressAdding());
      try {
        await repository.createOrUpdateAddress(event.address);
        add(LoadAddresses(event.address.organizationId));
        add(RegionChanged(regionId: event.address.regionId, phone: event.phone));
        emit(AddressAddedSuccess());
      } catch (e) {
        emit(AddressFailure('Қате орын алды: $e'));
      }
    });
        on<RegionChanged>((event, emit) async {
    //todo: states for regionchanged
      try {
        await repository.regionChanged(event.regionId, event.phone);
     
        emit(AddressAddedSuccess());
      } catch (e) {
        emit(AddressFailure('Қате орын алды: $e'));
      }
    });

  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  bool isValidPolygon(Polygon polygon) {
    final points = polygon.outerRing.points;
    if (points.length < 4) return false;
    if (points.first != points.last) return false;
    if (polygon.innerRings.isNotEmpty) return false;
    return true;
  }

  bool isPointInPolygon(Point point, List<Point> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      final p1 = polygon[j];
      final p2 = polygon[j + 1];

      if (((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
  }

  Future<void> _onSearchAddressByPoint(
    SearchAddressByPoint event,
    Emitter<AddressState> emit,
  ) async {
    emit(SearchLoading());

    try {
      final point = event.point;
      final geometry = event.geometry;

      final resultWithSession = await YandexSearch.searchByPoint(
        point: point,
        searchOptions: SearchOptions(geometry: true),
      );

      final polygonPoints = geometry.polygon?.outerRing.points;

      final session = resultWithSession.$1;
      final result = await resultWithSession.$2;

      final filteredItems =
          result.items?.where((e) {
            final geometries = e.geometry; // List<Geometry>

            final pointGeometry = geometries.firstWhere((g) => g.point != null);

            final point = pointGeometry.point;

            return point != null && isPointInPolygon(point, polygonPoints!);
          }).toList() ??
          [];

      session.close();

      final addresses =
          filteredItems
              .map((e) {
                final addr = e.toponymMetadata?.address;
                final geometry = e.geometry.firstWhere((g) => g.point != null);

                if (addr == null || geometry.point == null) return null;

                final comps = addr.addressComponents;

                final parts = [
                  comps[SearchComponentKind.street],
                  comps[SearchComponentKind.house],
                  comps[SearchComponentKind.entrance],
                ];

                const List<String> forbiddenWords = [
                  'улица',
                  'переулок',
                  'проспект',
                  'пр-кт',
                  'бульвар',
                  'набережная',
                  'шоссе',
                  'аллея',
                  'площадь',
                ];

                final cleanedParts =
                    parts
                        .where((p) => p != null && p.isNotEmpty)
                        .map((p) => p!.toLowerCase()) // сначала в lowercase
                        .map((p) {
                          for (final word in forbiddenWords) {
                            p =
                                p
                                    .replaceAll(word, '')
                                    .trim(); // убираем слово если есть
                          }
                          return p;
                        })
                        .where((p) => p.isNotEmpty) // убираем пустые строки
                        .toList();

                final cleanedAddress = cleanedParts.join(', ');

                return AddressSuggestion(
                  formattedAddress: cleanedAddress,
                  latitude: point.latitude,
                  longitude: point.longitude,
                );
              })
              .whereType<AddressSuggestion>()
              .toList();
              if(addresses
              .isEmpty) {
                emit(SearchFailure('бұл мекенге жеткізу мүмкін емес'));
                return;
              }

      emit(PointSearchSuccess(addresses));
    } on PlatformException catch (e) {
      emit(SearchFailure('Платформенная ошибка: ${e.message}'));
    } catch (e) {
      emit(SearchFailure('Ошибка: $e'));
    }
  }

  BoundingBox boundingBoxFromGeometry(Geometry geometry) {

  final points = geometry.polygon!.outerRing.points;

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLon = points.first.longitude;
  double maxLon = points.first.longitude;

  for (final point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLon) minLon = point.longitude;
    if (point.longitude > maxLon) maxLon = point.longitude;
  }

  return BoundingBox(
    southWest: Point(latitude: minLat, longitude: minLon),
    northEast: Point(latitude: maxLat, longitude: maxLon),
  );
}


  Future<void> _onSearchAddressChanged(
    SearchAddressChanged event,
    Emitter<AddressState> emit,
  ) async {
    emit(SearchLoading());

    try {
      final geometry = event.geometry;

            final resultWithSession1 = await YandexSuggest.getSuggestions(
        text: event.query,
        boundingBox: boundingBoxFromGeometry(geometry),
        suggestOptions: SuggestOptions(suggestType: SuggestType.geo),
      );


      final resultWithSession = await YandexSearch.searchByText(
        searchText: event.query,
        geometry: geometry,
        searchOptions: SearchOptions(geometry: true),
      );

      final polygonPoints = geometry.polygon?.outerRing.points;

      final session = resultWithSession1.$1;
      final result = await resultWithSession.$2;

      final filteredItems =
          result.items?.where((e) {
            final geometries = e.geometry; // List<Geometry>

            final pointGeometry = geometries.firstWhere((g) => g.point != null);

            final point = pointGeometry.point;

            return point != null && isPointInPolygon(point, polygonPoints!);
          }).toList() ??
          [];

      session.close();

  final List<AddressSuggestion> allSuggestions = filteredItems
    .map((e) {
      final addr = e.toponymMetadata?.address;
      final geometry = e.geometry.firstWhere((g) => g.point != null);

      if (addr == null || geometry.point == null) return null;

      final comps = addr.addressComponents;

      const List<String> forbiddenWords = [
        'улица',
        'переулок',
        'проспект',
        'пр-кт',
        'бульвар',
        'набережная',
        'шоссе',
        'аллея',
        'площадь',
      ];

      final parts = [
        comps[SearchComponentKind.street],
        comps[SearchComponentKind.house],
        comps[SearchComponentKind.entrance],
      ];

      final cleanedParts = parts
          .where((p) => p != null && p.isNotEmpty)
          .map((p) => p!.toLowerCase())
          .map((p) {
            for (final word in forbiddenWords) {
              p = p.replaceAll(word, '').trim();
            }
            return p;
          })
          .where((p) => p.isNotEmpty)
          .toList();

      final cleanedAddress = cleanedParts.join(' ').trim();

      return AddressSuggestion(
        formattedAddress: cleanedAddress,
        latitude: geometry.point!.latitude,
        longitude: geometry.point!.longitude,
      );
    })
    .whereType<AddressSuggestion>()
    .toList();

// // 🔍 Точное и приближённое совпадение
// final query = event.query.toLowerCase().trim();

// final exactMatches = allSuggestions.where((s) {
//   return s.formattedAddress.startsWith(query); // строгое начало
// }).toList();

// final suggestedMatches = allSuggestions.where((s) {
//   return s.formattedAddress.contains(query) && !s.formattedAddress.startsWith(query);
// }).toList();

// final resultAddresses = [
//   ...exactMatches,
//   ...suggestedMatches,
// ];

emit(SearchSuccess(allSuggestions));

    } on PlatformException catch (e) {
      emit(SearchFailure('Платформенная ошибка: ${e.message}'));
    } catch (e) {
      emit(SearchFailure('Ошибка: $e'));
    }
  }

  Future<void> _onCreateOrUpdate(
    CreateOrUpdateAddress event,
    Emitter emit,
  ) async {
    try {
      await repository.createOrUpdateAddress(event.address);
      add(LoadAddresses(event.organizationId)); // перезагрузим список
    } catch (_) {
      emit(AddressError('Не удалось сохранить адрес'));
    }
  }

  Future<void> _onLoadRegions(LoadRegions event, Emitter emit) async {
    emit(AddressLoading());
    try {
      final regions = await repository.getRegions();
      emit(RegionsLoaded(regions));
    } catch (e) {
      emit(AddressError('Ошибка загрузки адресов'));
    }
  }

  Future<void> _onLoad(LoadAddresses event, Emitter emit) async {
    emit(AddressLoading());
    try {
      final addresses = await repository.getOrganizationAddresses(
        event.organizationId,
      );
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteAddress event, Emitter emit) async {
    if (state is! AddressLoaded) return;
    await repository.deleteAddress(event.addressId);
    add(LoadAddresses(event.organizationId));
  }
}

class AddressSuggestion {
  final String formattedAddress;
  final double latitude;
  final double longitude;

  AddressSuggestion({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
}
