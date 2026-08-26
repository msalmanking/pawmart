import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import 'address_providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Addresses'),
      body: addressesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: AppText.body(size: 13, color: AppColors.neutral600)),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.mapPin,
                      size: 48, color: AppColors.neutral400),
                  const SizedBox(height: 12),
                  Text('No addresses yet',
                      style: AppText.body(
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.neutral600)),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              for (final addr in addresses) ...[
                _AddressTile(address: addr, ref: ref),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: PillButton(
            label: '+ Add new address',
            height: 52,
            onTap: () => _showAddAddressSheet(context, ref),
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, required this.ref});
  final dynamic address;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: address.isDefault
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.accent100, shape: BoxShape.circle),
            child: const Icon(LucideIcons.mapPin,
                size: 18, color: AppColors.accent700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Text(address.label,
                      style: AppText.body(size: 14, weight: FontWeight.w700)),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    const AppTag(
                        label: 'Default',
                        variant: TagVariant.accentSoft,
                        dense: true),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(address.formatted,
                    style:
                        AppText.body(size: 12.5, color: AppColors.neutral600)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical,
                size: 18, color: AppColors.neutral600),
            onSelected: (value) async {
              if (value == 'default') await setDefaultAddress(ref, address.id);
              if (value == 'delete') await deleteAddress(ref, address.id);
            },
            itemBuilder: (context) => [
              if (!address.isDefault)
                const PopupMenuItem(
                    value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
  final labelController = TextEditingController(text: 'Home');
  final buildingController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController(text: 'Dubai');

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add address', style: AppText.heading(size: 22)),
                const SizedBox(height: 16),
                _field('Label (e.g. Home, Work)', labelController),
                const SizedBox(height: 12),
                _field('Building / Villa', buildingController),
                const SizedBox(height: 12),
                _field('Street', streetController),
                const SizedBox(height: 12),
                _field('Area', areaController),
                const SizedBox(height: 12),
                _field('City', cityController),
                const SizedBox(height: 24),
                PillButton(
                  label: 'Save address',
                  height: 52,
                  onTap: () async {
                    if (labelController.text.trim().isEmpty) return;
                    await addAddress(
                      ref,
                      label: labelController.text.trim(),
                      building: buildingController.text.trim(),
                      street: streetController.text.trim(),
                      area: areaController.text.trim(),
                      city: cityController.text.trim(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _field(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
