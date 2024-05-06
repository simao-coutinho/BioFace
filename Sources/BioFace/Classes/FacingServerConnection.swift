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
    
    private func getHeaders() -> HTTPHeaders? {
        guard let apiToken = Facing.apiToken else { return nil}
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer " + apiToken,
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        return headers
    }
    
    func makeImageUpload(with image: UIImage,sessionId: String, completion: @escaping FacingResponse) {
        guard let apiToken = Facing.apiToken else { return }
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
                
                switch response.result {
                    case .success(_):
                        completion(.succeeded, response.value, nil)
                    case .failure(_):
                        completion(.succeeded, response.value, response.error as NSError?)
                    }
                
                print("URL: Collect -> Response: \(response)")
                
            }
    }
    
    func makeGetConnection(url: String, sessionId: String, completion: @escaping FacingResponse) {
        guard let headers = getHeaders() else { return }
        
        AF.request(self.url + url, method: .get, parameters: ["session_id": sessionId], encoding: URLEncoding.queryString, headers: headers).responseDecodable(of: ExtractResponse.self) { response in
            
            switch response.result {
                case .success(_):
                    completion(.succeeded, Response(success: true, data: response.value), nil)
                case .failure(_):
                    completion(.failed, Response(success: false, data: response.value), response.error as NSError?)
                }
            
            print("URL: \(url) -> Response: \(response)")
        }
    }
    
    func makeCompareVerification(templateA: [Float], templateB: [Float], completion: @escaping FacingResponse) {
        guard let headers = getHeaders() else { return }
        
        let dataTemplateA = Data(buffer: UnsafeBufferPointer(start: templateA, count: templateA.count))
        
        let dataTemplateB = Data(buffer: UnsafeBufferPointer(start: templateB, count: templateB.count))
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(try! JSONEncoder().encode(templateA), withName: "templateA")
                multipartFormData.append(try! JSONEncoder().encode(templateB), withName: "templateB")
            },
            to: url + "compare", method: .post , headers: headers).responseString { response in
                
                switch response.result {
                case .success(_):
                    print("success: \(response)")
                    //completion(.succeeded, Response(success: true, data: response.value), nil)
                case .failure(_):
                    print("failure: \(response)")
                    //completion(.failed, Response(success: false, data: response.value), response.error as NSError?)
                }
                
                print("URL: Collect -> Response: \(response)")
        }
    }
}
