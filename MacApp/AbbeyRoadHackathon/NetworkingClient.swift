import Cocoa

public class NetworkingClient: NSObject {
    public func searchRequest(
        _ parameters: SearchRequest,
        _ completion: @escaping (Result<SearchResponse, Error>) -> Void) {

        let request = JSONRequester()
        let requestOptions = HTTPRequestOptions(
            URL: URL(string: "http://m2.audiocommons.org/api/audioclips/search?pattern=\(parameters.parameters)&limit=1&page=1&source=freesound")!,
            verb: .get,
            body: nil,
            headers: nil
        )
        request.request(requestOptions) { (result: Result<SearchResponse, Error>) in
            switch result  {
            case .success(let data):
                do {
                    let response = try SearchResponse(data)
                    return completion(.success(response))
                } catch {
                    return completion(.failure(error))
                }
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
}

public struct SearchResults: Decodable {
    let results: [SearchItem]
}

public struct SearchItem: Decodable {
}

public class SearchResponse: NSObject {
    public convenience init(_ response: Any) throws {
        let data: Data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
        try self.init(data)
    }

    public init(_ data: Data) throws {
        self.results = try JSONDecoder().decode(SearchResults.self, from: data).results
    }

    public let results: [SearchItem]
}

public class SearchRequest: NSObject {
    let parameters: [(key: String, value: String?)]

    init(category: String) {
        parameters = [("category", category)]
    }
}
