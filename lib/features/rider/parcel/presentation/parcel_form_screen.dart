import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/validation/phone_input.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';
import 'package:mishwar/core/widgets/mw_country_chip.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_cubit.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';

typedef ParcelPhotoPicker = Future<Uint8List?> Function();
Future<Uint8List?> pickParcelPhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 75,
    maxWidth: 1024,
  );
  return file?.readAsBytes();
}

class ParcelFormScreen extends StatefulWidget {
  const ParcelFormScreen({
    required this.uid,
    this.picker = pickParcelPhoto,
    this.pickupAvailable = true,
    super.key,
  });
  final String uid;
  final bool pickupAvailable;
  final ParcelPhotoPicker picker;
  @override
  State<ParcelFormScreen> createState() => _ParcelFormScreenState();
}

class _ParcelFormScreenState extends State<ParcelFormScreen> {
  late PhoneCountry _country = PhoneCountry.fromRegion(
    WidgetsBinding.instance.platformDispatcher.locale.countryCode,
  );
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _photo() async {
    final cubit = context.read<ParcelFormCubit>();
    try {
      final bytes = await widget.picker();
      if (bytes != null && !cubit.isClosed) {
        await cubit.upload(widget.uid, bytes);
      }
    } on Object {
      if (!cubit.isClosed) cubit.photoFailed();
    }
  }

  Future<void> _continue() async {
    final cubit = context.read<ParcelFormCubit>();
    final parcel = cubit.validate(
      _name.text,
      _phone.text,
      _description.text,
      country: _country,
    );
    if (parcel == null) return;
    final pickup = await cubit.pickup();
    if (!mounted || pickup == null) return;
    final language = Localizations.localeOf(context).languageCode;
    final details = await context.push<PlaceDetails>(
      '/rider/search',
      extra: DestinationSearchParams(position: pickup, language: language),
    );
    if (!mounted || details == null) return;
    final label = context.l10n.currentLocation;
    var pickupStop = RideStop(name: label, address: label, location: pickup);
    if (!kIsWeb && widget.pickupAvailable) {
      final confirmed = await context.push<RideStop>(
        '/rider/pickup',
        extra: pickupStop,
      );
      if (!mounted || confirmed == null) return;
      pickupStop = confirmed;
    }
    await context.push<void>(
      '/rider/confirm',
      extra: RideDraft(
        parcel: parcel,
        pickup: pickupStop,
        dropoff: RideStop(
          name: details.name,
          address: details.address,
          location: details.location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.parcelTitle)),
    body: BlocBuilder<ParcelFormCubit, ParcelFormState>(
      builder: (context, state) => ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          MwTextField(
            label: context.l10n.parcelRecipient,
            controller: _name,
            maxLength: 40,
            enabled: !state.busy,
          ),
          SizedBox(height: AppSpacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                MwCountryChip(
                  country: _country,
                  enabled: !state.busy,
                  onChanged: (value) => setState(() => _country = value),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: MwTextField(
                    label: context.l10n.phoneLabel,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    inputFormatters: phoneFormatters(),
                    enabled: !state.busy,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          MwTextField(
            label: context.l10n.parcelDescription,
            controller: _description,
            minLines: 3,
            maxLines: 5,
            maxLength: 200,
            enabled: !state.busy,
          ),
          SizedBox(height: AppSpacing.md),
          MwListRow(
            icon: AppIcons.image,
            title: context.l10n.parcelPhoto,
            subtitle: state.photoPath == null
                ? context.l10n.parcelPhotoOptional
                : context.l10n.parcelPhotoUploaded,
            onTap: state.busy ? null : _photo,
          ),
          if (state.progress != null && state.busy)
            LinearProgressIndicator(value: state.progress),
          if (state.failure != null || state.invalid)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                state.invalid
                    ? context.l10n.parcelInvalid
                    : failureMessage(context, state.failure!),
                style: AppTextStyles.footnote.copyWith(
                  color: context.colors.negative,
                ),
              ),
            ),
          SizedBox(height: AppSpacing.lg),
          MwPrimaryButton(
            label: context.l10n.parcelContinue,
            isLoading: state.busy,
            onPressed: state.busy ? null : _continue,
          ),
        ],
      ),
    ),
  );
}
