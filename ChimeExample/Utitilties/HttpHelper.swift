//
//  HttpHelper.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import Foundation

class HttpHelper {
    typealias DataResult = (Result<Data,Error>) -> Void
    
    static func postRequest(url: String, completion: @escaping DataResult) {
        makeHttpRequest(url: url, method: "post", completion: completion)
    }
    
    static func getRequest(url: String, completion: @escaping DataResult) {
        makeHttpRequest(url: url, method: "get", completion: completion)
    }
    
    private static func makeHttpRequest(url: String, method: String, completion: @escaping DataResult) {
        guard let serverUrl = URL(string: url) else {
            print("Unable to parse Url please make sure check Url")
            return
        }
        
        var request = URLRequest(url: serverUrl)
        request.httpMethod = method
    
        URLSession.shared.dataTask(with: request) { data, resp, error in
            print(resp)
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else { return }
            completion(.success(data))
        
        }.resume()
    }
    
    public static func encodeStrForURL(str: String) -> String {
        return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? str
    }
}
