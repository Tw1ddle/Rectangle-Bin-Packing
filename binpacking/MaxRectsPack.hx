package binpacking;

enum FreeRectChoiceHeuristic {
	BestShortSideFit;
	BestLongSideFit;
	BestAreaFit;
	BottomLeftRule;
	ContactPointRule;
}

class MaxRectsPack {
	private var binWidth:Int;
	private var binHeight:Int;
	private var usedRectangles:Array<Rect> = new Array<Rect>();
	private var freeRectangles:Array<Rect> = new Array<Rect>();
	
	public function new(width:Int = 0, height:Int = 0) {
		binWidth = 0;
		binHeight = 0;
		
		var n = new Rect(0, 0, width, height);
		
		freeRectangles.push(n);
	}
	
	public function insertRects(rects:Array<Rect>, dst:Array<Rect>, method:FreeRectChoiceHeuristic):Void {		
		dst.splice(0, dst.length);
		
		while (rects.length > 0) {
			var bestScore1 = 0x3FFFFFFF;
			var bestScore2 = 0x3FFFFFFF;
			
			var bestRectIndex = -1;
			var bestNode:Rect = new Rect();
			
			for (i in 0...rects.length) {				
				var details = scoreRect(Std.int(rects[i].width), Std.int(rects[i].height), method);
				
				if (details.primaryScore < bestScore1 || (details.primaryScore == bestScore1 && details.secondaryScore < bestScore2)) {
					bestScore1 = details.primaryScore;
					bestScore2 = details.secondaryScore;
					bestNode = details.rect;
					bestRectIndex = i;
				}
			}
			
			if (bestRectIndex == -1) {
				return;
			}
			
			placeRect(bestNode);
			rects.splice(bestRectIndex, 1);
		}
	}
	
	public function insertRect(width:Int, height:Int, method:FreeRectChoiceHeuristic):Rect {
		var newNode:Rect = switch(method) {
			case FreeRectChoiceHeuristic.BestShortSideFit:
				findPositionForNewNodeBestShortSideFit(width, height).bestNode;
			case FreeRectChoiceHeuristic.BottomLeftRule:
				findPositionForNewNodeBottomLeft(width, height).bestNode;
			case FreeRectChoiceHeuristic.ContactPointRule:
				findPositionForNewNodeContactPoint(width, height).bestNode;
			case FreeRectChoiceHeuristic.BestLongSideFit:
				findPositionForNewNodeBestLongSideFit(width, height).bestNode;
			case FreeRectChoiceHeuristic.BestAreaFit:
				findPositionForNewNodeBestAreaFit(width, height).bestNode;
		}
		
		if (newNode.height == 0) {
			return newNode;
		}
		
		var numRectanglesToProcess = freeRectangles.length;
		
		for (i in 0...numRectanglesToProcess) {
			if (splitFreeNode(freeRectangles[i], newNode)) {
				freeRectangles.splice(i, 1);
				--i;
				--numRectanglesToProcess;
			}
		}
		
		pruneFreeList();
		
		usedRectangles.push(newNode);
		return newNode;
	}
	
	public function occupancy():Float {
		var usedSurfaceArea:Float = 0;
		
		for (i in 0...usedRectangles.length) {
			usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;
		}
		
		return cast(usedSurfaceArea, Float) / (binWidth * binHeight);
	}
	
	private function scoreRect(width:Int, height:Int, method:FreeRectChoiceHeuristic): { rect:Rect, primaryScore: Int, secondaryScore: Int } {
		var newNode:Rect = null;
		var score1:Int = 0x3FFFFFFF;
		var score2:Int = 0x3FFFFFFF;
		
		switch(method) {
			case FreeRectChoiceHeuristic.BestShortSideFit:
				var data = findPositionForNewNodeBestShortSideFit(width, height);
				newNode = data.bestNode;
				score1 = data.bestShortSideFit;
				score2 = data.bestLongSideFit;
			case FreeRectChoiceHeuristic.BottomLeftRule:
				var data = findPositionForNewNodeBottomLeft(width, height);
				newNode = data.bestNode;
				score1 = data.bestY;
				score2 = data.bestX;
			case FreeRectChoiceHeuristic.ContactPointRule:
				var data = findPositionForNewNodeContactPoint(width, height);
				newNode = data.bestNode;
				score1 = -data.bestContactScore;
			case FreeRectChoiceHeuristic.BestLongSideFit:
				var data = findPositionForNewNodeBestLongSideFit(width, height);
				newNode = data.bestNode;
				score1 = data.bestLongSideFit;
				score2 = data.bestLongSideFit;
			case FreeRectChoiceHeuristic.BestAreaFit:
				var data = findPositionForNewNodeBestAreaFit(width, height);
				newNode = data.bestNode;
				score1 = data.bestAreaFit;
				score2 = data.bestShortSideFit;
		}
		
		if (newNode.height == 0) {
			score1 = 0x3FFFFFFF;
			score2 = 0x3FFFFFFF;
		}
		
		return { rect: newNode, primaryScore: score1, secondaryScore: score2 };
	}
	
