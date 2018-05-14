package binpacking;

// Occupancy, a measure of the total area covered (0-1)
interface IOccupancy {
	public function occupancy():Float;
}