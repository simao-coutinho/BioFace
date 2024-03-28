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
        guard let apiToken = BioFace.apiToken else { return nil}
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "authorization": "Bearer " + apiToken
        ]
        
        return headers
    }
    
    func makeImageUpload(with image: UIImage, completion: @escaping BioFaceResponse) {
        guard let headers = getHeaders() else { return }
        
        guard let sessionIdData = BioFace.sessionId?.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        guard let collectionNameData = "teste anm".data(using: .utf8, allowLossyConversion: false) else { return }
        
        guard let file = image.jpegData(compressionQuality: 75) else { return }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(sessionIdData, withName: "session_id")
                multipartFormData.append(collectionNameData, withName: "collection_name")
                multipartFormData.append(file, withName: "collection" , fileName: "CollectImage", mimeType: "image/jpg")
        },
            to: url + "collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                completion(.succeeded, response.value, nil)
            }
    }
    
    func makeGetConnection(url: String, completion: @escaping BioFaceResponse) {
        guard let headers = getHeaders() else { return }
        
        guard let sessionIdData = BioFace.sessionId?.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        AF.request(self.url + url, method: .get, headers: headers).response { response in
            completion(.succeeded, Response(success: true, data: response.data), nil)
        }
    }
}
