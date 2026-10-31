import Testing

@testable import Stheno

@Suite("TileIndex")
struct TileIndexTests {
	@Test func `Initializer stores the zoom, column and row`() {
		let tile = TileIndex(z: 12, x: 2130, y: 1495)
		#expect(tile.z == 12)
		#expect(tile.x == 2130)
		#expect(tile.y == 1495)
	}

	// The grid is a cache key before anything else, so two tiles naming the
	// same square must be one entry — and the three fields must all count.
	@Test func `Two tiles of the same square are the same key`() {
		let a = TileIndex(z: 8, x: 133, y: 93)
		let b = TileIndex(z: 8, x: 133, y: 93)
		#expect(a == b)
		#expect(a.hashValue == b.hashValue)
		#expect(Set([a, b]).count == 1)
	}

	@Test func `A tile differs on any one of zoom, column and row`() {
		let tile = TileIndex(z: 8, x: 133, y: 93)
		#expect(tile != TileIndex(z: 9, x: 133, y: 93))
		#expect(tile != TileIndex(z: 8, x: 134, y: 93))
		#expect(tile != TileIndex(z: 8, x: 133, y: 94))
	}
}
