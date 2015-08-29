# Copyright 2013-2015 Pervasive Displays, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#   http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.  See the License for the specific language
# governing permissions and limitations under the License.


import sys
import os
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont
from EPD import EPD

import netifaces as ni


WHITE = 1
BLACK = 0

# fonts are in different places on Raspbian/Angstrom so search
possible_fonts = [
    '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono-Bold.ttf',   # R.Pi
    '/usr/share/fonts/truetype/freefont/FreeMono.ttf',                # R.Pi
    '/usr/share/fonts/truetype/LiberationMono-Bold.ttf',              # B.B
    '/usr/share/fonts/truetype/DejaVuSansMono-Bold.ttf'               # B.B
]


FONT_FILE = ''
for f in possible_fonts:
    if os.path.exists(f):
        FONT_FILE = f
        break

if '' == FONT_FILE:
    raise 'no font file found'

FONT_SIZE = 20

MAX_START = 0xffff

epd = EPD()
epd.clear()

# initially set all white background
image = Image.new('1', epd.size, WHITE)

# prepare for drawing
draw = ImageDraw.Draw(image)
width, height = image.size

font = ImageFont.truetype(FONT_FILE, FONT_SIZE)

draw.rectangle((0, 0, width, height), fill=WHITE, outline=WHITE)

i = 0
for interface in ni.interfaces():
    try:
        draw.text((0, i*20), interface+": "+ni.ifaddresses(interface)[2][0]['addr'], fill=BLACK, font=font)
    except:
        draw.text((0, i*20), interface+": None", fill=BLACK, font=font)
    i += 1

# display image on the panel
epd.display(image)
epd.partial_update()

