//
//  File.swift
//  
//
//  Created by Simao Coutinho on 21/03/2024.
//

import Foundation
import Alamofire
import UIKit

class ServerConnection {
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
    
    private func getHeaders(sessionId: String) -> HTTPHeaders? {
        guard let apiToken = BioFace.apiToken else { return nil}
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer " + apiToken,
            "Content-Type": "application/x-www-form-urlencoded",
            "session_id": sessionId
        ]
        
        return headers
    }
    
    func makeImageUpload(with image: UIImage,sessionId: String, completion: @escaping BioFaceResponse) {
        guard let apiToken = BioFace.apiToken else { return }
        let headers: HTTPHeaders = [
            "authorization": "Bearer " + apiToken,
        ]
        
        guard let sessionIdData = sessionId.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        guard let file = image.jpegData(compressionQuality: 75) else { return }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(sessionIdData, withName: "session_id")
                multipartFormData.append(file, withName: "collection" , fileName: "collection.jpg", mimeType: "image/jpg")
        },
            to: url + "collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                completion(.succeeded, response.value, nil)
            }
    }
    
    func makeGetConnection(url: String, sessionId: String, completion: @escaping BioFaceResponse) {
        /*guard let apiToken = BioFace.apiToken else { return }
        let parameters = "session_id=\(sessionId)"
        let postData =  parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: self.url + url)!,timeoutInterval: Double.infinity)
        request.addValue(sessionId, forHTTPHeaderField: "session_id")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + apiToken, forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()*/

        guard let headers = getHeaders(sessionId: sessionId) else { return }
        
        AF.request(self.url + url, method: .get, headers: headers).responseString { response in
            completion(.succeeded, Response(success: true, message: response.value), nil)
        }
    }
}
