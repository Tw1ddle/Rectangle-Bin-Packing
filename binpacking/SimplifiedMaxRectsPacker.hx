package binpacking;
 
//	Implements MAXRECTS (maximal rectangles) bin packer algorithm
//	See: http://clb.demon.fi/projects/even-more-rectangle-bin-packing
//	Also see C++ implementations: https://github.com/juj/RectangleBinPack
// 
//	Author: Jukka Jylänki
//		- Original
//	
//	Author: Claus Wahlers
//		- Ported to ActionScript3
//	
//	Author: Tony DiPerna
//	    - Ported to HaXe, optimized
//		
//	Author: Sam Twidale
//		- Remove NME dependency, refactoring

class SimplifiedMaxRectsPacker implements IOccupancy {
	public var binWidth(default, null):Float;
	public var binHeight(default, null):Float;
	public var freeRectangles(default, null):Array<Rect>;
	private var areaUsed(default, null):Float;
		
	public function new(width:Float, height:Float):Void {
		binWidth = width;
		binHeight = height;
		freeRectangles = new Array<Rect>();
		freeRectangles.push(new Rect(0, 0, width, height));
		areaUsed = 0;
	}
	
	public function insert(width:Float, height:Float):Rect {
		var newNode = findPositionForNewNodeBestAreaFit(width, height);
		
		if (newNode == null) {
			return newNode;
		}
		
		var numRectanglesToProcess:Int = freeRectangles.length;
		var i = 0;
		while (i < numRectanglesToProcess) {
			if (splitFreeNode(freeRectangles[i], newNode)) {
				freeRectangles.splice(i, 1);
				--numRectanglesToProcess;
				--i;
			}
			i++;
		}
		
		pruneFreeList();
		
		return newNode;
	}
	
	private inline function findPositionForNewNodeBestAreaFit(width:Float, height:Float):Rect {
		var score = Math.POSITIVE_INFINITY;
		var areaFit:Float;
		var bestNode:Rect = new Rect();
		
		for(r in freeRectangles) {
			// Try to place the rectangle in upright (non-flipped) orientation
			if (r.width >= width && r.height >= height) {
				areaFit = r.width * r.height - width * height;
				if (areaFit < score) {
					bestNode.x = r.x;
					bestNode.y = r.y;
					bestNode.width = width;
					bestNode.height = height;
					score = areaFit;
				}
			}
		}
		
		if (bestNode.height != 0) {
			areaUsed += bestNode.width * bestNode.height;
			return bestNode;
		} else {
			return null;
		}
	}
	
	private function splitFreeNode(freeNode:Rect, usedNode:Rect):Bool {
		// Test with SAT if the rectangles even intersect
		if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x || usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y) {
			return false;
		}
		
		var newNode:Rect;
		
		if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x) {
			// New node at the top side of the used node
			if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height) {
				newNode = freeNode.clone();
				newNode.height = usedNode.y - newNode.y;
				freeRectangles.push(newNode);
			}
			// New node at the bottom side of the used node
			if (usedNode.y + usedNode.height < freeNode.y + freeNode.height) {
				newNode = freeNode.clone();
				newNode.y = usedNode.y + usedNode.height;
				newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
				freeRectangles.push(newNode);
			}
		}
		
		if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y) {
			// New node at the left side of the used node
			if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width) {
				newNode = freeNode.clone();
				newNode.width = usedNode.x - newNode.x;
				freeRectangles.push(newNode);
			}
			// New node at the right side of the used node
			if (usedNode.x + usedNode.width < freeNode.x + freeNode.width) {
				newNode = freeNode.clone();
				newNode.x = usedNode.x + usedNode.width;
				newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
				freeRectangles.push(newNode);
			}
		}
		
		return true;
	}

	private function pruneFreeList():Void {
		// Remove redundant rectangles
		var i = 0;
		var j = 0;
		var len = freeRectangles.length;
		var tmpRect:Rect;
		var tmpRect2:Rect;
		while (i < len) {
			j = i + 1;
			tmpRect = freeRectangles[i];
			while (j < len) {
				tmpRect2 = freeRectangles[j];
				if (isContainedIn(tmpRect, tmpRect2)) {
					freeRectangles.splice(i, 1);
					--i;
					--len;
					break;
				}
				if (isContainedIn(tmpRect2, tmpRect)) {
					freeRectangles.splice(j, 1);
					--len;
					--j;
				}
				j++;
			}
			i++;
		}
	}
	
	public function occupancy():Float {
		if (areaUsed == 0) {
			return 0;
		}
		
		return areaUsed / (binWidth * binHeight);
	}
	
	private inline function isContainedIn(a:Rect, b:Rect):Bool {
		return a.x >= b.x && a.y >= b.y	&& a.x + a.width <= b.x + b.width && a.y + a.height <= b.y + b.height;
	}
}