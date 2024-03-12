public struct BioFace {
    public private(set) var token = ""

    public init(token: String) {
        self.token = token
    }
    
    public func getToken() -> String {
        return token
    }
}
