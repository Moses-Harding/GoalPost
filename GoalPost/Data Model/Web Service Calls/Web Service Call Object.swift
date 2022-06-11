//
//  Web Service Call Object.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class WebServiceCall {
     
    func retrieveResults(requestURL: String, requestHeaders: [String:String]? = nil, errorClosure: ((Error?) -> Void)? = nil) async throws -> Data {
        
        print("WebServiceCall - Calling request url: \(requestURL)")

        var headers: [String:String]
        
        if let requestHeaders = requestHeaders {
            headers = requestHeaders
        } else {
            headers = [
                "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
                "X-RapidAPI-Key": Secure.rapidAPIKey ]
        }
        
        guard let url =  URL(string: requestURL) else { fatalError() }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                          
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        return data
    }
}
