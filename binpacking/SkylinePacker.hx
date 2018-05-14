package binpacking;

import binpacking.Rect.DisjointRectCollection;
import binpacking.Rect.RectSize;
import binpacking.GuillotinePacker.GuillotineFreeRectChoiceHeuristic;
import binpacking.GuillotinePacker.GuillotineSplitHeuristic;

enum LevelChoiceHeuristic {
	BottomLeft;
	MinWasteFit;
}

private class SkylineNode {
	public var x:Int;
	public var y:Int;
	public var width:Int;
	
	public inline function new(x:Int, y:Int, width:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
	}
}

class SkylinePacker implements IOccupancy {
	public var binWidth(default, null):Int;
	public var binHeight(default, null):Int;
	private var usedSurfaceArea:Int;
	private var useWasteMap:Bool;
	private var wasteMap:GuillotinePacker;
	private var skyline:Array<SkylineNode>;
	
	#if debug
	private var disjointRects:DisjointRectCollection = new DisjointRectCollection();
	#end
	
	public function new(binWidth:Int, binHeight:Int, useWasteMap:Bool) {
		this.binWidth = binWidth;
		this.binHeight = binHeight;
		this.useWasteMap = useWasteMap;
		
		usedSurfaceArea = 0;
		skyline = new Array<SkylineNode>();
		var node = new SkylineNode(0, 0, binWidth);
		skyline.push(node);
		
		if (useWasteMap) {
			wasteMap = new GuillotinePacker(binWidth, binHeight);
			var rects = wasteMap.getFreeRectangles();
			rects = [];
		}
	}
	
	public function insert(width:Int, height:Int, method:LevelChoiceHeuristic):Rect {
		var node:Rect = wasteMap.insert(width, height, true, GuillotineFreeRectChoiceHeuristic.BestShortSideFit, GuillotineSplitHeuristic.MaximizeArea);
		
		if (node == null) {
			return null;
		}
		
		#if debug
		Sure.sure(disjointRects.disjoint(node));
		#end
		
		if (node.height != 0) {
			var newNode = new Rect(node.x, node.y, node.width, node.height);
			usedSurfaceArea += width * height;
			
			#if debug
			Sure.sure(disjointRects.disjoint(newNode));
			disjointRects.add(newNode);
			#end
			
			return newNode;
		}
		
		return switch(method) {
			case LevelChoiceHeuristic.BottomLeft: insertBottomLeft(width, height);
			case LevelChoiceHeuristic.MinWasteFit: insertMinWaste(width, height);
		}
	}
	
	public function occupancy():Float {
		var fUsedSurfaceArea = cast(usedSurfaceArea, Float);
		return fUsedSurfaceArea / (binWidth * binHeight);
	}
	
	private function insertBottomLeft(width:Int, height:Int):Rect {
		var data = findPositionForNewNodeBottomLeft(width, height);
		var bestHeight = data.bestHeight;
		var bestWidth = data.bestWidth;
		var bestIndex = data.bestIndex;
		var newNode = data.newNode;

		if (bestIndex != -1) {
			#if debug
			Sure.sure(disjointRects.disjoint(newNode));
			#end
			
			addSkylineLevel(bestIndex, newNode);

			usedSurfaceArea += width * height;
			
			#if debug
			disjointRects.add(newNode);
			#end
		}
		
		return null;
	}
	
	private function insertMinWaste(width:Int, height:Int):Rect {
		var data = findPositionForNewNodeMinWaste(width, height);
		var bestHeight = data.bestHeight;
		var bestIndex = data.bestIndex;
		var newNode = data.newNode;

		if (bestIndex != -1) {
			#if debug
			Sure.sure(disjointRects.disjoint(newNode));
			#end
			
			addSkylineLevel(bestIndex, newNode);

			usedSurfaceArea += width * height;
			
			#if debug
			disjointRects.add(newNode);
			#end
		}
		
		return newNode;
	}
	
