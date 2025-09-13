import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/data/models/address.dart';
import 'package:maktub/presentation/user/blocs/address/address_bloc.dart';
import 'package:maktub/presentation/user/blocs/address/address_event.dart';
import 'package:maktub/presentation/user/blocs/address/address_state.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class AddressDetailsScreen extends StatefulWidget {
  final AddressSuggestion address;
  final BuildContext context;

  const AddressDetailsScreen({super.key, required this.address, required this.context});

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgAddressController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool isButtonEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _orgAddressController.text = widget.address.formattedAddress;

    _orgNameController.addListener(_validateFields);
    _commentController.addListener(_validateFields);
  }

  void _validateFields() {
    final isFilled =
        _orgNameController.text.trim().isNotEmpty &&
        _orgAddressController.text.trim().isNotEmpty;

    setState(() {
      isButtonEnabled = isFilled;
    });
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgAddressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitAddress() {
    List<double> coordinates = [
      widget.address.latitude,
      widget.address.longitude,
    ];
    Address address = Address(
      regionId: context.read<AppStateCubit>().state!.regionId,
      organizationId: context.read<AppStateCubit>().state!.workplaceId,
      nameOfPoint: _orgNameController.text.trim(),
      point: coordinates,
      commentForDelivery: _commentController.text.trim(),
      address: _orgAddressController.text.trim(),
    );
    String phone = context.read<AppStateCubit>().state!.phone;

    context.read<AddressBloc>().add(AddAddress(address: address, phone: phone));

    context.read<AddressBloc>().add(
      RegionChanged(regionId: address.regionId, phone: phone),
    );

    showTopSnackbar(
      context: context,
      message: AppLocalizations.of(widget.context)!.cityChanged,
      isError: false,
      vsync: this,
      withLove: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressAdding) {
          isLoading = true;
        } else if (state is AddressAddedSuccess) {
          isLoading = false;
        } else if (state is AddressFailure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.errorTryLater,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.fillAddressData,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 20),

                // Organization Name
                TextField(
                  controller: _orgNameController,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText:  AppLocalizations.of(context)!.organizationName,
                    hintStyle: hint,

                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
        
                const SizedBox(height: 16),

                // Organization Address
                TextField(
                  controller: _orgAddressController,
                  enabled: false,
                  readOnly: true,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: 'Ұйым адресі',
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.borderGray),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.borderGray),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Comment
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.pointDesc,
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
       
                const SizedBox(height: 20),

                // Button
                ElevatedButton(
                  onPressed:
                      isButtonEnabled && !isLoading ? _submitAddress : null,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      isButtonEnabled && !isLoading
                          ? Gradients.primary
                          : const Color(0xFFd4f2d6),
                    ),
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
                  child:
                      isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingAnimationWidget.waveDots(
                              color: Colors.white,
                              size: 25,
                            ),
                          )
                          : Text(
                            AppLocalizations.of(context)!.addAddress,
                            style: GoogleFonts.montserrat(
                              color:
                                  isButtonEnabled
                                      ? Colors.white
                                      : const Color(0xFFa9e4ac),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
