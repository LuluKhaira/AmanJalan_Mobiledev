import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/profile_store.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// EDIT NAMA (2/10)
class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late final TextEditingController _name = TextEditingController(text: pfNow.fullName);
  late final TextEditingController _nick = TextEditingController(text: pfNow.nickname);

  bool get _valid => _name.text.trim().length >= 2;
  bool get _dirty => _name.text.trim() != pfNow.fullName || _nick.text.trim() != pfNow.nickname;

  @override
  void dispose() {
    _name.dispose();
    _nick.dispose();
    super.dispose();
  }

  void _save() {
    ProfileStore.update((p) => p.copyWith(fullName: _name.text.trim(), nickname: _nick.text.trim()));
    ajSnack(context, 'Nama berhasil diperbarui', icon: Icons.check_circle_rounded);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Edit Nama',
      footer: PfPrimaryButton('Simpan', onTap: _valid && _dirty ? _save : null),
      children: [
        const SizedBox(height: 8),
        Center(
          child: PfAvatar(
            size: 128,
            camera: true,
            onTap: () => ajSnack(context, 'Ganti foto profil segera hadir', icon: Icons.photo_camera_outlined),
          ),
        ),
        const SizedBox(height: 28),
        PfField(label: 'Nama Lengkap', controller: _name, maxLength: 50, hint: 'Nama sesuai identitas', onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        PfField(label: 'Nama Panggilan (Opsional)', controller: _nick, maxLength: 20, hint: 'Cth: Puja', onChanged: (_) => setState(() {})),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline_rounded, size: 15, color: Aj.berry),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nama panggilan dipakai untuk sapaan di Beranda dan terlihat oleh Guardian-mu.',
                style: Aj.b(12, color: Aj.muted, height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}