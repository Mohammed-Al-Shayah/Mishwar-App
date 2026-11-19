import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/validation/phone_input.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';
import 'package:mishwar/core/widgets/mw_country_chip.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';
import 'package:mishwar/features/common/safety/presentation/safety_sheet.dart';
import 'package:mishwar/features/common/safety/presentation/trusted_contacts_cubit.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({this.driver = false, super.key});
  final bool driver;
  @override
  Widget build(BuildContext context) => driver
      ? Theme(data: AppTheme.dark(), child: const _SafetyBody())
      : const _SafetyBody();
}

class _SafetyBody extends StatelessWidget {
  const _SafetyBody();
  Future<void> _edit(BuildContext context, [TrustedContact? contact]) =>
      safetySheet<void>(
        context,
        contact == null ? context.l10n.contactAdd : context.l10n.contactEdit,
        BlocProvider.value(
          value: context.read<TrustedContactsCubit>(),
          child: _ContactEditor(contact: contact),
        ),
      );
  Future<void> _delete(BuildContext context, TrustedContact contact) async {
    final cubit = context.read<TrustedContactsCubit>();
    final confirmed = await safetySheet<bool>(
      context,
      context.l10n.contactDelete,
      Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.contactDeleteConfirm(contact.name)),
            SizedBox(height: AppSpacing.md),
            MwPrimaryButton(
              label: context.l10n.accountConfirm,
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.accountCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) await cubit.delete(contact.id);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TrustedContactsCubit, TrustedContactsState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text(context.l10n.safetyTitle)),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.loading) const LinearProgressIndicator(),
                  Expanded(
                    child: ListView(
                      children: [
                        Text(
                          context.l10n.trustedContacts,
                          style: context.textStyles.titleMedium,
                        ),
                        if (!state.loading && state.contacts.isEmpty) ...[
                          SizedBox(height: AppSpacing.md),
                          Text(context.l10n.contactsEmpty),
                          Text(
                            context.l10n.contactsExplanation,
                            style: context.textStyles.bodySmall,
                          ),
                        ],
                        for (final contact in state.contacts) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            minTileHeight: AppSizes.rowMinHeight,
                            leading: CircleAvatar(
                              radius: AppSizes.iconCircle / 2,
                              backgroundColor: context.colors.fill,
                              child: Icon(AppIcons.person, size: AppSizes.icon),
                            ),
                            title: Text(
                              contact.name,
                              style: context.textStyles.titleMedium,
                            ),
                            subtitle: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                contact.phone,
                                textDirection: TextDirection.ltr,
                                style: context.textStyles.bodySmall,
                              ),
                            ),
                            trailing: PopupMenuButton<bool>(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).moreButtonTooltip,
                              enabled: !state.saving,
                              onSelected: (delete) => delete
                                  ? _delete(context, contact)
                                  : _edit(context, contact),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: false,
                                  child: Text(context.l10n.contactEdit),
                                ),
                                PopupMenuItem(
                                  value: true,
                                  child: Text(
                                    context.l10n.contactDelete,
                                    style: TextStyle(
                                      color: context.colors.negative,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: state.saving
                                ? null
                                : () => _edit(context, contact),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: AppSizes.iconCircle + AppSpacing.sm,
                            ),
                            child: const Divider(),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xl),
                        Text(
                          context.l10n.emergencySettings,
                          style: context.textStyles.titleMedium,
                        ),
                        Text(
                          context.l10n.emergencyFootnote,
                          style: context.textStyles.bodySmall,
                        ),
                        if (state.contacts.length >= 5)
                          Text(
                            context.l10n.contactsLimit,
                            style: context.textStyles.bodySmall,
                          ),
                        if (state.failure != null)
                          Text(
                            failureMessage(context, state.failure!),
                            style: TextStyle(color: context.colors.negative),
                          ),
                      ],
                    ),
                  ),
                  MwPrimaryButton(
                    label: context.l10n.contactAdd,
                    onPressed:
                        state.loading ||
                            state.saving ||
                            state.contacts.length >= 5
                        ? null
                        : () => _edit(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _ContactEditor extends StatefulWidget {
  const _ContactEditor({this.contact});
  final TrustedContact? contact;
  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  late PhoneCountry _country = widget.contact?.phone.startsWith('+970') == true
      ? PhoneCountry.palestine
      : widget.contact != null
      ? PhoneCountry.jordan
      : PhoneCountry.fromRegion(
          WidgetsBinding.instance.platformDispatcher.locale.countryCode,
        );
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _phone = TextEditingController(
    text: widget.contact?.phone.replaceFirst(RegExp(r'^\+(962|970)'), '0'),
  );
  bool _invalid = false;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = normalizePhone(_phone.text, country: _country);
    if (phone == null ||
        _name.text.trim().isEmpty ||
        _name.text.trim().runes.length > 40) {
      setState(() => _invalid = true);
      return;
    }
    final saved = await context.read<TrustedContactsCubit>().save(
      TrustedContact(
        id: widget.contact?.id ?? '',
        name: _name.text.trim(),
        phone: phone,
      ),
    );
    if (mounted && saved) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TrustedContactsCubit, TrustedContactsState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MwTextField(
              label: context.l10n.contactName,
              controller: _name,
              enabled: !state.saving,
            ),
            SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: MwCountryChip(
                country: _country,
                enabled: !state.saving,
                onChanged: (value) => setState(() => _country = value),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            MwTextField(
              label: context.l10n.contactPhone,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: phoneFormatters(),
              enabled: !state.saving,
            ),
            if (_invalid)
              Text(
                context.l10n.contactInvalid,
                style: TextStyle(color: context.colors.negative),
              ),
            if (state.failure != null)
              Text(
                failureMessage(context, state.failure!),
                style: TextStyle(color: context.colors.negative),
              ),
            SizedBox(height: AppSpacing.md),
            MwPrimaryButton(
              label: context.l10n.accountSave,
              isLoading: state.saving,
              onPressed: _save,
            ),
          ],
        ),
      );
}
