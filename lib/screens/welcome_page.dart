import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/feature_card.dart';
import '../widgets/nav_bar.dart';
import '../theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 500;
      if (shouldShow != _showBackToTop) {
        setState(() => _showBackToTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SearUmaNavBar(
              onInicioTap: () => _scrollTo(_heroKey),
              onCaracteristicasTap: () => _scrollTo(_featuresKey),
              onAcercaDeTap: () => _scrollTo(_aboutKey),
            ),
            _HeroSection(key: _heroKey, onVerMasTap: () => _scrollTo(_featuresKey)),
            _HowToUseSection(key: _featuresKey),
            _AboutFooterSection(key: _aboutKey),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showBackToTop ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_showBackToTop,
          child: FloatingActionButton(
            onPressed: _scrollToTop,
            backgroundColor: AppColors.forestGreen,
            child: const Icon(Icons.arrow_upward, color: AppColors.warmWhite),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatefulWidget {
  final VoidCallback onVerMasTap;
  const _HeroSection({super.key, required this.onVerMasTap});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, height: 1.15),
            children: [
              TextSpan(text: 'Encuentra a tu\n', style: TextStyle(color: AppColors.darkBrown)),
              TextSpan(text: 'Uma Musume', style: TextStyle(color: AppColors.forestGreen)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Busca, descubre y conoce a todas tus Uma Musume favoritas. SearUma te espera.',
          style: TextStyle(fontSize: 16, color: AppColors.leatherBrown, height: 1.5),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.darkBrown,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('✨ ¡Comenzar!'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: widget.onVerMasTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkBrown,
                side: const BorderSide(color: AppColors.darkBrown, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Ver más'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.pets, size: 18, color: AppColors.oliveGreen),
            const SizedBox(width: 8),
            Text(
              '+150 Uma Musume disponibles para explorar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.leatherBrown,
              ),
            ),
          ],
        ),
      ],
    );

    final bannerImage = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/nicenature.webp',
          fit: BoxFit.contain,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: textColumn),
                        const SizedBox(width: 32),
                        Expanded(flex: 4, child: bannerImage),
                      ],
                    )
                  : Column(
                      children: [
                        textColumn,
                        const SizedBox(height: 40),
                        bannerImage,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HowToUseSection extends StatelessWidget {
  const _HowToUseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightGreen.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          const Text(
            '¿Cómo funciona?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: const [
              FeatureCard(
                icon: Icons.search,
                title: 'Busca',
                description: 'Escribe cualquier letra o nombre y filtra al instante entre todas las Uma Musume.',
              ),
              FeatureCard(
                icon: Icons.list_alt,
                title: 'Explora',
                description: 'Navega la lista completa organizada en páginas, sin saturar la pantalla.',
              ),
              FeatureCard(
                icon: Icons.info_outline,
                title: 'Detalles',
                description: 'Toca cualquier personaje para ver toda su información a fondo.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutFooterSection extends StatelessWidget {
  const _AboutFooterSection({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: AppColors.darkBrown,
      child: Column(
        children: [
          const Text(
            'Acerca de SearUma',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warmWhite),
          ),
          const SizedBox(height: 12),
          Text(
            'Proyecto personal hecho con Flutter, para practicar y explorar el mundo de Uma Musume: Pretty Derby.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.lightGreen.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(
                icon: Icons.code,
                label: 'GitHub',
                onTap: () => _openUrl('https://github.com/Mrxz2203'),
              ),
              _FooterLink(
                icon: Icons.person,
                label: 'LinkedIn',
                onTap: () => _openUrl(
                  'https://www.linkedin.com/in/jarold-gabriel-garcia-cartagena-54b80b20b/',
                ),
              ),
              _FooterLink(
                icon: Icons.storage,
                label: 'Datos: Umapyoi.net',
                onTap: () => _openUrl('https://umapyoi.net'),
              ),
              const _FooterBadge(
                icon: Icons.flutter_dash,
                label: 'Hecho con Flutter',
              ),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: AppColors.leatherBrown.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            '© 2026 SearUma — Proyecto personal sin fines de lucro',
            style: TextStyle(color: AppColors.lightGreen.withValues(alpha: 0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.icon, required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.forestGreen.withValues(alpha: 0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: AppColors.lightGreen),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(color: AppColors.warmWhite, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.lightGreen),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.warmWhite, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}