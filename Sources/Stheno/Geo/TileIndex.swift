// The slippy-map grid every tiled chart is keyed on — as generic as a
// coordinate, and needed by anything that caches, fetches or draws tiles.

/// One tile of the slippy-map grid the cache is keyed on.
public struct TileIndex: Hashable, Sendable {

	/// The zoom level.
	public let z: Int
	/// The column, counted east from the antimeridian.
	public let x: Int
	/// The row, counted south from the top of the Web Mercator square.
	public let y: Int

	/// Creates a tile index.
	public init(z: Int, x: Int, y: Int) {
		self.z = z
		self.x = x
		self.y = y
	}
}
