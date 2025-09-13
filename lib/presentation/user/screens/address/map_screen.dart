// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/region.dart';
import 'package:maktub/presentation/user/blocs/address/address_bloc.dart';
import 'package:maktub/presentation/user/blocs/address/address_event.dart';
import 'package:maktub/presentation/user/blocs/address/address_state.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late YandexMapController _mapController;
  final TextEditingController addressController = TextEditingController();

  List<Region> _regions = [];
  final List<MapObject> _mapObjects = [];
  Region? _selectedRegion;
  String get _currentRegionName => _selectedRegion?.name ?? 'регион';
  bool _mapReady = false;
  bool _regionsReady = false;
  bool _isInside = false;
  AddressSuggestion? _selectedSuggestion;

  @override
  void initState() {
    super.initState();
  }

  void _onRegionTapped(Region region) async {
    final center = Point(
      latitude: region.center[0],
      longitude: region.center[1],
    );
    setState(() {
            context.read<AppStateCubit>().updateRegion(region.id);
     
      _selectedRegion = region;
      _updatePolygons();
    });
    addressController.text = 'адрес';
    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 12)),
      animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.5),
    );
  }

  void _updatePolygons() {
    _mapObjects.addAll(
      _regions.map((region) {
        final points =
            region.border.first.map((coord) {
              return Point(latitude: coord[0], longitude: coord[1]);
            }).toList();

        return PolygonMapObject(
          mapId: MapObjectId('region_${region.id}'),
          polygon: Polygon(
            outerRing: LinearRing(points: points),
            innerRings: [],
          ),
          strokeColor: Colors.green[500]!,
          strokeWidth: 2,
          fillColor:
              _selectedRegion?.id == region.id
                  ? Colors.green.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.3),
          onTap: (self, point) => _onRegionTapped(region),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {

                      if (state is SearchFailure) {
                        showTopSnackbar(context: context, vsync: this, message: state.message, isError: true, withLove: false);
                        setState(() {
                          _isInside = false;
                        });
                      }
                      if (state is AddressAddedSuccess) {
         context.pop(true);
                      }
          if (state is RegionsLoaded) {
            _regions = state.regions;
            _regions.sort((a, b) => a.id.compareTo(b.id));

            _updatePolygons();
            _regionsReady = true;

            _trySelectDefaultRegion();
            if(!_regionsReady)
            setState(() {});
          }
          if (state is PointSearchSuccess && state.addresses.isNotEmpty) {
            final suggestion = state.addresses.first;
            _selectedSuggestion = suggestion;
            // Проверяем, находится ли точка внутри полигона
            final polygonPoints =
                _selectedRegion != null
                    ? getPolygonForRegion(_selectedRegion!).outerRing.points
                    : <Point>[];

            final isInside = isPointInPolygon(
              Point(
                latitude: suggestion.latitude,
                longitude: suggestion.longitude,
              ),
              polygonPoints,
            );
            _isInside = isInside;
            if (!isInside) {
              addressController.text = 'адрес';
              showTopSnackbar(
                context: context,
                message: 'сіздің мекенжайыңыз аймақтан тыс',
                isError: true,
                vsync: this,
                withLove: false,
              );

              return;
            }

            addressController.text = suggestion.formattedAddress;

            _mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: Point(
                    latitude: suggestion.latitude,
                    longitude: suggestion.longitude,
                  ),
                  zoom: 18,
                ),
              ),
              animation: const MapAnimation(
                type: MapAnimationType.linear,
                duration: 1,
              ),
            );

            _mapObjects.removeWhere(
              (obj) => obj.mapId.value == 'selected_point',
            );
            _mapObjects.add(
              PlacemarkMapObject(
                opacity: 1,
                mapId: const MapObjectId('selected_point'),
                point: Point(
                  latitude: suggestion.latitude,
                  longitude: suggestion.longitude,
                ),
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage(
                      'assets/icons/location.png',
                    ),
                    scale: 0.8,
                  ),
                ),
              ),
            );
          }

          if (_regions.isNotEmpty && _mapReady && _selectedRegion == null) {
            _onRegionTapped(_regions.first);
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                color: Gradients.primary,
                size: 25,
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: YandexMap(
                  key: const ValueKey('main-map'),
                  onMapCreated: (controller) {
                    _mapController = controller;

                    _mapReady = true;
                    _trySelectDefaultRegion();
                  },
                  onMapTap: _onMapTapped,

                  mapObjects: _mapObjects,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 12,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(
                        3.1416,
                      ), 
                      child: Image.asset(
                        'assets/icons-system/arrow.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: GestureDetector(
                    onTap: _showRegionPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentRegionName,
                            style: productNameText.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,

                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 0.7,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                                      
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                      
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              color: Colors.white.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: DeliveryAddressPanel(
                              polygon:
                                  _selectedRegion != null
                                      ? getPolygonForRegion(_selectedRegion!)
                                      : Polygon(
                                        outerRing: LinearRing(points: []),
                                        innerRings: [],
                                      ),
                              controller: addressController,
                              isInside: _isInside,
                              suggestion:
                                  _selectedSuggestion, // <<< ДОБАВЬ ЭТО
                              onAddressSelected: (suggestion) {
                                setState(() {
                                  _selectedSuggestion = suggestion;
                                });
                                      
                                _mapController.moveCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: Point(
                                        latitude: suggestion.latitude,
                                        longitude: suggestion.longitude,
                                      ),
                                      zoom: 20.5,
                                    ),
                                  ),
                                  animation: MapAnimation(
                                    type: MapAnimationType.smooth,
                                    duration: 1,
                                  ),
                                );
                                      
                                _mapObjects.removeWhere(
                                  (obj) =>
                                      obj.mapId.value == 'selected_point',
                                );
                                _mapObjects.add(
                                  PlacemarkMapObject(
                                    opacity: 1,
                                    mapId: const MapObjectId(
                                      'selected_point',
                                    ),
                                    point: Point(
                                      latitude: suggestion.latitude,
                                      longitude: suggestion.longitude,
                                    ),
                                    icon: PlacemarkIcon.single(
                                      PlacemarkIconStyle(
                                        image:
                                            BitmapDescriptor.fromAssetImage(
                                              'assets/icons/location.png',
                                            ),
                                        scale: 0.8,
                                      ),
                                    ),
                                  ),
                                );
                                      
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 16,
                bottom: 225, 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3), 
                        width: 0.7,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(10, 20),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/navigation.png',
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () async {
                        final position = await getUserLocation();
                        if (position != null) {
                          _mapController.moveCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: Point(
                                  latitude: position.latitude,
                                  longitude: position.longitude,
                                ),
                                zoom: 18,
                              ),
                            ),
                            animation: const MapAnimation(
                              type: MapAnimationType.linear,
                              duration: 1,
                            ),
                          );
                          context.read<AddressBloc>().add(
                            SearchAddressByPoint(
                              context.read<AppStateCubit>().state!.regionId,
                              Point(
                                
                                latitude: position.latitude,
                                longitude: position.longitude,
                              ),
                              Geometry.fromPolygon(
                                getPolygonForRegion(_selectedRegion!),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем включена ли геолокация
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Геолокация отключена
      return null;
    }

    // Проверяем разрешение
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showTopSnackbar(
          context: context,
          vsync: this,
          message: 'сіз геолокацияны баптаулардан қоса аласыз',
          isError: false,
          withLove: false,
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showTopSnackbar(
        context: context,
        vsync: this,
        message: 'сіз геолокацияны баптаулардан қоса аласыз',
        isError: false,
        withLove: false,
      );
      return null;
    }

    // Получаем текущее местоположение
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Polygon getPolygonForRegion(Region region) {
    final points =
        region.border.first.map((coord) {
          return Point(latitude: coord[0], longitude: coord[1]);
        }).toList();

    return Polygon(outerRing: LinearRing(points: points), innerRings: []);
  }

  void _trySelectDefaultRegion() {
    if (_mapReady &&
        _regionsReady &&
        _selectedRegion == null &&
        _regions.isNotEmpty) {
          int regionId = context.read<AppStateCubit>().state!.regionId;
      _onRegionTapped(_regions[regionId-1]);
    }
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.grey.shade100.withOpacity(0.5),
      backgroundColor: Colors.transparent, // важно! убрать дефолтный белый фон
      builder: (context) {
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 700),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.blueGrey.withOpacity(0.4),
                      width: 0.7,
                    ),
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.20),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.chooseRegion,
                            style: 
                            
                            GoogleFonts.montserrat(
                              // color: Colors.white,
                              fontSize: 20,
                              color: Gradients.textGray,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: _regions.length,
                              itemBuilder: (context, index) {
                                final region = _regions[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Gradients.primary,
                                          width: 0.7,
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 8),
                                        alignment: Alignment.centerLeft,
                                        height: 30,
                                        child: Text(
                                          region.name,
                                          style: productNameText.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      context.pop();
                                      _onRegionTapped(region);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMapTapped(Point point) async {
    if (!_mapReady || _selectedRegion == null) return;
    _isInside = false;
    final polygon = getPolygonForRegion(_selectedRegion!);

    // Запускаем поиск адреса по координате
    context.read<AddressBloc>().add(
      SearchAddressByPoint(context.read<AppStateCubit>().state!.regionId, point, Geometry.fromPolygon(polygon)),
    );

    // Обновляем маркер сразу
    _mapObjects.removeWhere((obj) => obj.mapId.value == 'selected_point');

    _mapObjects.add(
      PlacemarkMapObject(
        mapId: const MapObjectId('selected_point'),
        point: point,
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/icons/location.png'),
            scale: 1,
          ),
        ),
      ),
    );

    setState(() {});
  }

  bool isPointInPolygon(Point point, List<Point> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].longitude > point.longitude) !=
              (polygon[j].longitude > point.longitude) &&
          (point.latitude <
              (polygon[j].latitude - polygon[i].latitude) *
                      (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) +
                  polygon[i].latitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool rayCastIntersect(Point point, Point vertA, Point vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    double m = (aY - bY) / (aX - bX);
    double bee = (-aX) * m + aY;
    double x = (pY - bee) / m;

    return x > pX;
  }
}

class DeliveryAddressPanel extends StatelessWidget {
  final TextEditingController controller;
  final Polygon polygon;
  final bool isInside;
  final AddressSuggestion? suggestion; // <<< ДОБАВИЛ
  final void Function(AddressSuggestion suggestion) onAddressSelected;

  const DeliveryAddressPanel({
    required this.controller,
    required this.polygon,
    required this.isInside,
    required this.onAddressSelected,
    this.suggestion, // <<< ДОБАВИЛ
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.deliveryAddress,
            style: productNameText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final addressBloc = context.read<AddressBloc>();

              final selectedSuggestion =
                  await showModalBottomSheet<AddressSuggestion>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return BlocProvider.value(
                        value: addressBloc,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16)
                            )
                          ),
                          child: AddressSearchSheet(polygon: polygon)),
                      );
                    },
                  );

              if (selectedSuggestion != null) {
                controller.text = selectedSuggestion.formattedAddress;
                onAddressSelected(selectedSuggestion);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                style: productNameText.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'адрес',
                  hintStyle: productNameText.copyWith(fontSize: 14),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isInside
                      ? () {
                        if (suggestion != null) {
                          context.push(
                            RouteNames.addressDetails,
                            extra: {
                              'address': suggestion,
                              'bloc': context.read<AddressBloc>(),
                            },
                          );
                        } else {
                          showTopSnackbar(
                            context: context,
                            message: 'Адрес выберите сначала',
                            isError: true,
                            vsync:
                                context
                                    .findAncestorStateOfType<
                                      _MapScreenState
                                    >()!, // или передать vsync через конструктор
                            withLove: false,
                          );
                        }
                      }
                      : () {},

              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                overlayColor: Colors.transparent,
                enableFeedback: false,
                elevation: 0,
                backgroundColor:
                    isInside ? Gradients.primary : Color(0xFFd4f2d6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                AppLocalizations.of(context)!.deliveryHere,
                style: GoogleFonts.montserrat(
                  color: isInside ? Colors.white : const Color(0xFFa9e4ac),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressSearchSheet extends StatefulWidget {
  final Polygon polygon;

  const AddressSearchSheet({super.key, required this.polygon});

  @override
  State<AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<AddressSearchSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final query = _controller.text;
      final geometry = Geometry.fromPolygon(widget.polygon);
      context.read<AddressBloc>().add(SearchAddressChanged(query, geometry));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: mainText
                  // .copyWith(fontWeight: FontWeight.bold)
                  ,
                  decoration: InputDecoration(
                    hintText: 'адрес',
                    hintStyle: hint.copyWith(fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.borderGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return  Center(child: LoadingAnimationWidget.waveDots(color: Gradients.primary, size: 30));
                      }
                      if (state is SearchSuccess) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: state.addresses.length,
                          itemBuilder: (context, index) {
                            final suggestion = state.addresses[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 200 + index * 100),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: child,
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text(
                                    suggestion.formattedAddress,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, suggestion);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                      // Color color = Gradients.primary;
                      // double size = 30;
                      
                      //   return  Center(child: LoadingAnimationWidget
                      //   // .twistingDots(color: color, size: size));
                      //   .waveDots(color: color, size: size));

                        // .twoRotatingArc(
                        //   rightDotColor: Colors.amber, 
                         
                        //   leftDotColor: Gradients.primary, 
                        //   size: 30));

                      return ListView(
                        controller: scrollController,
                        children: const [],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}