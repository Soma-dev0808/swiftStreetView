import Foundation
import GoogleMaps

struct DistanceCalculator {
    func calDistance(firstLocation: CLLocation, secondLocaiton: CLLocation) -> Double{
        let distance = firstLocation.distance(from: secondLocaiton) / 1000
        return distance
    }
    
    func convertDistanceKm(distance: Double) -> String {
        return String(format: "%\(0.2)f", distance) + "km"
    }
}
