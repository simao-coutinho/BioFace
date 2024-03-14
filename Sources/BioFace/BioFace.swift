import Alamofire
import Foundation

public struct BioFace {
    public private(set) var token = ""
    public private(set) var sessionId = ""

    public init(token: String) {
        self.token = token
    }
    
    public mutating func setSessionId(_ mSessionId: String) {
        sessionId = mSessionId
    }
    
    public func getToken() -> String {
        return token
    }
    
    public func uploadImage(_ file: Data,filename : String) {
        guard let sessionIdData = sessionId.data(using: .utf8, allowLossyConversion: false) else { return }
        guard let collectionNameData = "teste anm".data(using: .utf8, allowLossyConversion: false) else { return }
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "authorization": "Bearer " + self.token
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(sessionIdData, withName: "session_id")
                multipartFormData.append(collectionNameData, withName: "collection_name")
                multipartFormData.append(file, withName: "collection" , fileName: filename, mimeType: "image/jpg")
        },
            to: "https://visteamlab.isr.uc.pt/facing/v2/api/collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                debugPrint(response)
            }
    }
}
