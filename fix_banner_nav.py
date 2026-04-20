# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

changed = 0

# Step 1: Update _BannerItem class to add viewRoute
old_banner_item = "class _BannerItem {\n  final String title;\n  final String subtitle;\n  final Color color1;\n  final Color color2;\n  final IconData icon;\n  final VoidCallback? onTap;\n\n  const _BannerItem(this.title, this.subtitle, this.color1, this.color2, this.icon, [this.onTap]);\n}"
new_banner_item = "class _BannerItem {\n  final String title;\n  final String subtitle;\n  final Color color1;\n  final Color color2;\n  final IconData icon;\n  final Widget? viewRoute;  // 立即查看跳转的目标页面\n\n  const _BannerItem(this.title, this.subtitle, this.color1, this.color2, this.icon, [this.viewRoute]);\n}"
if old_banner_item in data:
    data = data.replace(old_banner_item, new_banner_item)
    print('Updated _BannerItem class')
    changed += 1
else:
    print('ERROR: _BannerItem class not found!')
    print(repr(data[data.find('class _BannerItem'):data.find('class _BannerItem')+300]))
    import sys; sys.exit(1)

# Step 2: Update _BannerCard to add tappable "立即查看"
old_viewbtn = """                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                    child: const Text('立即查看', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
                  ),"""
new_viewbtn = """                  GestureDetector(
                    onTap: () {
                      if (banner.viewRoute != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => banner.viewRoute!));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        banner.viewRoute != null ? '立即查看' : '',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),"""
if old_viewbtn in data:
    data = data.replace(old_viewbtn, new_viewbtn)
    print('Updated _BannerCard view button')
    changed += 1
else:
    print('ERROR: _BannerCard view button not found!')
    # Search for it
    idx = data.find('Container(\n                    padding: const EdgeInsets.symmetric(horizontal: 10')
    print(f'Found at: {idx}')
    if idx >= 0:
        print(repr(data[idx:idx+300]))

# Step 3: Update banner items to specify viewRoute
# Banner 1: 新用户首月租金立减 → UtilityPaymentPage
old_b1 = """    _BannerItem(
      '新用户首月租金立减 ¥500',
      '认证即享优惠，快来体验吧',
      const Color(0xFF6366F1),
      const Color(0xFFA5B4FC),
      Icons.campaign,
      null,
    ),"""
new_b1 = """    _BannerItem(
      '新用户首月租金立减 ¥500',
      '认证即享优惠，快来体验吧',
      const Color(0xFF6366F1),
      const Color(0xFFA5B4FC),
      Icons.campaign,
      UtilityPaymentPage(tenantPhone: MockService.currentUser.phone),
    ),"""
if old_b1 in data:
    data = data.replace(old_b1, new_b1)
    print('Updated banner 1 (新用户租金立减)')
    changed += 1
else:
    print('ERROR: Banner 1 not found!')
    import sys; sys.exit(1)

# Banner 2: 押一付一 → ShoppingPage
old_b2 = """    _BannerItem(
      '押一付一房源特惠',
      '海量精选房源，租金月付无忧',
      const Color(0xFFEF4444),
      const Color(0xFFFF8A65),
      Icons.local_offer,
      null,
    ),"""
new_b2 = """    _BannerItem(
      '押一付一房源特惠',
      '海量精选房源，租金月付无忧',
      const Color(0xFFEF4444),
      const Color(0xFFFF8A65),
      Icons.local_offer,
      const ShoppingPage(),
    ),"""
if old_b2 in data:
    data = data.replace(old_b2, new_b2)
    print('Updated banner 2 (押一付一)')
    changed += 1
else:
    print('ERROR: Banner 2 not found!')
    import sys; sys.exit(1)

# Banner 3: 地铁沿线 → MapPage
old_b3 = """    _BannerItem(
      '地铁沿线房源推荐',
      '出门即地铁，通勤零压力',
      const Color(0xFF06B6D4),
      const Color(0xFF64B5F6),
      Icons.subway,
      null,
    ),"""
new_b3 = """    _BannerItem(
      '地铁沿线房源推荐',
      '出门即地铁，通勤零压力',
      const Color(0xFF06B6D4),
      const Color(0xFF64B5F6),
      Icons.subway,
      const MapPage(),
    ),"""
if old_b3 in data:
    data = data.replace(old_b3, new_b3)
    print('Updated banner 3 (地铁沿线)')
    changed += 1
else:
    print('ERROR: Banner 3 not found!')
    import sys; sys.exit(1)

# Banner 4: 精装修公寓 → RepairReportPage
old_b4 = """    _BannerItem(
      '精装修公寓集合',
      '品质生活，从这里开始',
      const Color(0xFF7B61FF),
      const Color(0xFFB39DDB),
      Icons.home_work,
      null,
    ),"""
new_b4 = """    _BannerItem(
      '精装修公寓集合',
      '品质生活，从这里开始',
      const Color(0xFF7B61FF),
      const Color(0xFFB39DDB),
      Icons.home_work,
      const RepairReportPage(),
    ),"""
if old_b4 in data:
    data = data.replace(old_b4, new_b4)
    print('Updated banner 4 (精装修公寓)')
    changed += 1
else:
    print('ERROR: Banner 4 not found!')
    import sys; sys.exit(1)

print(f'Total changes: {changed}')
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Saved!')