	private function placeRect(node:Rect):Void {
		var numRectanglesToProcess = freeRectangles.length;
		for (i in 0...numRectanglesToProcess) {
			if (splitFreeNode(freeRectangles[i], node)) {
				freeRectangles.splice(i, 1);
				--i;
				--numRectanglesToProcess;
			}
		}
		
		pruneFreeList();
		usedRectangles.push(node);
	}
	
	private function contactPointScoreNode(x:Int, y:Int, width:Int, height:Int):Int {
		var score = 0;
		
		if (x == 0 || x + width == binWidth) {
			score += height;
		}
		if (y == 0 || y + height == binHeight) {
			score += width;
		}
		
		for (i in 0...usedRectangles.length) {
			if (usedRectangles[i].x == x + width || usedRectangles[i].x + usedRectangles[i].width == x) {
				score += Std.int(commonIntervalLength(usedRectangles[i].y, usedRectangles[i].height, y, y + height));
			}
			if (usedRectangles[i].y == y + height || usedRectangles[i].y + usedRectangles[i].height == y) {
				score += Std.int(commonIntervalLength(usedRectangles[i].x, usedRectangles[i].x + usedRectangles[i].width, x, x + width));
			}
		}
		
		return score;
	}
	
	private function findPositionForNewNodeBottomLeft(width:Int, height:Int):{ bestNode:Rect, bestY:Int, bestX:Int } {
		var bestNode:Rect = null;
		
		var bestY = 0x3FFFFFFF;
		var bestX = 0x3FFFFFFF;
		
		for (i in 0...freeRectangles.length) {			
			if (freeRectangles[i].width >= width && freeRectangles[i].height < bestX) {
				var topSideY = Std.int(freeRectangles[i].y + height);
				
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestY = topSideY;
				bestX = Std.int(freeRectangles[i].x);
			}
			
			if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
				var topSideY = Std.int(freeRectangles[i].y + height);
				
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestY = topSideY;
				bestX = Std.int(freeRectangles[i].x);
			}
		}
		
