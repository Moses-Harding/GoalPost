//
//  Web Service Call Object.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class WebServiceCall {
    
    init() {
        
    }
    
    func retrieveResults(requestURL: String, requestHeaders: [String:String]? = nil, errorClosure: ((Error?) -> Void)? = nil, dataConversionClosure: @escaping (Data?) -> Void) {
        
        print("WebServiceCall - Calling request url: \(requestURL)")

        var headers: [String:String]
        
        if let requestHeaders = requestHeaders {
            headers = requestHeaders
        } else {
            headers = [
                "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
                "X-RapidAPI-Key": Secure.rapidAPIKey ]
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: requestURL)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                          
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                errorClosure?(error) ?? print("Error calling \(requestURL) - \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                
                print("\nConverting data for \(requestURL)\n")
                dataConversionClosure(data)
            }
        })
        
        dataTask.resume()
    }
    
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
        
        //let request = NSMutableURLRequest(url: NSURL(string: requestURL)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                          
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        return data
    }
}
