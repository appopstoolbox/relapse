import Foundation
import RelapseCore

public final class CLI {
    
    let limitKey : String
    let limitValue : Int
    let sign : RelapseCore.Sign
    let dbFilePath : String

    /// Revoir le parsing des parametres
    public init(arguments: [String] = CommandLine.arguments) throws {
        
        let arguments = CommandLine.arguments.dropFirst()
        
        // Number of arguments
        guard arguments.count == 4 else { throw "Bad number of argument" }
        
        // LimitKey
        guard let limitKey = arguments[safe: 1] else { throw "Missing Limit Key" }
        if limitKey.isEmpty {
            throw "LimitKey should not be empty"
        }

        // LimitValue
        guard
            let stringValue = arguments[safe: 2],
            let limitValue = Int(stringValue)
            else { throw "Limit value is invalid" }
        if stringValue.isEmpty {
            throw "LimitValue should not be empty"
        }

        // Sign
        guard
            let signString = arguments[safe: 3],
            let sign = RelapseCore.Sign(rawValue: signString)
            else { throw "Sign is invalid" }
        if signString.isEmpty {
            throw "Sign should not be empty"
        }

        // Database File Path
        guard let dbFilePath = arguments[safe: 4] else { throw "Missing database path" }
        if dbFilePath.isEmpty {
            throw "Database path should not be empty"
        }
        
        self.limitKey = limitKey
        self.limitValue = limitValue
        self.sign = sign
        self.dbFilePath = dbFilePath

    }
    
    public func run() throws {
        
        guard let url = URL(string: dbFilePath) else { throw "Failed to create URL" }
        let dbPath = url.deletingLastPathComponent().absoluteString
        
        if FileManager.default.fileExists(atPath: dbFilePath) == false {
            if try RelapseCore.createDB(dbFilePath, folderPath: dbPath) == false {
                throw "Failed to create db file"
            }
        }
        
        guard let rp = RelapseCore(dbFilePath) else { throw "Failed open databeFile" }
        let isTableCreate = try rp.isLimitKeyPresent(limitKey)
        if isTableCreate == false {
            try rp.add(limitKey: limitKey, limitValue: limitValue)
        } else {
            try rp.shouldWeUpdateOrRejectValue(limitKey: limitKey, limitValue: limitValue, sign: sign)
        }
    }
}