	private function findPositionForNewNodeMinWaste(width:Int, height:Int): { newNode:Rect, bestHeight:Int, bestWastedArea:Int, bestIndex:Int } {
		var bestHeight = 0x3FFFFFFF;
		var bestWastedArea = 0x3FFFFFFF;
		var bestIndex = -1;
		var newNode = new Rect();
		
		for (i in 0...skyline.length) {
			var data = rectangleFitsWithWastedArea(i, width, height);
			var y = data.y;
			var wastedArea = data.wastedArea;
			var fits = data.fits;
			
			if (fits) {
				if (wastedArea < bestWastedArea || (wastedArea == bestWastedArea && y + height < bestHeight)) {
					bestHeight = y + height;
					bestWastedArea = wastedArea;
					bestIndex = i;
					newNode.x = skyline[i].x;
					newNode.y = y;
					newNode.width = width;
					newNode.height = height;
					
					#if debug
					Sure.sure(disjointRects.disjoint(newNode));
					#end
				}
			}
			
			data = rectangleFitsWithWastedArea(i, height, width);
			y = data.y;
			wastedArea = data.wastedArea;
			fits = data.fits;
			
			if (fits) {
				if (wastedArea < bestWastedArea || (wastedArea == bestWastedArea && y + width < bestHeight)) {
					bestHeight = y + width;
					bestWastedArea = wastedArea;
					bestIndex = i;
					newNode.x = skyline[i].x;
					newNode.y = y;
					newNode.width = height;
					newNode.height = width;
					newNode.flipped = !newNode.flipped;
					
					#if debug
					Sure.sure(disjointRects.disjoint(newNode));
					#end
				}
			}
		}
		
		return { newNode: newNode, bestHeight: bestHeight, bestWastedArea: bestWastedArea, bestIndex: bestIndex };
	}
	
	private function findPositionForNewNodeBottomLeft(width:Int, height:Int): { newNode: Rect, bestHeight:Int, bestWidth:Int, bestIndex:Int } {
		var bestHeight = 0x3FFFFFFF;
		var bestWidth = 0x3FFFFFFF;
		var bestIndex = -1;
		var newNode = new Rect();
		
		for (i in 0...skyline.length) {
			var data = rectangleFits(i, width, height);
			var fits = data.fits;
			var y = data.y;
			
			if (fits) {
				if (y + height < bestHeight || (y + height == bestHeight && skyline[i].width < bestWidth)) {
					bestHeight = y + height;
					bestIndex = i;
					bestWidth = skyline[i].width;
					newNode.x = skyline[i].x;
					newNode.y = y;
					newNode.width = width;
					newNode.height = height;
					
					#if debug
					Sure.sure(disjointRects.disjoint(newNode));
					#end
				}
			}
			
			data = rectangleFits(i, height, width);
			fits = data.fits;
			y = data.y;
			
			if (y + width < bestHeight || (y + width == bestHeight && skyline[i].width < bestWidth)) {
				bestHeight = y + width;
				bestIndex = i;
				bestWidth = skyline[i].width;
				newNode.x = skyline[i].x;
				newNode.y = y;
				newNode.width = height;
				newNode.height = width;
				newNode.flipped = !newNode.flipped;
				
				#if debug
				Sure.sure(disjointRects.disjoint(newNode));
				#end
			}
		}
		
		return { newNode: newNode, bestHeight: bestHeight, bestWidth: bestWidth, bestIndex: bestIndex };
	}
	
	private function rectangleFits(skylineNodeIndex:Int, width:Int, height:Int): { y:Int, fits:Bool } {
		var x = skyline[skylineNodeIndex].x;
		if (x + width > binWidth) {
			return { fits: false, y: -1 };
		}
		
		var widthLeft = width;
		var i = skylineNodeIndex;
		
		var y = skyline[skylineNodeIndex].y;
		
		while (widthLeft > 0) {
			y = Std.int(Math.max(y, skyline[i].y));
			if (y + height > binHeight) {
				return { y: y, fits: false };
			}
			widthLeft -= skyline[i].width;
			++i;
			Sure.sure(i < skyline.length || widthLeft <= 0);
		}
		
		return { y: y, fits: true };
	}
	
