WORK IN PROGRESS - DO NOT USE

![Project logo](https://github.com/Tw1ddle/Rectangle-Bin-Packing/blob/master/screenshots/bin_packing_logo.png?raw=true "Bin Packing Algorithms Logo")

2D rectangular bin packing algorithms for the Haxe [bin-packing haxelib](http://lib.haxe.org/p/bin-packing). Based on the C++ algorithms by [Jukka Jylänki](https://github.com/juj/RectangleBinPack).

Try it out now [in your browser](http://www.samcodes.co.uk/project/realtime-signed-distance-fields/).

## Features ##
* Include several fast approximate bin packing algorithms.
* "Occupancy rate" measure to compare performance.
* Configurable packing heuristics.

## Usage ##

Try the [demo](http://www.samcodes.co.uk/project/realtime-signed-distance-fields/) in your browser, which includes an option for generating packed textures. This particular demo requires WebGL support. Refer to the [demo code](https://github.com/Tw1ddle/Realtime-Signed-Distance-Fields).

Basic usage example:

```
TODO
```

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
* The haxelib supports every Haxe target, but has not been thoroughly tested or optimized for performance, especially on native targets.
* If you have any questions or suggestions then [get in touch](http://samcodes.co.uk/contact).