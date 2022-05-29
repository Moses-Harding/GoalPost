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
                errorClosure?(error) ?? print("Error calling \(requestURL) - \(error)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                dataConversionClosure(data)
            }
        })
        
        dataTask.resume()
    }
}
