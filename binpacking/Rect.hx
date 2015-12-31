package binpacking;

class RectSize {
	public var width:Int;
	public var height:Int;
	
	public inline function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
	}
}

class Rect {
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var flipped:Bool; // If a rect is flipped, then width and height are swapped and this is marked true
	
	public inline function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, flipped:Bool = false) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.flipped = flipped;
	}
	
	public inline function clone():Rect {
		return new Rect(x, y, width, height);
	}
	
	public inline function isContainedIn(other:Rect):Bool {
		return x >= other.x && y >= other.y	&& x + width <= other.x + other.width && y + height <= other.y + other.height;
	}
}

// Helper/debug class for ensuring that a collection of rects are disjoint
class DisjointRectCollection {
	public var rects:Array<Rect> = new Array<Rect>();
	
	public function new() {
	}
	
	public function add(r:Rect):Bool {
		if (r.width == 0 || r.height == 0) {
			return true;
		}
		
		if (!disjoint(r)) {
			return false;
		}
		
		rects.push(r);
		
		return true;
	}
	
	public function clear():Void {
		rects = [];
	}
	
	public function disjoint(r:Rect):Bool {
		if (r.width == 0 || r.height == 0) {
			return true;
		}
		
		for (i in 0...rects.length) {
			if (!rectsDisjoint(rects[i], r)) {
				return false;
			}
		}
		
		return true;
	}
	
	static public function rectsDisjoint(a:Rect, b:Rect):Bool {
		return (a.x + a.width <= b.x || b.x + b.width <= a.x || a.y + a.height <= b.y || b.y + b.height <= a.y);
	}
}