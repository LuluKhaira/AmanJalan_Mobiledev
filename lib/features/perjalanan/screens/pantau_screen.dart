import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/barter_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/family_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/friend_track_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/tukar_proteksi_card.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// "Saya Memantau": pantau orang-orang terdekat secara real-time.
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
          BarterCard(),
          SizedBox(height: 22),
          AjSectionTitle('Lingkar Pantau Saya', trailing: _LiveUpdate()),
          FriendTrackCard(),
          SizedBox(height: 14),
          FamilyCard(),
          SizedBox(height: 18),
          TukarProteksiCard(),
        ],
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
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF1F6B45), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('Update $_s dtk lalu', style: Aj.b(12, color: Aj.muted)),
      ],
    );
  }
}
