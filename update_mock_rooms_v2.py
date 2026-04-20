# -*- coding: utf-8 -*-
"""
Directly replace the rooms list in mock_service.dart with updated data
"""

with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find the rooms section boundaries
start_marker = "static final List<Room> rooms = ["
end_marker = "\n    ),\n  ];\n\n  static List<Room> getRoomsByType"

start_idx = data.find(start_marker)
end_idx = data.find(end_marker)

if start_idx < 0 or end_idx < 0:
    print(f"ERROR: start={start_idx}, end={end_idx}")
    exit(1)

print(f"Found rooms section: {start_idx} to {end_idx}")

new_rooms = '''static final List<Room> rooms = [
    Room(
      id: 1, title: '陆家嘴花园整租', type: RoomType.whole,
      address: '陆家嘴路199号1号楼1单元101', communityId: '1', communityName: '陆家嘴花园',
      building: '1号楼', unit: '1单元', roomNo: '101',
      floor: 1, totalFloors: 6, area: 85.5, layout: '2室1厅1卫', orientation: '南',
      price: 5800, deposit: 11600, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机', '冰箱', '宽带', '电视'],
      tenantName: '张先生', tenantPhone: '13912345678',
      rentExpireDate: '2024-06-30',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      ],
    ),
    Room(
      id: 2, title: '浦东大道合租', type: RoomType.shared,
      address: '浦东大道1000号2号楼2单元201', communityId: '2', communityName: '浦东大道公寓',
      building: '2号楼', unit: '2单元', roomNo: '201',
      floor: 2, totalFloors: 8, area: 45.0, layout: '3室1厅2卫', orientation: '南北',
      price: 3200, deposit: 6400, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机'],
      tenantName: '李女士', tenantPhone: '13823456789',
      rentExpireDate: '2024-03-15',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
      ],
    ),
    Room(
      id: 3, title: '前滩公寓', type: RoomType.whole,
      address: '前滩路88号3号楼301', communityId: '3', communityName: '前滩小区',
      building: '3号楼', unit: '', roomNo: '301',
      floor: 3, totalFloors: 5, area: 65.0, layout: '1室1厅1卫', orientation: '东南',
      price: 4500, deposit: 9000, status: RoomStatus.available,
      facilities: ['空调', '热水器', '冰箱'],
      isPublished: true,
      images: [
        'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
      ],
    ),
    Room(
      id: 4, title: '静安寺独栋', type: RoomType.building,
      address: '南京西路200号', communityId: '4', communityName: '静安公馆',
      floor: 1, totalFloors: 3, area: 200.0, layout: '5室3厅3卫', orientation: '南',
      price: 12000, deposit: 24000, status: RoomStatus.rented,
      facilities: ['中央空调', '地暖', '智能家居', '车位'],
      tenantName: '王总', tenantPhone: '13712345678',
      rentExpireDate: '2024-09-01',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&q=80',
      ],
    ),
    Room(
      id: 5, title: '徐家汇精品公寓', type: RoomType.whole,
      address: '漕溪北路88号汇翠花园4号楼401', communityId: '1', communityName: '汇翠花园',
      floor: 4, totalFloors: 10, area: 78.0, layout: '2室2厅1卫', orientation: '南',
      price: 6800, deposit: 13600, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机', '冰箱', '宽带'],
      tenantName: '陈小姐', tenantPhone: '13687654321',
      rentExpireDate: '2024-02-28',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&q=80',
        'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800&q=80',
        'https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?w=800&q=80',
      ],
    ),
    Room(
      id: 6, title: '新天地服务公寓', type: RoomType.whole,
      address: '马当路188号5号楼501', communityId: '2', communityName: '新天地',
      floor: 5, totalFloors: 12, area: 95.0, layout: '3室2厅2卫', orientation: '南北',
      price: 8500, deposit: 17000, status: RoomStatus.signing,
      facilities: ['中央空调', '地暖', '智能门锁', '管家服务'],
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
        'https://images.unsplash.com/photo-1615529182904-14819c35db37?w=800&q=80',
      ],
    ),
    Room(
      id: 7, title: '淮海路老公房', type: RoomType.shared,
      address: '淮海中路99号6号楼601', communityId: '3', communityName: '淮海路小区',
      floor: 6, totalFloors: 6, area: 35.0, layout: '2室1厅1卫', orientation: '东',
      price: 2800, deposit: 5600, status: RoomStatus.available,
      facilities: ['空调', '热水器'],
      isPublished: true,
      images: [
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
        'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&q=80',
      ],
    ),
    Room(
      id: 8, title: '虹口足球场旁整租', type: RoomType.whole,
      address: '西江湾路388号7号楼701', communityId: '4', communityName: '虹口花园',
      floor: 7, totalFloors: 9, area: 72.0, layout: '2室1厅1卫', orientation: '南',
      price: 5200, deposit: 10400, status: RoomStatus.reserved,
      facilities: ['空调', '热水器', '洗衣机', '宽带'],
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1484154218962-a197022b25ba?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=80',
      ],
    ),
  ];

  static List<Room> getRoomsByType'''

new_data = data[:start_idx] + new_rooms + data[end_idx + len(end_marker):]
print(f"Old size: {len(data)}, New size: {len(new_data)}")

with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'w', encoding='utf-8') as f:
    f.write(new_data)
print("Saved!")
