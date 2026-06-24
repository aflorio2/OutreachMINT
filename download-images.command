#!/bin/bash
# Downloads the 7 Wikimedia images used by scales-quantum-cosmos.html
# and saves them next to this script with the local names the slide expects.
# (cell / virus / germany / bielfeld-gutersloh are already your own files.)
#
# Run: double-click this file, or in Terminal:  bash download-images.command

cd "$(dirname "$0")" || exit 1
UA="Mozilla/5.0 (outreach-lecture; scales slide)"
B="https://commons.wikimedia.org/wiki/Special:FilePath"

dl(){ echo "→ $2"; curl -fL -A "$UA" -o "$2" "$1" || echo "   FAILED: $2"; }

dl "$B/Da%20Vinci%20Vitruve%20Luc%20Viatour.jpg" human.jpg
dl "$B/Human%20Hair%2040x.JPG" hair.jpg
dl "$B/1GZX%20Haemoglobin.png" protein.png
dl "$B/Atomic%20resolution%20Au100.JPG" atom.jpg
dl "$B/The%20Earth%20seen%20from%20Apollo%2017.jpg" earth.jpg
dl "$B/FullMoon2010.jpg" moon.jpg
dl "$B/The%20Sun%20by%20the%20Atmospheric%20Imaging%20Assembly%20of%20NASA%27s%20Solar%20Dynamics%20Observatory%20-%2020100819.jpg" sun.jpg

echo "Done. Open scales-quantum-cosmos.html — all images are now local."
