import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/barter_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/family_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/friend_track_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/tukar_proteksi_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// "Saya Memantau": satu layar, satu pertanyaan → "Orang terdekatku aman nggak?"
///
/// Urutan sengaja dibuat dari yang paling penting:
/// 1. Ringkasan status (sekali lihat langsung tahu)
/// 2. Siapa yang sedang berjalan (butuh perhatian)
/// 3. Siapa yang sudah aman di rumah
/// 4. Tambah teman pantau (aksi sekunder, paling bawah)
class PantauScreen extends StatelessWidget {
  const PantauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Saya Memantau'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: const [
          _SummaryHero(),
          SizedBox(height: 12),
          BarterCard(),
          SizedBox(height: 24),
          AjSectionTitle('Sedang Berjalan'),
          FriendTrackCard(),
          SizedBox(height: 24),
          AjSectionTitle('Sudah di Rumah'),
          FamilyCard(),
          SizedBox(height: 24),
          TukarProteksiCard(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Ringkasan status
// ─────────────────────────────────────────────────────────────

class _SummaryHero extends StatelessWidget {
  const _SummaryHero();

  @override
  Widget build(BuildContext context) {
    const soft = Color(0xCCFFFFFF);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LiveUpdate(),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Semua orang terdekatmu aman', style: Aj.h(19, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 6),
          Text('1 sedang dalam perjalanan pulang, 1 sudah di rumah.', style: Aj.b(12.5, color: soft, height: 1.3)),
          const SizedBox(height: 14),
          const Row(
            children: [
              _Count('1', 'Berjalan'),
              SizedBox(width: 8),
              _Count('1', 'Di rumah'),
              SizedBox(width: 8),
              _Count('0', 'Butuh bantuan'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String value;
  final String label;
  const _Count(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: Aj.h(22, color: Colors.white)),
            const SizedBox(height: 1),
            FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: Aj.b(11, color: const Color(0xCCFFFFFF), w: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}

class _LiveUpdate extends StatefulWidget {
  const _LiveUpdate();

  @override
  State<_LiveUpdate> createState() => _LiveUpdateState();
}

class _LiveUpdateState extends State<_LiveUpdate> {
  int _s = 12;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _s = _s >= 29 ? 3 : _s + 1);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF6FE3A5), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('Live • diperbarui $_s dtk lalu', style: Aj.b(11.5, color: const Color(0xCCFFFFFF), w: FontWeight.w700)),
      ],
    );
  }
}