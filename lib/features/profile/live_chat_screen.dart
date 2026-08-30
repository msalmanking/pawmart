import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();
  final _controller = TextEditingController();

  // TODO: replace with the client's real WhatsApp Business number
  // (country code, no + or spaces, e.g. 971501234567)
  static const _whatsappNumber = '03439302580';

  Future<void> _openWhatsApp(String message) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_whatsappNumber?text=$encoded');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _openWhatsApp(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 20, 14),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(children: [
                IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => Navigator.of(context).maybePop()),
                Stack(children: [
                  CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.accent2_200,
                      child: Text('A',
                          style: AppText.heading(
                              size: 14, color: AppColors.accent2_800))),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                            color: AppColors.accent2,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bg, width: 2))),
                  ),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Aisha — PawMart care',
                          style:
                              AppText.body(size: 15, weight: FontWeight.w700)),
                      Text('Online · replies in ~1 min',
                          style: AppText.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.accent2_700)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _openWhatsApp('Hi, I need help.'),
                  child: const Icon(LucideIcons.phone,
                      size: 19, color: AppColors.neutral600),
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                children: [
                  Center(
                      child: Text('Today',
                          style: AppText.body(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.neutral500))),
                  const SizedBox(height: 12),
                  _bubble(
                      "Hi! 🐾 I'm Aisha from PawMart care. How can I help you and your pet today?",
                      fromMe: false),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    GestureDetector(
                      onTap: () =>
                          _openWhatsApp("Hi, I'd like an update on my order."),
                      child: const AppTag(
                          label: 'Track my order',
                          variant: TagVariant.outline,
                          dense: true),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _openWhatsApp("Hi, I'd like to return an item."),
                      child: const AppTag(
                          label: 'Return an item',
                          variant: TagVariant.outline,
                          dense: true),
                    ),
                    GestureDetector(
                      onTap: () => _openWhatsApp(
                          "Hi, I'd like some food advice for my pet."),
                      child: const AppTag(
                          label: 'Food advice',
                          variant: TagVariant.outline,
                          dense: true),
                    ),
                  ]),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  22, 12, 22, 12 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                  color: AppColors.neutral100,
                  border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(children: [
                const Icon(LucideIcons.camera,
                    size: 20, color: AppColors.neutral600),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.divider)),
                    child: TextField(
                      controller: _controller,
                      style: AppText.body(size: 14),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: 'Type a message…',
                        hintStyle:
                            AppText.body(size: 14, color: AppColors.neutral500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.send,
                          size: 19, color: AppColors.bg)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(String text, {required bool fromMe}) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(fromMe ? 24 : 6),
            bottomRight: Radius.circular(fromMe ? 6 : 24),
          ),
        ),
        child: Text(text,
            style: AppText.body(
                size: 13.5,
                height: 1.5,
                color: fromMe ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}
