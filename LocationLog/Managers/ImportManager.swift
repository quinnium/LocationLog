//
//  ImportManager.swift
//  LocationLog
//
//  Created by Quinn on 29/11/2021.
//

import Foundation

class ImportManager {
    
    static func getCodableItemsFromURL(url: URL, completion: @escaping (Result<[CodableLogItem], ImportError>) -> Void ) {
        llPrint(for: "Starting getting data from URL")
        var codableLogItemsToReturn     = [CodableLogItem]()
        let task                        = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.requestFailed))
            } else if let data                  = data {
                let decoder                     = JSONDecoder()
                let myDateFormatter             = DateFormatter()
                myDateFormatter.dateFormat      = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy    = .formatted(myDateFormatter)
                do {
                    codableLogItemsToReturn = try decoder.decode([CodableLogItem].self, from: data)
                    completion(.success(codableLogItemsToReturn))
                }
                catch {
                    print("QLog: \(error)")
                    completion(.failure(.invalidData))
                }
            }
        }
        task.resume()
    }
}
