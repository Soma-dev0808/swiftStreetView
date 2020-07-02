import Foundation
import GoogleMaps

struct FetchLocationModel {
    private let coordinate: CLLocationCoordinate2D
    private let searchKey: String
    private let radius: String = "10000"
    private let originalUrl: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    private let apiKey: String = "AIzaSyBGFxfdrvOsqeuZqihIVGxhGR4ueqkybbs"
    
    init(coordinate: CLLocationCoordinate2D, searchKey: String) {
        self.coordinate = coordinate
        self.searchKey = searchKey
    }
    
    private func createURL() -> URL? {
        let urlWithParam = originalUrl + "location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=\(searchKey)&key=\(apiKey)"
        if let url = URL(string: urlWithParam) {
            return url
        }
        else {
            return nil
        }
    }
    
    func fetchNearPlace(_ completion: @escaping (PlaceResultData?, Error?) -> ()) {
        if let url = createURL() {
            
            let request = URLRequest(url: url)
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: request) { (data, res, error) in
                if let e = error {completion(nil, e)}
                else {completion(self.decodeFetchedData(with: data), nil)}
            }
            task.resume()
        }
    }
    
    private func decodeFetchedData(with data: Data?) -> PlaceResultData? {
        let decoder = JSONDecoder()
        if let safeData = data {
            do {
                let decodedData = try decoder.decode(PlaceResultData.self, from: safeData)
                return decodedData
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }
        
    static func convertCountryInfo(with fetchRes: PlaceResultData.Results) -> String {
        var countryLabel = ""
        if let plusCode = fetchRes.plus_code {
            
            if var countryInfoArr = plusCode.compound_code?.components(separatedBy: " ") {
                countryInfoArr.removeFirst()
                for info in countryInfoArr {
                    countryLabel += info + " " 
                }
            }
            return countryLabel
        }
        else {
            return countryLabel

        }
    }
 
}
