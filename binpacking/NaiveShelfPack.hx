package binpacking;

private class Node {
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var flipped:Bool;
	
	public inline function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, flipped:Bool = false) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.flipped = flipped;
	}
}

class NaiveShelfPack {
	private var binWidth:Int;
	private var binHeight:Int;
	private var currentX:Int;
	private var currentY:Int;
	private var shelfHeight:Int;
	private var usedSurfaceArea:Int;
	
	public function new(width:Int, height:Int) {
		this.binWidth = width;
		this.binHeight = height;
		
		currentX = 0;
		currentY = 0;
		shelfHeight = 0;
		usedSurfaceArea = 0;
	}
	
	public function insert(width:Int, height:Int):Node {
		var newNode = new Node();
		
		if (((width > height && width < shelfHeight) || (width < height && height > shelfHeight))) {
			newNode.flipped = true;
			var tmp = width;
			width = height;
			height = tmp;
		} else {
			newNode.flipped = true;
		}
		
		if (currentX + width > binWidth) {
			currentX = 0;
			currentY += shelfHeight;
			shelfHeight = 0;
			
			if (width < height) {
				var tmp = width;
				width = height;
				height = tmp;
				newNode.flipped = !newNode.flipped;
			}
		}
		
		if (width > binWidth || currentY + height > binHeight) {
			var tmp = width;
			width = height;
			height = tmp;
			newNode.flipped = !newNode.flipped;
		}
		
		if (width > binWidth || currentY + height > binHeight) {
			return null;
		}
		
		newNode.width = width;
		newNode.height = height;
		newNode.x = currentX;
		newNode.y = currentY;
		
		currentX += width;
		shelfHeight = shelfHeight > height ? shelfHeight : height; 
		
		usedSurfaceArea += width * height;
		
		return newNode;
	}
	
	public function occupancy():Float {
		var fUsedSurfaceArea = cast(usedSurfaceArea, Float);
		return fUsedSurfaceArea / (binWidth * binHeight);
	}
}