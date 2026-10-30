import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/profile_store.dart';
import 'package:amanjalan/features/profile/screens/edit_name_screen.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

const _months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

/// INFORMASI AKUN (4/10)
class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Informasi Akun',
      children: [
        ValueListenableBuilder<ProfileData>(
          valueListenable: ProfileStore.data,
          builder: (context, p, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PfCard(
                  child: Row(
                    children: [
                      const PfAvatar(size: 66),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(19, color: Aj.plum)),
                            const SizedBox(height: 6),
                            AjPill(p.status, bg: Aj.blush, fg: Aj.plum, icon: ProfileStore.statusIcon(p.status), size: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const PfSectionLabel('Data Pribadi', sub: 'Ketuk ikon pensil untuk mengubah data kamu.'),
                PfGroup(
                  children: [
                    _row('Nama Lengkap', p.fullName, () => pfPush(context, const EditNameScreen())),
                    _row('Nama Panggilan', p.nickname.isEmpty ? '-' : p.nickname, () => pfPush(context, const EditNameScreen())),
                    _row('Email', p.email, () => _editText(context, 'Email', p.email, TextInputType.emailAddress, (v) {
                          if (!v.contains('@') || !v.contains('.')) {
                            ajSnack(context, 'Format email belum benar', icon: Icons.error_outline_rounded);
                            return false;
                          }
                          ProfileStore.update((x) => x.copyWith(email: v));
                          return true;
                        })),
                    _row('Nomor Telepon', p.phone, () => _editText(context, 'Nomor Telepon', p.phone, TextInputType.phone, (v) {
                          if (v.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
                            ajSnack(context, 'Nomor telepon terlalu pendek', icon: Icons.error_outline_rounded);
                            return false;
                          }
                          ProfileStore.update((x) => x.copyWith(phone: v));
                          return true;
                        })),
                    _row('Tanggal Lahir', p.birth, () => _pickBirth(context)),
                    _row('Jenis Kelamin', p.gender, () {
                      pfPickOne(
                        context,
                        title: 'Jenis Kelamin',
                        options: const ['Perempuan', 'Laki-laki'],
                        current: p.gender,
                        onPick: (v) => ProfileStore.update((x) => x.copyWith(gender: v)),
                      );
                    }),
                  ],
                ),
                const PfSectionLabel('Status Kamu', sub: 'Pilih yang paling sesuai. Bisa diganti kapan saja.'),
                PfGroup(
                  children: [
                    _row('Status', p.status, () => _pickStatus(context, p.status), icon: ProfileStore.statusIcon(p.status)),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _row(String label, String value, VoidCallback? onEdit, {IconData? icon}) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            if (icon != null) ...[
              PfIcon(icon, size: 38),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Aj.b(11.5, color: Aj.muted, w: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(value, style: Aj.b(14.5, w: FontWeight.w800)),
                ],
              ),
            ),
            if (onEdit != null)
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: Aj.blush, shape: BoxShape.circle),
                child: const Icon(Icons.edit_outlined, size: 16, color: Aj.berry),
              )
            else
              const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFCBBFD0)),
          ],
        ),
      ),
    );
  }

  void _pickStatus(BuildContext context, String current) {
    pfPickOne(
      context,
      title: 'Status Kamu',
      options: ProfileStore.statusOptions,
      current: current,
      onPick: (v) {
        if (v == 'Lainnya…') {
          _editText(context, 'Status', '', TextInputType.text, (t) {
            if (t.length < 3) {
              ajSnack(context, 'Tulis status minimal 3 huruf', icon: Icons.error_outline_rounded);
              return false;
            }
            ProfileStore.update((x) => x.copyWith(status: t));
            return true;
          });
        } else {
          ProfileStore.update((x) => x.copyWith(status: v));
          ajSnack(context, 'Status diubah jadi $v', icon: Icons.check_circle_rounded);
        }
      },
    );
  }

  Future<void> _pickBirth(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (d == null) return;
    ProfileStore.update((x) => x.copyWith(birth: '${d.day} ${_months[d.month - 1]} ${d.year}'));
  }

  void _editText(BuildContext context, String label, String current, TextInputType type, bool Function(String) onSave) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Ubah $label',
        child: _EditSheet(
          label: label,
          initial: current,
          type: type,
          onSave: (v) {
            if (onSave(v.trim())) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  final String label;
  final String initial;
  final TextInputType type;
  final ValueChanged<String> onSave;

  const _EditSheet({required this.label, required this.initial, required this.type, required this.onSave});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PfField(label: widget.label, controller: _c, maxLength: 60, keyboardType: widget.type, hint: widget.label == 'Status' ? 'Cth: Perawat, Freelancer' : null),
          const SizedBox(height: 8),
          PfPrimaryButton('Simpan', onTap: () => widget.onSave(_c.text)),
        ],
      ),
    );
  }
}