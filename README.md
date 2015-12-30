WORK IN PROGRESS

![Project logo](https://github.com/Tw1ddle/Rectangle-Bin-Packing/blob/master/screenshots/bin_packing_logo.png?raw=true "Bin Packing Algorithms Logo")

2D rectangular bin packing algorithms for the Haxe [bin-packing haxelib](http://lib.haxe.org/p/bin-packing). Based on several algorithms implemented in C++ by [Jukka Jylänki](https://github.com/juj/RectangleBinPack).

Try it out now [in your browser](http://www.samcodes.co.uk/project/realtime-signed-distance-fields/).

## Features ##
* Several fast, approximate bin packing algorithms with configurable heuristics.
* "Occupancy rate" measure to compare packing performance between algorithms.

## Usage ##

Try the [demo](http://www.samcodes.co.uk/project/realtime-signed-distance-fields/) in your browser, which includes an option for generating packed spritesheets. This particular demo requires WebGL support.

## Install ##

Get the Haxe library code here or through haxelib. 

Include it in your ```.hxml```
```
-lib bin-packing
```

Or add it to your ```Project.xml```:
```
<haxelib name="bin-packing" />
```

## Screenshots ##

![Screenshot](https://github.com/Tw1ddle/Rectangle-Bin-Packing/blob/master/screenshots/screenshot1.png?raw=true "Bin Packing Algorithm screenshot 1")

![Screenshot](https://github.com/Tw1ddle/Rectangle-Bin-Packing/blob/master/screenshots/screenshot2.png?raw=true "Bin Packing Algorithm screenshot 2")

## Notes ##
* Many of the original algorithms are ported from public domain C++ implementations by [Jukka Jylänki](https://github.com/juj/RectangleBinPack).
* For more information about the algorithms, see Jukka's [blog posts](http://clb.demon.fi/projects/even-more-rectangle-bin-packing) and [paper](http://clb.demon.fi/files/RectangleBinPack.pdf).
* The haxelib supports every Haxe target, but has not been thoroughly tested or optimized for performance yet, especially on native targets.
* If you have any questions or suggestions then [get in touch](http://samcodes.co.uk/contact).