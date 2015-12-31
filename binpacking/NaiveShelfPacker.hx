package binpacking;

// Naive implementation of simple but bad packing efficiency bin packing algorithm
class NaiveShelfPacker implements IOccupancy {
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
	
	public function insert(width:Int, height:Int):Rect {
		var newNode = new Rect();
		
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