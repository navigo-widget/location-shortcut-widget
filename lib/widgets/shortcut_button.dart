import 'package:flutter/material.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/expiry_utils.dart';
import 'package:navigo/utils/shortcut_icons.dart';

/// A senior-friendly tile with split tap zones:
/// - Top 75%: tap to edit the shortcut
/// - Bottom 25%: tap to navigate via Google Maps
class ShortcutButton extends StatelessWidget {
  final LocationShortcut shortcut;
  final VoidCallback onNavigate;
  final VoidCallback onEdit;

  const ShortcutButton({
    super.key,
    required this.shortcut,
    required this.onNavigate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = getShortcutIcon(shortcut.iconName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expiryStatus =
        computeExpiryStatus(shortcut.expiresAt, shortcut.createdAt);
    final tint = expiryTintColor(expiryStatus, isDark);

    return Card(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ─── Top 75%: Edit zone ─────────────────────────
          Expanded(
            flex: 75,
            child: InkWell(
              onTap: onEdit,
              child: Stack(
                children: [
                  // Background tint for expiry warning
                  if (tint != null)
                    Positioned.fill(child: ColoredBox(color: tint)),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Colorful icon circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                iconData.color,
                                iconData.color.withAlpha(180),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: iconData.color.withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            iconData.icon,
                            size: 32,
                            color: Colors.white,
                            semanticLabel: shortcut.label,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Label
                        Text(
                          shortcut.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Expiry badge — top-right corner
                  if (expiryStatus != ExpiryStatus.none)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: _ExpiryBadge(
                        status: expiryStatus,
                        expiresAt: shortcut.expiresAt!,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Bottom 25%: Navigate zone ──────────────────
          Expanded(
            flex: 25,
            child: InkWell(
              onTap: onNavigate,
              child: Container(
                color: iconData.color.withAlpha(isDark ? 40 : 20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 18,
                        color: iconData.color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Navigate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: iconData.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final ExpiryStatus status;
  final DateTime expiresAt;

  const _ExpiryBadge({required this.status, required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final badgeColor = expiryBadgeColor(status);
    final text = expiryBadgeText(expiresAt);
    final icon = status == ExpiryStatus.urgent
        ? Icons.warning_rounded
        : Icons.schedule_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
