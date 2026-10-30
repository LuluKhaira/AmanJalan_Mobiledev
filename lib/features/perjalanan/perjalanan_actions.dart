import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/emergency/emergency_screen.dart';
import 'package:amanjalan/features/fake_call/fake_call_screen.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/screens/tracking_screen.dart';

// ─────────────────────────────────────────────────────────────
// Aksi bersama. SEMUA tombol Panggilan Palsu & SOS di fitur
// Perjalanan memanggil layar yang SUDAH ADA (FakeCallScreen &
// EmergencyScreen) lewat fungsi-fungsi ini — tidak ada layar baru.
// ─────────────────────────────────────────────────────────────

/// Transisi halus untuk semua layar perjalanan.
Route<T> pjRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

List<EmergencyRecipient> pjRecipients() {
  final guardians = GuardianStore.guardians.value;
  return [
    if (guardians.isNotEmpty)
      EmergencyRecipient(
        '${guardians.first.role} (Kontak Utama)',
        guardians.first.phone ?? '+62 812-3456-7890',
      ),
    const EmergencyRecipient('Layanan Polisi Terpadu', 'Panggilan 110'),
  ];
}

void pjOpenEmergency(BuildContext context) {
  HapticFeedback.heavyImpact();
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => EmergencyScreen(recipients: pjRecipients()),
    ),
  );
}

void pjOpenFakeCall(BuildContext context) {
  HapticFeedback.mediumImpact();
  final guardians = GuardianStore.guardians.value;
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => FakeCallScreen(
        callerName: guardians.isNotEmpty ? guardians.first.name : 'Ibu Nurhayati',
        guardianCount: guardians.length,
        emergencyRecipients: pjRecipients(),
      ),
    ),
  );
}

void pjShareLocation(BuildContext context) {
  HapticFeedback.selectionClick();
  final n = GuardianStore.guardians.value.length;
  ajSnack(context, 'Lokasi live dibagikan ke $n Guardian', icon: Icons.share_location_rounded);
}

/// Dipakai tombol "Mulai Jalan" di tab Peta: mulai perjalanan lalu buka tracking.
void pjStartFromMap(BuildContext context) {
  if (TripStore.active.value == null) {
    final d = kDestinations[0];
    PerjalananSession.mode.value = TravelMode.jalanKaki;
    TripStore.start(d);
  }
  Navigator.of(context).push(pjRoute(const TrackingScreen()));
}
