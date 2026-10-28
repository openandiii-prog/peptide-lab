#!/usr/bin/env bash
# Lays the chalk title over the headless shader render. Run after `npm run build` in og/.
cd "$(dirname "$0")/.."
F=og/fonts/CabinSketch-Bold.ttf
ffmpeg -y -loglevel error -i og-board.png -vf "\
drawtext=fontfile=$F:text='ROOM 214 · BIOCHEMISTRY':fontsize=26:fontcolor=0xb7c4b9:x=70:y=120,\
drawtext=fontfile=$F:text='Peptide':fontsize=150:fontcolor=0xf1efe6:x=64:y=160,\
drawtext=fontfile=$F:text='Lab 101':fontsize=150:fontcolor=0xf3d36b:x=64:y=310,\
drawtext=fontfile=$F:text='49 peptides · hormones · 3D molecules':fontsize=32:fontcolor=0xf1efe6:x=70:y=500" og-hero.png
