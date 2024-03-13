import Alamofire
import Foundation

public struct BioFace {
    public private(set) var token = ""

    public init(token: String) {
        self.token = token
    }
    
    public func getToken() -> String {
        return token
    }
    
    public func uploadImage(_ file: Data,filename : String) {
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "authorization": "Bearer " + self.token
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(file, withName: "upload_data" , fileName: filename, mimeType: "image/jpg")
        },
            to: "https://visteamlab.isr.uc.pt/facing/v2/api/collect", method: .post , headers: headers)
            .response { response in
                if let data = response.data{
                    //handle the response however you like
                    print(data)
                }

        }
    }
}
