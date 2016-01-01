package binpacking;

// Naive shelf bin packing algorithm
// First-fit implementation that packs poorly in most scenarios
class NaiveShelfPacker implements IOccupancy {
	public var binWidth(default, null):Int;
	public var binHeight(default, null):Int;
	private var shelfHeight:Int;
	private var currentX:Int;
	private var currentY:Int;
	private var usedSurfaceArea:Float;
	
	public function new(width:Int, height:Int) {
		Sure.sure(width > 0 && height > 0);
		
		this.binWidth = width;
		this.binHeight = height;
		shelfHeight = 0;
		currentX = 0;
		currentY = 0;
		usedSurfaceArea = 0;
	}
	
	// Attempts to insert a rect with width and height into the bin
	// Returns the rect on success, null on failure
	public function insert(width:Int, height:Int):Rect {
		Sure.sure(width > 0 && height > 0);
		
		var flipped:Bool = false;
		
		// If the long edge of the new rectangle fits vertically onto the current shelf, flip it
		// If the short edge is larger than the current shelf height, store the short edge vertically
		if (((width > height && width < shelfHeight) || (width < height && height > shelfHeight))) {
			var tmp = width;
			width = height;
			height = tmp;
			flipped = true;
		} else {
			flipped = false;
		}
		
		if (currentX + width > binWidth) {
			currentX = 0;
			currentY += shelfHeight;
			shelfHeight = 0;
			
			// When starting a new shelf, store the new long edge of the new rectangle horizontally to minimize the new shelf height
			if (width < height) {
				var tmp = width;
				width = height;
				height = tmp;
				flipped = !flipped;
			}
		}
		
		// If the rectangle doesn't fit in this orientation, try flipping
		if (width > binWidth || currentY + height > binHeight) {
			var tmp = width;
			width = height;
			height = tmp;
			flipped = !flipped;
		}
		
		// If flipping didn't help, return failure
		if (width > binWidth || currentY + height > binHeight) {
			return null;
		}
		
		var newNode = new Rect(currentX, currentY, width, height, flipped);
		
		currentX += width;
		shelfHeight = shelfHeight > height ? shelfHeight : height; 
		usedSurfaceArea += width * height;
		
		return newNode;
	}
	
	// Computes the ratio of used surface area to total area
	public function occupancy():Float {
		if (usedSurfaceArea == 0) {
			return 0;
		}
		
		return usedSurfaceArea / (binWidth * binHeight);
	}
}