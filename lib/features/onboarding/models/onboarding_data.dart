class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

const onboardingPages = <OnboardingData>[
  OnboardingData(
    image: 'assets/images/onboarding/owl_map.png',
    title: 'Kenali\nJalur Aman',
    subtitle: 'Temukan rute aman dan titik penting di sekitar kampus Polibatam.',
  ),
  OnboardingData(
    image: 'assets/images/onboarding/owl_security.png',
    title: 'Laporkan\nJika Berbahaya',
    subtitle:
        'Gunakan fitur SOS dan laporkan kejadian darurat atau situasi mencurigakan.',
  ),
  OnboardingData(
    image: 'assets/images/onboarding/owl_shield.png',
    title: 'Bersama\nLebih Aman',
    subtitle:
        'Jadilah bagian dari komunitas AmanJalan untuk lingkungan kampus yang lebih aman.',
  ),
];