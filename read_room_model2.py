with open(r'D:\Projects\gongyu_guanjia\lib\models\room.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()
with open(r'D:\Projects\gongyu_guanjia\room_model_out.txt', 'w', encoding='utf-8') as out:
    out.write(data)
print("Done")
