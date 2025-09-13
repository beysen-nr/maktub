import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/address.dart';
import 'package:maktub/presentation/user/blocs/address/address_bloc.dart';
import 'package:maktub/presentation/user/blocs/address/address_state.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/address/address_event.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:go_router/go_router.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final workplaceId = context.read<AppStateCubit>().state!.workplaceId;

    context.read<AddressBloc>().add(LoadAddresses(workplaceId));
  }

  void _onAddressSelected(Address address) {
    final currentRegionId = context.read<AppStateCubit>().state!.regionId;
    final phone = context.read<AppStateCubit>().state!.phone;
    if (address.regionId != currentRegionId) {
      // Регион другой — надо обновить AppState полностью

      context.read<AppStateCubit>().updateRegion(address.regionId);
              context.read<AddressBloc>().add(RegionChanged(regionId: address.regionId, phone: phone));
     
      showTopSnackbar(
        context: context,
        message: 'қала ауысты',
        isError: false,
        vsync: this,
        withLove: false,
      );
     
    }

    // Можно здесь вызвать смену текущего адреса если нужно, например:
    context.read<AppStateCubit>().updateSelectedAddress(address);

    context.pop(); // закрыть экран выбора адреса
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(
                            3.1416,
                          ), // π радиан = 180 градусов
                          child: Image.asset(
                            'assets/icons-system/arrow.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8),
                    child: Text(
                      AppLocalizations.of(context)!.chooseAddress,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    if (state is AddressLoading) {
                      return Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: Gradients.primary,
                          size: 30,
                        ),
                      );
                    }

                    if (state is AddressLoaded) {
                      if (state.addresses.isEmpty) {
                        return  Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/ohh.png',
                                width: 50, height: 50),
                            Text(AppLocalizations.of(context)!.noAddress,
                                style: mainText.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),

                          ],
                        ));
                      }

return ListView.builder(
  itemCount: state.addresses.length,
  itemBuilder: (context, index) {
    final address = state.addresses[index];
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + index * 100), // <<< можно чуть задержку
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20), // Плавный подъём
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _onAddressSelected(address),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Gradients.borderGray),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.nameOfPoint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.address,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Gradients.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 10,
            child: GestureDetector(
              onTap: () {
                context.read<AddressBloc>().add(
                  DeleteAddress(
                    addressId: address.addressId!,
                    organizationId: address.organizationId,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Gradients.textGray,
                ),
              ),
            ),
          ),
        
        ],
      ),
    );
  },
);
 }

                    if (state is AddressError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// КНОПКА "Добавить адрес"
              ElevatedButton(
                onPressed: () async {
                  final result = await context.push(
                    RouteNames.map,
                  ); // Переход на карту

                  if (result == true) {
                    final workplaceId =
                        context.read<AppStateCubit>().state!.workplaceId;
                    context.read<AddressBloc>().add(LoadAddresses(workplaceId));
                  }
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Gradients.primary),
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 50),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  AppLocalizations.of(context)!.addAddress,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),

              const SizedBox(height: 20), // Отступ внизу
            ],
          ),
        ),
      ),
    );
  }
}
