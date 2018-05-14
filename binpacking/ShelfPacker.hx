package binpacking;

import binpacking.GuillotinePacker;

enum ShelfChoiceHeuristic {
	Next; // Always add the new rectangle to the last open shelf
	First; // Test each rectangle against each shelf in turn and pack it to the first where it fits
	BestArea; // Choose the shelf with smallest remaining shelf area
	WorstArea; // Choose the shelf with the largest remaining shelf area
	BestHeight; // Choose the smallest shelf (height-wise) where the rectangle fits
	BestWidth; // Choose the shelf that has the least remaining horizontal shelf space available after packing
	WorstWidth; // Choose the shelf that will have most remainining horizontal shelf space available after packing
}

class Shelf {
	public var currentX:Int;
	public var startY:Int;
	public var height:Int;
	public var usedRectangles:Array<Rect>;
	
	public inline function new(currentX:Int = 0, startY:Int = 0, height:Int = 0) {
		this.currentX = currentX;
		this.startY = startY;
		this.height = height;
		usedRectangles = [];
	}
}

// Simple but bad packing efficiency bin packing algorithm
class ShelfPacker implements IOccupancy {
	public var binWidth(default, null):Int;
	public var binHeight(default, null):Int;
	public var currentY(default, null):Int;
	private var usedSurfaceArea(default, null):Int;
	private var useWasteMap:Bool;
	private var wasteMap:GuillotinePacker;
	private var shelves:Array<Shelf>;
	
	public function new(width:Int = 0, height:Int = 0, useWasteMap:Bool = false) {
		binWidth = width;
		binHeight = height;
		currentY = 0;
		usedSurfaceArea = 0;
		this.useWasteMap = useWasteMap;
		shelves = [];
		startNewShelf(0);
		
		if (useWasteMap) {
			wasteMap = new GuillotinePacker(width, height);
			wasteMap.getFreeRectangles().splice(0, wasteMap.getFreeRectangles().length);
		}
	}
	
	public function insert(width:Int, height:Int, heuristic:ShelfChoiceHeuristic):Rect {
		if (useWasteMap) {
			var node = wasteMap.insert(width, height, true, GuillotineFreeRectChoiceHeuristic.BestShortSideFit, GuillotineSplitHeuristic.MaximizeArea);
			
			if (node != null) {
				usedSurfaceArea += width * height;
				return node;
			}
		}
		
		var newNode = new Rect();
		
		switch(heuristic) {
			case ShelfChoiceHeuristic.Next:
				var back = shelves[shelves.length - 1];
				if (fitsOnShelf(back, width, height, true)) {
					addToShelf(back, width, height, newNode);
					return newNode;
				}
			case ShelfChoiceHeuristic.First:
				for (i in 0...shelves.length) {
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						addToShelf(shelves[i], width, height, newNode);
						return newNode;
					}
				}
			case ShelfChoiceHeuristic.BestArea:
				var bestShelf = null;
				var bestShelfSurfaceArea:Int = -1;
				for (i in 0...shelves.length) {
					if (shouldRotateToShelf(shelves[i], width, height)) {
						var tmp = width;
						width = height;
						height = tmp;
						newNode.flipped = !newNode.flipped;
					}
					
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						var surfaceArea:Int = (binWidth - shelves[i].currentX) * shelves[i].height;
						if (surfaceArea < bestShelfSurfaceArea) {
							bestShelf = shelves[i];
							bestShelfSurfaceArea = surfaceArea;
						}
					}
				}
				
