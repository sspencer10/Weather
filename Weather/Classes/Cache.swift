import MapKit

class CachingTileOverlay: MKTileOverlay {
    private let cache = NSCache<NSURL, NSData>()

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = url(forTilePath: path) as NSURL

        // Check if the tile is cached
        if let cachedData = cache.object(forKey: url) {
            result(cachedData as Data, nil)
            return
        }

        // If not cached, fetch from the server
        let task = URLSession.shared.dataTask(with: url as URL) { data, response, error in
            if let data = data {
                self.cache.setObject(data as NSData, forKey: url)
            }
            result(data, error)
        }
        task.resume()
    }
    
    // Add a method to clear the cache
    func clearCache() {
        cache.removeAllObjects()
    }
}
