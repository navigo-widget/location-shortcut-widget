import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/expiry_utils.dart';
import 'package:navigo/utils/shortcut_icons.dart';

/// A senior-friendly tile with split tap zones:
/// - Top 75%: tap to edit, long-press for context menu (Edit / Share / Delete)
/// - Bottom 25%: tap to navigate via maps app
class ShortcutButton extends StatelessWidget {
  final LocationShortcut shortcut;
  final VoidCallback onNavigate;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const ShortcutButton({
    super.key,
    required this.shortcut,
    required this.onNavigate,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    shortcut.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Edit', style: TextStyle(fontSize: 17)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share', style: TextStyle(fontSize: 17)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onShare();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Delete',
                      style:
                          TextStyle(fontSize: 17, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = getShortcutIcon(shortcut.iconName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expiryStatus =
        computeExpiryStatus(shortcut.expiresAt, shortcut.createdAt);
    final tint = expiryTintColor(expiryStatus, isDark);

    return Card(
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ─── Top 75%: Edit zone (long-press for context menu) ─────
          Expanded(
            flex: 75,
            child: InkWell(
              onTap: onEdit,
              onLongPress: () => _showContextMenu(context),
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
              onTap: () {
                HapticFeedback.mediumImpact();
                onNavigate();
              },
              child: Container(
                color: iconData.color.withAlpha(isDark ? 60 : 20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 18,
                        color: isDark ? Colors.white : iconData.color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Navigate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : iconData.color,
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
