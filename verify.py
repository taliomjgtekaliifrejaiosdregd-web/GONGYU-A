# -*- coding: utf-8 -*-
data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')
print('L195:', repr(lines[194]), len(lines[194]), 'bytes', lines[194].count(b')'), 'parens')
print('L237:', repr(lines[236]), len(lines[236]), 'bytes', lines[236].count(b')'), 'parens')
print('L238:', repr(lines[237]), len(lines[237]), 'bytes')