	private function rectangleFitsWithWastedArea(skylineNodeIndex:Int, width:Int, height:Int): { y:Int, fits:Bool, wastedArea:Int } {
		var data = rectangleFits(skylineNodeIndex, width, height);
		var y = data.y;
		var fits = data.fits;
		
		var wastedArea = 0;
		
		if (data.fits) {
			wastedArea = computeWastedArea(skylineNodeIndex, width, height, y);
		}
		
		return { y: y, fits: fits, wastedArea: wastedArea };
	}
	
	private function computeWastedArea(skylineNodeIndex:Int, width:Int, height:Int, y:Int):Int {
		var wastedArea:Int = 0;
		
		var rectLeft = skyline[skylineNodeIndex].x;
		var rectRight = rectLeft + width;
		
		while (skylineNodeIndex < skyline.length && skyline[skylineNodeIndex].x < rectRight) {
			if (skyline[skylineNodeIndex].x >= rectRight || skyline[skylineNodeIndex].x + skyline[skylineNodeIndex].width <= rectLeft) {
				break;
			}
			
			var leftSide = skyline[skylineNodeIndex].x;
			var rightSide = Math.min(rectRight, leftSide + skyline[skylineNodeIndex].width);
			
			Sure.sure(y >= skyline[skylineNodeIndex].y);
			
			wastedArea += Std.int((rightSide - leftSide) * (y - skyline[skylineNodeIndex].y));
		}
		
		return wastedArea;
	}
	
	private function addWasteMapArea(skylineNodeIndex:Int, width:Int, height:Int, y:Int):Void {
		var rectLeft = skyline[skylineNodeIndex].x;
		var rectRight = rectLeft + width;
		
		while (skylineNodeIndex < skyline.length && skyline[skylineNodeIndex].x < rectRight) {
			if (skyline[skylineNodeIndex].x >= rectRight || skyline[skylineNodeIndex].x + skyline[skylineNodeIndex].width <= rectLeft) {
				break;
			}
			
			var leftSide = skyline[skylineNodeIndex].x;
			var rightSide = Math.min(rectRight, leftSide + skyline[skylineNodeIndex].width);
			Sure.sure(y >= skyline[skylineNodeIndex].y);
			
			var waste = new Rect(leftSide, skyline[skylineNodeIndex].y, rightSide - leftSide, y - skyline[skylineNodeIndex].y);
			
			#if debug
			Sure.sure(disjointRects.disjoint(waste));
			#end
			
			wasteMap.getFreeRectangles().push(waste);
			
			skylineNodeIndex++;
		}
	}
	
	private function addSkylineLevel(skylineNodeIndex:Int, rect:Rect):Void {
		if (useWasteMap) {
			addWasteMapArea(skylineNodeIndex, Std.int(rect.width), Std.int(rect.height), Std.int(rect.y));
		}
		
		var newNode:SkylineNode = new SkylineNode(Std.int(rect.x), Std.int(rect.y + rect.height), Std.int(rect.width));
		skyline.insert(skylineNodeIndex, newNode);
		
		Sure.sure(newNode.x + newNode.width <= binWidth);
		Sure.sure(newNode.y <= binHeight);
		
		var i = skylineNodeIndex + 1;
		while (i < skyline.length) {
			Sure.sure(skyline[i - 1].x <= skyline[i].x);
			
			if (skyline[i].x < skyline[i - 1].x + skyline[i - 1].width) {
				var shrink = skyline[i - 1].x + skyline[i - 1].width - skyline[i].x;
				
				skyline[i].x += shrink;
				skyline[i].width -= shrink;
				
				if (skyline[i].width <= 0) {
					skyline.splice(i, 1);
					continue;
				} else {
					break;
				}
			} else {
				break;
			}
			
			i++;
		}
	}
	
	private function mergeSkylines():Void {
		var i = 0;
		while (i < skyline.length) {
			if (skyline[i].y == skyline[i + 1].y) {
				skyline[i].width += skyline[i + 1].width;
				skyline.splice(i + 1, 1);
				continue;
			}
			i++;
		}
	}
}