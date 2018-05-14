![Project logo](screenshots/bin_packing_logo.png?raw=true "Bin Packing Algorithms Logo")

2D rectangular bin packing algorithms for the Haxe [bin-packing haxelib](http://lib.haxe.org/p/bin-packing). Run the demo [in your browser](https://tw1ddle.github.io/Rectangle-Bin-Packing-Demo/index.html).

Based on the public domain C++ bin packers by [Jukka Jylänki](https://github.com/juj/RectangleBinPack).

## Features ##
* Several fast approximate bin packing algorithms.
* "Occupancy rate" measure to compare packing performance.
* Configurable packing heuristics.

## Usage ##

Run the [demo](https://tw1ddle.github.io/Rectangle-Bin-Packing-Demo/index.html) in your browser and refer to the [example code](https://github.com/Tw1ddle/Rectangle-Bin-Packing-Demo/).

Basic usage example:

```haxe
// Initialize a bin packer
var binWidth:Int = 800;
var binHeight:Int = 400;
var useWasteMap:Bool = true;
var packer = new SkylinePacker(binWidth, binHeight, useWasteMap);

// Start packing rectangles
var rectWidth:Int = 20;
var rectHeight:Int = 40;
var heuristic:LevelChoiceHeuristic = LevelChoiceHeuristic.MinWasteFit;
var rect:Rect = packer.insert(rectWidth, rectHeight, heuristic);

if(rect == null) {
	trace("Failed to pack rect");
} else {
	trace("Inserted rect at: " + Std.string(rect.x) + "," + Std.string(rect.y));
}
```

## Install ##

Get the Haxe library code here or via haxelib.

Include it in your ```.hxml```
```
-lib bin-packing
```

Or add it to your ```Project.xml```:
```
<haxelib name="bin-packing" />
```

## Screenshots ##
Screenshots of the [demo](https://github.com/Tw1ddle/Rectangle-Bin-Packing-Demo/):

![Screenshot](https://github.com/Tw1ddle/Rectangle-Bin-Packing-Demo/screenshots/screenshot1.png?raw=true "Bin Packing Algorithms screenshot 1")

![Screenshot](https://github.com/Tw1ddle/Rectangle-Bin-Packing-Demo/screenshots/screenshot2.png?raw=true "Bin Packing Algorithms screenshot 2")

## Notes ##
* The algorithms in this haxelib are ported from public domain C++ code by [Jukka Jylänki](https://github.com/juj/RectangleBinPack).
* For details about the algorithms, see Jukka's [blog posts](http://clb.demon.fi/projects/even-more-rectangle-bin-packing) and [paper](http://clb.demon.fi/files/RectangleBinPack.pdf).
* If you have any questions or suggestions then [get in touch](http://samcodes.co.uk/contact).