		return { bestNode: bestNode, bestY: bestY, bestX: bestX };
	}
	
	private function findPositionForNewNodeBestShortSideFit(width:Int, height:Int):{ bestNode: Rect, bestShortSideFit:Int, bestLongSideFit:Int } {
		var bestNode:Rect = null;
		
		var bestShortSideFit = 0x3FFFFFFF;
		var bestLongSideFit = 0x3FFFFFFF;
		
		for (i in 0...freeRectangles.length) {
			if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
				var leftoverHoriz = Math.abs(freeRectangles[i].width - width);
				var leftoverVert = Math.abs(freeRectangles[i].height - height);
				var shortSideFit = Math.min(leftoverHoriz, leftoverVert);
				var longSideFit = Math.max(leftoverHoriz, leftoverVert);
			
				if (shortSideFit < bestShortSideFit || (shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = width;
					bestNode.height = height;
					bestShortSideFit = Std.int(shortSideFit);
					bestLongSideFit = Std.int(longSideFit);
				}
			}
			
			if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
				var flippedLeftoverHoriz = Math.abs(freeRectangles[i].width - height);
				var flippedLeftoverVert = Math.abs(freeRectangles[i].height - width);
				var flippedShortSideFit = Math.min(flippedLeftoverHoriz, flippedLeftoverVert);
				var flippedLongSideFit = Math.max(flippedLeftoverHoriz, flippedLeftoverVert);
				
				if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = height;
					bestNode.height = width;
					bestShortSideFit = Std.int(flippedShortSideFit);
					bestLongSideFit = Std.int(flippedLongSideFit);
				}
			}
		}
		
		return { bestNode: bestNode, bestShortSideFit: bestShortSideFit, bestLongSideFit: bestLongSideFit };
	}
	
	private function findPositionForNewNodeBestLongSideFit(width:Int, height:Int):{ bestNode: Rect, bestShortSideFit:Int, bestLongSideFit:Int } {
		var bestNode:Rect = null;
		
		var bestShortSideFit = 0x3FFFFFFF;
		var bestLongSideFit = 0x3FFFFFFF;
		
		for (i in 0...freeRectangles.length) {
			if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
				var leftoverHoriz = Math.abs(freeRectangles[i].width - width);
				var leftoverVert = Math.abs(freeRectangles[i].height - height);
				var shortSideFit = Math.min(leftoverHoriz, leftoverVert);
				var longSideFit = Math.max(leftoverHoriz, leftoverVert);
			
				if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = width;
					bestNode.height = height;
					bestShortSideFit = Std.int(shortSideFit);
					bestLongSideFit = Std.int(longSideFit);
				}
			}
			
			if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
				var leftoverHoriz = Math.abs(freeRectangles[i].width - width);
				var leftoverVert = Math.abs(freeRectangles[i].height - height);
				var shortSideFit = Math.min(leftoverHoriz, leftoverVert);
				var longSideFit = Math.max(leftoverHoriz, leftoverVert);
				
				if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = height;
					bestNode.height = width;
					bestShortSideFit = Std.int(shortSideFit);
					bestLongSideFit = Std.int(longSideFit);
				}
			}
		}
		
		return { bestNode: bestNode, bestShortSideFit: bestShortSideFit, bestLongSideFit: bestLongSideFit };
	}
	
	private function findPositionForNewNodeBestAreaFit(width:Int, height:Int): { bestNode: Rect, bestAreaFit:Int, bestShortSideFit:Int } {
		var bestNode:Rect = null;

		var bestAreaFit = 0x3FFFFFFF;
		var bestShortSideFit = 0x3FFFFFFF;

		for(i in 0...freeRectangles.length) {
			var areaFit = freeRectangles[i].width * freeRectangles[i].height - width * height;

			if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
				var leftoverHoriz = Math.abs(freeRectangles[i].width - width);
				var leftoverVert = Math.abs(freeRectangles[i].height - height);
				var shortSideFit = Math.min(leftoverHoriz, leftoverVert);

				if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = width;
					bestNode.height = height;
					bestShortSideFit = Std.int(shortSideFit);
					bestAreaFit = Std.int(areaFit);
				}
			}

			if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
				var leftoverHoriz = Math.abs(freeRectangles[i].width - height);
				var leftoverVert = Math.abs(freeRectangles[i].height - width);
				var shortSideFit = Math.min(leftoverHoriz, leftoverVert);

				if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit)) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = height;
					bestNode.height = width;
					bestShortSideFit = Std.int(shortSideFit);
					bestAreaFit = Std.int(areaFit);
				}
			}
		}
		
		return { bestNode: bestNode, bestAreaFit: bestAreaFit, bestShortSideFit: bestShortSideFit };
	}
	
	private function findPositionForNewNodeContactPoint(width:Int, height:Int):{ bestNode: Rect, bestContactScore:Int } {
		var bestNode:Rect = null;
		
		var bestContactScore = -1;
		
		for (i in 0...freeRectangles.length) {
			if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
				var score = contactPointScoreNode(Std.int(freeRectangles[i].x), Std.int(freeRectangles[i].y), width, height);
				if (score > bestContactScore) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = width;
					bestNode.height = height;
					bestContactScore = score;
				}
			}
			
			if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
				var score = contactPointScoreNode(Std.int(freeRectangles[i].x), Std.int(freeRectangles[i].y), height, width);
				if (score > bestContactScore) {
					bestNode.x = freeRectangles[i].x;
					bestNode.y = freeRectangles[i].y;
					bestNode.width = height;
					bestNode.height = width;
					bestContactScore = score;
				}
			}
		}
		
		return { bestNode: bestNode, bestContactScore: bestContactScore };
	}
	
	private function splitFreeNode(freeNode:Rect, usedNode:Rect):Bool {
	if (usedNode.x >= freeNode.x + freeNode.width ||
		usedNode.x + usedNode.width <= freeNode.x ||
		usedNode.y >= freeNode.y + freeNode.height ||
		usedNode.y + usedNode.height <= freeNode.y) {
			return false;
		}
		
		if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x) {
			if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height) {
				var newNode = freeNode.clone();
				newNode.height = usedNode.y - newNode.y;
				freeRectangles.push(newNode);
			}
			if (usedNode.y + usedNode.height < freeNode.y + freeNode.height) {
				var newNode = freeNode.clone();
				newNode.y = usedNode.y + usedNode.height;
				newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
				freeRectangles.push(newNode);
			}
		}

		if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y) {
			if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width) {
				var newNode = freeNode.clone();
				newNode.width = usedNode.x - newNode.x;
				freeRectangles.push(newNode);
			}
			if (usedNode.x + usedNode.width < freeNode.x + freeNode.width) {
				var newNode = freeNode.clone();
				newNode.x = usedNode.x + usedNode.width;
				newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
				freeRectangles.push(newNode);
			}
		}
		
		return true;
	}
	
	private function pruneFreeList():Void {
		for (i in 0...freeRectangles.length) {
			for (j in (i + 1)...freeRectangles.length) {
				if (freeRectangles[i].isContainedIn(freeRectangles[j])) {
					freeRectangles.splice(i, 1);
					--i;
					break;
				}
				
				if (freeRectangles[j].isContainedIn(freeRectangles[i])) {
					freeRectangles.splice(j, 1);
					--j;
				}
			}
		}
	}
	
	private function commonIntervalLength(i1start:Float, i1end:Float, i2start:Float, i2end:Float):Float {
		if (i1end < i2start || i2end < i1start) {
			return 0;
		}
		return (i1end < i2end ? i1end : i2end) - (i1start > i2start ? i1start : i2start);
	}
}