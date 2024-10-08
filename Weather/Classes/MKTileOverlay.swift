/*
 import MapKit

class CachingTileOverlay: MKTileOverlay {
    private let cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "tileCache")

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
        let request = URLRequest(url: url)
        
        // Check if the tile is already cached
        if let cachedResponse = cache.cachedResponse(for: request) {
            print("cache - cached tile")
            result(cachedResponse.data, nil)
        } else {
            print("cache - downloading tile")
            // Download the tile
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    // Cache the response
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    self.cache.storeCachedResponse(cachedResponse, for: request)
                }
                result(data, error)
                print("cache - \(String(describing: result))")
            }
            dataTask.resume()
        }
    }
    func clearCache() {
        cache.removeAllCachedResponses()
    }
}
*/
