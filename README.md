procsland
===========
A cellular automata based procedural hex island map generator.

## Usage
```
usage: procsland.rkt [ <option> ... ]
  procsland is an hex map island generator
  based on cellular automata.

<option> is one of

  -W <SCREEN-WIDTH>, --screen-width <SCREEN-WIDTH>
     width of the screen in pixels
  -H <SCREEN-HEIGHT>, --screen-height <SCREEN-HEIGHT>
     height of the screen in pixels
  -e <MAP-HEIGHT>, --map-height <MAP-HEIGHT>
     height of the map in (hex) tiles
  -w <MAP-WIDTH>, --map-width <MAP-WIDTH>
     width of the map in (hex) tiles
  -l <LAND-MASS>, --land-mass <LAND-MASS>
     probability for land tiles to appear
  -m <MOUNTAIN-MASS>, --mountain-mass <MOUNTAIN-MASS>
     probability for mountain tiles to appear
  -f <FOREST-MASS>, --forest-mass <FOREST-MASS>
     probability for forest tiles to appear
  -b <BEACH-MASS>, --beach-mass <BEACH-MASS>
     probability for beach tiles to appear
  -i <ITERATIONS>, --iterations <ITERATIONS>
     number of iterations of the cellular automata to perform
  --help, -h
     Show this help
  --
     Do not treat any remaining argument as a switch (at this level)

 Multiple single-letter switches can be combined after
 one `-`. For example, `-h-` is the same as `-h --`.
```
## Screenshot

![screenshot of procsland in action](resources/images/screenshot.png)

Tileset is a combination (and scaling) of [Basic Hex Tile Set - 16x16 by Dr. Jamgo](https://opengameart.org/content/basic-hex-tile-set-16x16) and [Basic Hex Tile Set Plus - 16x16 by pistachio](https://opengameart.org/content/basic-hex-tile-set-plus-16x16).
