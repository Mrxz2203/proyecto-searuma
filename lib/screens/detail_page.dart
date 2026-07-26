import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/character_detail.dart';
import '../services/uma_api_service.dart';
import '../services/translation_service.dart';
import '../theme/app_colors.dart';

class DetailPage extends StatefulWidget {
  final int characterId;
  const DetailPage({super.key, required this.characterId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final UmaApiService _apiService = UmaApiService();
  final TranslationService _translationService = TranslationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  CharacterDetail? _character;
  bool _isLoading = true;
  bool _isTranslating = false;
  String? _error;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _apiService.fetchCharacterDetail(widget.characterId);
      setState(() {
        _character = detail;
        _isLoading = false;
        _isTranslating = true;
      });

      final translated = await Future.wait([
        _translationService.translateToSpanish(detail.profile),
        _translationService.translateToSpanish(detail.slogan),
        _translationService.translateToSpanish(detail.strengths),
        _translationService.translateToSpanish(detail.weaknesses),
      ]);

      if (mounted) {
        setState(() {
          _character = detail.copyWithTranslations(
            profile: translated[0],
            slogan: translated[1],
            strengths: translated[2],
            weaknesses: translated[3],
          );
          _isTranslating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleVoice() async {
    if (_character?.voiceUrl == null) return;

    if (_isPlayingVoice) {
      await _audioPlayer.stop();
      setState(() => _isPlayingVoice = false);
    } else {
      await _audioPlayer.play(UrlSource(_character!.voiceUrl!));
      setState(() => _isPlayingVoice = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingVoice = false);
      });
    }
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppColors.forestGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
            : _error != null
                ? _ErrorState(error: _error!, onRetry: _loadDetail)
                : _character == null
                    ? const SizedBox.shrink()
                    : _DetailContent(
                        key: ValueKey(_character!.id),
                        character: _character!,
                        accentColor: _parseColor(_character!.colorMain),
                        isPlayingVoice: _isPlayingVoice,
                        isTranslating: _isTranslating,
                        onToggleVoice: _toggleVoice,
                      ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.softOrange, size: 40),
          const SizedBox(height: 12),
          const Text('No se pudo cargar el personaje', style: TextStyle(color: AppColors.leatherBrown)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
            child: const Text('Reintentar', style: TextStyle(color: AppColors.warmWhite)),
          ),
        ],
      ),
    );
  }
}

/// Envuelve cualquier widget con una animación de entrada fade + slide hacia arriba.
/// El [delay] permite escalonar varias secciones para que no aparezcan todas
/// al mismo tiempo (efecto "cascada").
class _FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeInUp({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Botón genérico con hover: escala levemente y sube la sombra al pasar el mouse.
class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const _HoverButton({required this.child, required this.onPressed});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final CharacterDetail character;
  final Color accentColor;
  final bool isPlayingVoice;
  final bool isTranslating;
  final VoidCallback onToggleVoice;

  const _DetailContent({
    super.key,
    required this.character,
    required this.accentColor,
    required this.isPlayingVoice,
    required this.isTranslating,
    required this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FadeInUp(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _HoverButton(
                    onPressed: () => context.go('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: accentColor, size: 18),
                          const SizedBox(width: 6),
                          Text('Volver', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [accentColor.withValues(alpha: 0.18), accentColor.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
                      boxShadow: [
                        BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Hero(
                      tag: 'character-image-${character.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          character.thumbImg ?? character.detailImgPc ?? '',
                          height: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.pets, size: 80, color: accentColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _FadeInUp(
                delay: const Duration(milliseconds: 140),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        character.nameEn,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                      ),
                      Text(
                        character.nameJp,
                        style: TextStyle(fontSize: 16, color: AppColors.leatherBrown.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FadeInUp(
                delay: const Duration(milliseconds: 180),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      character.categoryLabelEn,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (character.slogan != null) ...[
                _FadeInUp(
                  delay: const Duration(milliseconds: 220),
                  child: Text(
                    '"${character.slogan}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: AppColors.leatherBrown),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (character.voiceUrl != null)
                _FadeInUp(
                  delay: const Duration(milliseconds: 260),
                  child: Center(
                    child: _HoverButton(
                      onPressed: onToggleVoice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isPlayingVoice
                              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.6), blurRadius: 16, spreadRadius: 2)]
                              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isPlayingVoice ? Icons.stop : Icons.volume_up, color: AppColors.darkBrown, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isPlayingVoice ? 'Detener' : 'Escuchar voz',
                              style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTranslating) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: accentColor)),
                    const SizedBox(width: 8),
                    Text('Traduciendo...', style: TextStyle(fontSize: 12, color: AppColors.leatherBrown.withValues(alpha: 0.7))),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              _FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.cake,
                        label: 'Cumpleaños',
                        value: character.birthdayFormatted,
                        accentColor: accentColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.category,
                        label: 'Altura',
                        value: character.height != null ? '${character.height} cm' : '—',
                        accentColor: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (character.weight != null)
                _FadeInUp(
                  delay: const Duration(milliseconds: 340),
                  child: _InfoCard(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso / Complexión',
                    value: character.weight!,
                    accentColor: accentColor,
                    fullWidth: true,
                  ),
                ),
              if (character.profile != null) ...[
                const SizedBox(height: 28),
                _FadeInUp(
                  delay: const Duration(milliseconds: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                      const SizedBox(height: 8),
                      Text(character.profile!, style: TextStyle(fontSize: 14, color: AppColors.leatherBrown, height: 1.6)),
                    ],
                  ),
                ),
              ],
              if (character.strengths != null || character.weaknesses != null) ...[
                const SizedBox(height: 28),
                _FadeInUp(
                  delay: const Duration(milliseconds: 420),
                  child: Row(
                    children: [
                      if (character.strengths != null)
                        Expanded(
                          child: _TraitBox(
                            icon: Icons.thumb_up_alt_outlined,
                            label: 'Fortaleza',
                            value: character.strengths!,
                            color: AppColors.emerald,
                          ),
                        ),
                      if (character.strengths != null && character.weaknesses != null) const SizedBox(width: 12),
                      if (character.weaknesses != null)
                        Expanded(
                          child: _TraitBox(
                            icon: Icons.thumb_down_alt_outlined,
                            label: 'Debilidad',
                            value: character.weaknesses!,
                            color: AppColors.softOrange,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    this.fullWidth = false,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovering ? -3.0 : 0.0, 0.0),
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.accentColor.withValues(alpha: _hovering ? 0.6 : 0.3)),
          boxShadow: _hovering
              ? [BoxShadow(color: widget.accentColor.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 6))]
              : [],
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.accentColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: TextStyle(fontSize: 12, color: AppColors.leatherBrown.withValues(alpha: 0.7))),
                  Text(widget.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitBox extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TraitBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  State<_TraitBox> createState() => _TraitBoxState();
}

class _TraitBoxState extends State<_TraitBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovering ? -3.0 : 0.0, 0.0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _hovering ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 16, color: widget.color),
                const SizedBox(width: 6),
                Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.color)),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.value, style: const TextStyle(fontSize: 13, color: AppColors.darkBrown)),
          ],
        ),
      ),
    );
  }
}