import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/character.dart';
import '../theme/app_colors.dart';

class CharacterTile extends StatefulWidget {
  final Character character;
  const CharacterTile({super.key, required this.character});

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  bool _hovering = false;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.forestGreen;
    final cleaned = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppColors.forestGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _parseColor(widget.character.colorMain);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go('/detail/${widget.character.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovering ? -4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovering ? 0.12 : 0.05),
                blurRadius: _hovering ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    color: accentColor.withValues(alpha: 0.12),
                    child: widget.character.thumbImg != null
                        ? Image.network(
                            widget.character.thumbImg!,
                            fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, color: accentColor, size: 40),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(color: accentColor, strokeWidth: 2),
                              );
                            },
                          )
                        : Icon(Icons.pets, color: accentColor, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.character.nameEn,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkBrown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}