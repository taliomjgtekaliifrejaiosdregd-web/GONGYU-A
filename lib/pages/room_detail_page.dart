import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gongyu_guanjia/models/room.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;
  final VoidCallback? onLoginRequired;
  const RoomDetailPage({super.key, required this.room, this.onLoginRequired});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheetDialog(room: widget.room),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF00C853),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFE0E0E0), child: Center(child: Icon(Icons.apartment, size: 80, color: const Color(0xFFBDBDBD)))),
                  Container(color: Colors.black.withOpacity(0.1)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _showShareSheet,
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 价格+标题
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\u00a5${room.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4, left: 4),
                            child: Text('元/月', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: room.isAvailable ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFFF9800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              room.statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: room.isAvailable ? const Color(0xFF10B981) : const Color(0xFFFF9800),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(room.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        children: [
                          _tag(room.typeLabel, const Color(0xFF2196F3)),
                          _tag('${room.area.toStringAsFixed(0)}m\u00b2', const Color(0xFF9E9E9E)),
                          _tag(room.layout, const Color(0xFF9E9E9E)),
                          _tag('${room.floor}/${room.totalFloors}\u5c42', const Color(0xFF9E9E9E)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 地址
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        room.address.isNotEmpty ? room.address : room.communityName,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                // 配套设施
                if (room.facilities.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('配套设施', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: room.facilities.map<Widget>((f) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(f, style: const TextStyle(fontSize: 12)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // 描述
                if (room.description != null && room.description!.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('房源描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(room.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF616161), height: 1.5)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // 房东信息
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('房东信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF00C853)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(room.landlordName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Text('个人房东', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse('tel:${room.landlordPhone}');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              icon: const Icon(Icons.phone),
              label: const Text('打电话'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00C853),
                side: const BorderSide(color: Color(0xFF00C853)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('预约看房', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

class _ShareSheetDialog extends StatelessWidget {
  final Room room;
  const _ShareSheetDialog({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('分享房源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ShareIcon(Icons.chat, '微信', const Color(0xFF07C160), () {}),
                _ShareIcon(Icons.group, '朋友圈', const Color(0xFF07C160), () {}),
                _ShareIcon(Icons.tag, 'QQ', const Color(0xFF1296DB), () {}),
                _ShareIcon(Icons.sms, '短信', const Color(0xFFFF9500), () async {
                  final uri = Uri.parse('sms:?body=${Uri.encodeComponent(room.title + "\n" + room.layout + " · " + room.area.toStringAsFixed(0) + "m\u00b2 \u00a5" + room.price.toStringAsFixed(0) + "/\u6708\n" + room.address + "\n\u70b9\u51fb\u67e5\u770b\u8be6\u60c5 \u2192")}');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }),
                _ShareIcon(Icons.link, '复制链接', const Color(0xFF6366F1), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('\u94fe\u63a5\u5df2\u590d\u5236'), behavior: SnackBarBehavior.floating),
                  );
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '\u00a5' + room.price.toStringAsFixed(0) + '/\u6708\n' + room.address + '\n\u70b9\u51fb\u67e5\u770b\u8be6\u60c5 \u2192',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u53d6\u6d88', style: TextStyle(fontSize: 15, color: Color(0xFF9E9E9E))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareIcon(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}
