import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/admin/presentation/admin_content_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/admin/presentation/admin_services.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});
  Future<void> _edit(BuildContext context, [AppBanner? banner]) =>
      showDialog<void>(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<AdminContentCubit>(),
          child: BannerEditor(banner: banner),
        ),
      );
  Future<void> _delete(BuildContext context, AppBanner banner) async {
    final cubit = context.read<AdminContentCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contentDeleteConfirm),
        content: Text(banner.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.contentCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.contentDelete,
              style: TextStyle(color: context.colors.negative),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.save('deleteBanner', {'id': banner.id});
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AdminContentCubit, AdminContentState>(
        builder: (context, state) => ListView(
          children: [
            if (state.failure != null)
              Text(
                context.l10n.adminError,
                style: AppTextStyles.footnote.copyWith(
                  color: context.colors.negative,
                ),
              ),
            if (state.loading) const LinearProgressIndicator(),
            AdminServices(state: state),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.contentBanners,
                    style: AppTextStyles.title2,
                  ),
                ),
                TextButton(
                  onPressed: state.busy ? null : () => _edit(context),
                  child: Text(context.l10n.contentAddBanner),
                ),
              ],
            ),
            if (!state.loading && state.banners.isEmpty)
              Text(context.l10n.adminEmpty),
            for (final banner in state.banners)
              Column(
                children: [
                  ListTile(
                    title: Text(banner.title),
                    subtitle: Text(adminDate(context, banner.validUntil)),
                    onTap: state.busy ? null : () => _edit(context, banner),
                    trailing: TextButton(
                      onPressed: state.busy
                          ? null
                          : () => _delete(context, banner),
                      child: Text(context.l10n.contentDelete),
                    ),
                  ),
                  const Divider(),
                ],
              ),
          ],
        ),
      );
}

class BannerEditor extends StatefulWidget {
  const BannerEditor({this.banner, super.key});
  final AppBanner? banner;
  @override
  State<BannerEditor> createState() => _BannerEditorState();
}

class _BannerEditorState extends State<BannerEditor> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.banner?.title);
  late final _subtitle = TextEditingController(text: widget.banner?.subtitle);
  late final _image = TextEditingController(text: widget.banner?.imageUrl);
  late final _target = TextEditingController(
    text: widget.banner?.promoCode ?? widget.banner?.url,
  );
  late final _order = TextEditingController(
    text: (widget.banner?.order ?? 0).toString(),
  );
  late BannerAction _action = widget.banner?.action ?? BannerAction.openSearch;
  late DateTime _until =
      widget.banner?.validUntil ?? DateTime.now().add(const Duration(days: 30));
  late bool _active = widget.banner?.active ?? true;
  @override
  void dispose() {
    for (final controller in [_title, _subtitle, _image, _target, _order]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _https(String value) {
    final uri = Uri.tryParse(value.trim());
    return value.trim().length <= 2048 &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<AdminContentCubit>().save('upsertBanner', {
      if (widget.banner != null) 'id': widget.banner!.id,
      'title': _title.text.trim(),
      'subtitle': _subtitle.text.trim(),
      'imageUrl': _image.text.trim(),
      'action': switch (_action) {
        BannerAction.openSearch => 'open_search',
        BannerAction.openPromo => 'open_promo',
        BannerAction.url => 'url',
      },
      if (_action == BannerAction.openPromo) 'promoCode': _target.text.trim(),
      if (_action == BannerAction.url) 'url': _target.text.trim(),
      'order': int.parse(_order.text.trim()),
      'validUntil': _until.toUtc().toIso8601String(),
      'active': _active,
    });
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AdminContentCubit, AdminContentState>(
    builder: (context, state) => AlertDialog(
      title: Text(
        widget.banner == null
            ? context.l10n.contentAddBanner
            : context.l10n.contentEditBanner,
      ),
      scrollable: true,
      content: SizedBox(
        width: AdminSizes.panel,
        child: AbsorbPointer(
          absorbing: state.busy,
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.failure != null)
                  Text(
                    context.l10n.adminError,
                    style: TextStyle(color: context.colors.negative),
                  ),
                _field(
                  _title,
                  context.l10n.contentTitle,
                  (v) => v.trim().isNotEmpty && v.trim().length <= 60,
                ),
                _field(
                  _subtitle,
                  context.l10n.contentSubtitle,
                  (v) => v.trim().length <= 120,
                ),
                _field(_image, context.l10n.contentImage, _https),
                DropdownButtonFormField<BannerAction>(
                  initialValue: _action,
                  decoration: InputDecoration(
                    labelText: context.l10n.contentAction,
                  ),
                  items: [
                    for (final action in BannerAction.values)
                      DropdownMenuItem(
                        value: action,
                        child: Text(switch (action) {
                          BannerAction.openSearch => context.l10n.contentSearch,
                          BannerAction.openPromo => context.l10n.contentPromo,
                          BannerAction.url => context.l10n.contentUrl,
                        }),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _action = value!;
                    _target.clear();
                  }),
                ),
                SizedBox(height: AppSpacing.md),
                if (_action != BannerAction.openSearch)
                  _field(
                    _target,
                    _action == BannerAction.openPromo
                        ? context.l10n.contentPromo
                        : context.l10n.contentUrl,
                    (v) => _action == BannerAction.url
                        ? _https(v)
                        : v.trim().isNotEmpty && v.trim().length <= 40,
                  ),
                _field(
                  _order,
                  context.l10n.contentOrder,
                  (v) => int.tryParse(v.trim()) != null,
                ),
                ListTile(
                  title: Text(context.l10n.contentValidUntil),
                  subtitle: Text(adminDate(context, _until)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _until.toLocal(),
                      firstDate: DateTime(1),
                      lastDate: DateTime(9999, 12, 31),
                    );
                    if (date != null && mounted) {
                      setState(
                        () => _until = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          23,
                          59,
                          59,
                        ),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  title: Text(context.l10n.contentActive),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.busy ? null : () => Navigator.pop(context),
          child: Text(context.l10n.contentCancel),
        ),
        FilledButton(
          onPressed: state.busy ? null : _save,
          child: state.busy
              ? const CircularProgressIndicator()
              : Text(context.l10n.contentSave),
        ),
      ],
    ),
  );
  Widget _field(
    TextEditingController controller,
    String label,
    bool Function(String) valid,
  ) => Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.md),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) => valid(v ?? '') ? null : context.l10n.contentInvalid,
    ),
  );
}
