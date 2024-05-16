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
    
    public static var url : String?
    public static var apiToken: String?
    
    private func getHeaders() -> HTTPHeaders? {
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(ServerConnection.apiToken ?? "")",
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
            to: "\(ServerConnection.url ?? "")collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                
                switch response.result {
                    case .success(_):
                        completion(.succeeded, response.value, nil)
                    case .failure(_):
                        completion(.succeeded, response.value, response.error as NSError?)
                    }
                
                print("URL: Collect -> Response: \(response)")
                
            }
    }
    
    func getUrlAndApiToken(completion: @escaping FacingResponse) {
        let url = "https://dev.bioface.devcprojects.com/api/authenticate"
        
        let parameters = [
            "token" : Facing.apiToken,
            "bundle" : Bundle.main.bundleIdentifier,
            "platform" : "ios"
        ]
        
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: AuthenticationResponse.self) { response in
            switch response.result {
            case .success(_):
                if response.response?.url != nil {
                    ServerConnection.url = response.value?.url
                    ServerConnection.apiToken = response.value?.api_token
                    completion(.succeeded, nil, nil)
                } else {
                    completion(.failed, nil, response.error as NSError?)
                }
                    
                case .failure(_):
                    completion(.failed, nil, response.error as NSError?)
                }
            print("URL: \(url) -> Response: \(response)")
        }
    }
    
    func makeGetConnection(url: String, parameters: [String : Any], completion: @escaping FacingResponse) {
        guard let headers = getHeaders() else { return }
        
        AF.request("\(ServerConnection.url ?? "")\(url)", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).responseDecodable(of: ExtractResponse.self) { response in
            switch response.result {
                case .success(_):
                    completion(.succeeded, Response(success: true, data: response.value), nil)
                case .failure(_):
                    completion(.failed, Response(success: false, data: response.value), response.error as NSError?)
                }
            
            print("URL: \(ServerConnection.url ?? "")\(url) -> Response: \(response)")
            print("Teste: \(response.response?.url)")
        }
    }
    
    func makeCompareVerification(templateA: [Float], templateB: [Float], completion: @escaping FacingResponse) {
        guard let headers = getHeaders() else { return }
        
        do {
            let dataTemplateA = try JSONSerialization.data(withJSONObject: templateA, options: [])
            let dataTemplateB = try JSONSerialization.data(withJSONObject: templateB, options: [])
            
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(dataTemplateA, withName: "templateA")
                    multipartFormData.append(dataTemplateB, withName: "templateB")
                },
                to: "\(ServerConnection.url ?? "")compare", method: .post, headers: headers).responseString { response in
                    
                    switch response.result {
                    case .success(_):
                        print("success: \(response)")
                        completion(.succeeded, Response(success: true, data: nil), nil)
                    case .failure(_):
                        print("failure: \(response)")
                        completion(.failed, Response(success: false, data: nil), response.error as NSError?)
                    }
                    
                    print("URL: Compare -> Response: \(response)")
            }
        } catch {
            
        }
    }
    
    private func convertArrayToFile(template: [Float])-> Data? {
        let floatString = template.map { String($0) }.joined(separator: "\n")

        // Convert string to data
        return floatString.data(using: .utf8)
    }
}