				if (bestShelf != null) {
					addToShelf(bestShelf, width, height, newNode);
					return newNode;
				}
			case ShelfChoiceHeuristic.WorstArea:
				var bestShelf = null;
				var bestShelfSurfaceArea:Int = -1;
				for (i in 0...shelves.length) {
					if (shouldRotateToShelf(shelves[i], width, height)) {
						var tmp = width;
						width = height;
						height = tmp;
						newNode.flipped = !newNode.flipped;
					}
					
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						var surfaceArea:Int = (binWidth - shelves[i].currentX) * shelves[i].height;
						if (surfaceArea > bestShelfSurfaceArea) {
							bestShelf = shelves[i];
							bestShelfSurfaceArea = surfaceArea;
						}
					}
				}
				
				if (bestShelf != null) {
					addToShelf(bestShelf, width, height, newNode);
					return newNode;
				}
			case ShelfChoiceHeuristic.BestHeight:
				var bestShelf = null;
				var bestShelfHeightDifference = 0x3FFFFFFF; // Neko max int is this (2^30-1, 0x3FFFFFFF)
				for (i in 0...shelves.length) {
					if (shouldRotateToShelf(shelves[i], width, height)) {
						var tmp = width;
						width = height;
						height = tmp;
						newNode.flipped = !newNode.flipped;
					}
					
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						var heightDifference = Math.max(shelves[i].height - height, 0);
						Sure.sure(heightDifference >= 0);
						if (heightDifference < bestShelfHeightDifference) {
							bestShelf = shelves[i];
							bestShelfHeightDifference = Std.int(heightDifference);
						}
					}
				}
				
				if (bestShelf != null) {
					addToShelf(bestShelf, width, height, newNode);
					return newNode;
				}
			case ShelfChoiceHeuristic.BestWidth:
				var bestShelf = null;
				var bestShelfWidthDifference = 0x3FFFFFFF; // Neko max int is this (2^30-1, 0x3FFFFFFF)
				for (i in 0...shelves.length) {
					if (shouldRotateToShelf(shelves[i], width, height)) {
						var tmp = width;
						width = height;
						height = tmp;
						newNode.flipped = !newNode.flipped;
					}
					
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						var widthDifference = binWidth - shelves[i].currentX - width;
						Sure.sure(widthDifference >= 0);
						
						if (widthDifference < bestShelfWidthDifference) {
							bestShelf = shelves[i];
							bestShelfWidthDifference = widthDifference;
						}
					}
				}
				
				if (bestShelf != null) {
					addToShelf(bestShelf, width, height, newNode);
					return newNode;
				}
			case ShelfChoiceHeuristic.WorstWidth:
				var bestShelf = null;
				var bestShelfWidthDifference = -1;
				for (i in 0...shelves.length) {
					if (shouldRotateToShelf(shelves[i], width, height)) {
						var tmp = width;
						width = height;
						height = tmp;
						newNode.flipped = !newNode.flipped;
					}
					
					if (fitsOnShelf(shelves[i], width, height, i == shelves.length - 1)) {
						var widthDifference = binWidth - shelves[i].currentX - width;
						Sure.sure(widthDifference >= 0);
						
						if (widthDifference > bestShelfWidthDifference) {
							bestShelf = shelves[i];
							bestShelfWidthDifference = widthDifference;
						}
					}
				}
				
				if (bestShelf != null) {
					addToShelf(bestShelf, width, height, newNode);
					return newNode;
				}
		}
		
		if (width < height && height <= binWidth) {
			var tmp = width;
			width = height;
			height = tmp;
			newNode.flipped = !newNode.flipped;
		}
		
		if (canStartNewShelf(height)) {
			if (useWasteMap) {
				var back = shelves[shelves.length - 1];
				moveShelfToWasteMap(back);
			}
			startNewShelf(height);
			var back = shelves[shelves.length - 1];
			Sure.sure(fitsOnShelf(back, width, height, true));
			addToShelf(back, width, height, newNode);
			return newNode;
		}
		
		return null;
	}
	
	public function occupancy():Float {
		var fUsedSurfaceArea = cast(usedSurfaceArea, Float);
		return fUsedSurfaceArea / (binWidth * binHeight);
	}
	
	private function moveShelfToWasteMap(shelf:Shelf):Void {
		var freeRects = wasteMap.getFreeRectangles();
		
		for (i in 0...shelf.usedRectangles.length) {
			var r = shelf.usedRectangles[i];
			var newNode = new Rect(r.x, r.y + r.height, r.width, shelf.height - r.height);
			if (newNode.height > 0) {
				freeRects.push(newNode);
			}
		}
		shelf.usedRectangles.splice(0, shelf.usedRectangles.length);
		
		var newNode = new Rect(shelf.currentX, shelf.startY, binWidth - shelf.currentX, shelf.height);
		
		if (newNode.width > 0) {
			freeRects.push(newNode);
		}
		
		shelf.currentX = binWidth;
		
		wasteMap.mergeFreeList();
	}
	
	private function fitsOnShelf(shelf:Shelf, width:Int, height:Int, canResize:Bool):Bool {
		var shelfHeight = canResize ? (binHeight - shelf.startY) : shelf.height;
		return ((shelf.currentX + width <= binWidth && height <= shelfHeight) || (shelf.currentX + height <= binWidth && width <= shelfHeight));
	}
	
	private function shouldRotateToShelf(shelf:Shelf, width:Int, height:Int):Bool {
		if ((width > height && width > binWidth - shelf.currentX) || (width > height && width < shelf.height) || (width < height && height > shelf.height && height <= binWidth - shelf.currentX)) {
			return true;
		}
		return false;
	}
	
	private function addToShelf(shelf:Shelf, width:Int, height:Int, newNode:Rect):Void {
		Sure.sure(fitsOnShelf(shelf, width, height, true));
		
		if (shouldRotateToShelf(shelf, width, height)) {
			var tmp = width;
			width = height;
			height = tmp;
			newNode.flipped = !newNode.flipped;
		}
		
		newNode.x = shelf.currentX;
		newNode.y = shelf.startY;
		newNode.width = width;
		newNode.height = height;
		
		shelf.usedRectangles.push(newNode);
		
		shelf.currentX += width;
		
		Sure.sure(shelf.currentX <= binWidth);
		
		shelf.height = Std.int(Math.max(shelf.height, height));
		
		Sure.sure(shelf.height <= binHeight);
		
		usedSurfaceArea += width * height;
	}
	
	private function canStartNewShelf(height:Int):Bool {
		var back = shelves[shelves.length - 1];
		return (back.startY + back.height + height <= binHeight);
	}
	
	private function startNewShelf(startingHeight:Int):Void {
		if (shelves.length > 0) {
			var back = shelves[shelves.length - 1];
			//Sure.sure(back.height != 0); // TODO ported from C++, but isn't this always false at first because StartNewShelf(0) is called in the c'tor?
			currentY += back.height;
			Sure.sure(currentY < binHeight);
		}
		
		var shelf = new Shelf(0, currentY, startingHeight);
		
		Sure.sure(shelf.startY + shelf.height <= binHeight);
		
		shelves.push(shelf);
	}
}