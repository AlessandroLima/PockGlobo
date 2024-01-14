//
//  HTTPRequestManager.swift
//  PocGlobo
//
//  Created by Alessandro Teixeira Lima on 14/01/24.
//

import Foundation

class HTTPRequestManager {
    
    enum RequestError: Error {
        case timeout
        case invalidResponse
        case requestFailed(Error)
    }
    
    func makePostRequest(with jsonBody: Data, completionHandler: @escaping (Result<Bool, RequestError>) -> Void) {
        
        guard let url = URL(string: "\(ServerEnvironment.urlBase.rawValue)\(ServerEnvironment.port.rawValue)") else {
            completionHandler(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            if let jsonData = data {
                // Aqui você pode analisar o JSON de retorno, se necessário.
                // Por exemplo: let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                completionHandler(.success(true))
            } else {
                completionHandler(.failure(.invalidResponse))
            }
        }
        
        task.resume()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            if task.state == .running {
                task.cancel()
                completionHandler(.failure(.timeout))
            }
        }
    }
}
