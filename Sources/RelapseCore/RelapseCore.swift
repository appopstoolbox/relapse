import Foundation
import GRDB
import os.log

extension String : Error {}

public struct RelapseCore {
    
    var database : DatabasePool
    public static let log : OSLog = {
        let bundleIdentifier  = Bundle.main.bundleIdentifier ?? "com.appopstoolbox"
        let subsystem = "\(bundleIdentifier)"
        let category = "Relapse"
        return OSLog(subsystem: subsystem, category: category)
    }()


    public enum Sign : String, RawRepresentable {
        case inferiorTo = "<"
        case superiorTo = ">"
    }
    
    public init?(_ databasePath : String) {
        
        do {
            database = try DatabasePool(path: databasePath)
            os_log("💾 %s", log: RelapseCore.log, type: .debug, database.path)
        } catch {
            print(error)
            return nil
        }
    }
    
    public static func createDB(
        _ filePath : String,
        folderPath : String
        ) throws -> Bool {
        try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        if FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) {
            
            let dbQueue = try DatabaseQueue(path: filePath)
            try dbQueue.write { db in
                try db.create(table: "limits") { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("limitKey", .text).notNull()
                    t.column("limitValue", .integer).notNull()
                    t.column("update", .date).notNull()
                }
            }
            
            return true
        }
        return false
    }
    
    public func isLimitKeyPresent(
        _ limitKey : String
        ) throws -> Bool {
        
        var scalar : Int = 0
        try database.read { db in
            scalar = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM `limits` WHERE `limitKey` = '\(limitKey)'") ?? 0
        }
        if scalar == 1 { return true }
        return false
    }
    
    public func add(
        limitKey key : String,
        limitValue value : Int
        ) throws {
        
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO `limits` (`limitKey`,`limitValue`, `update`) VALUES (:limitKey ,:limitValue, :update)",
                arguments:["limitKey": key, "limitValue": value, "update" : Date()]
            )
            print("😆 - We have added this new value.")
        }
    }
    
    public func updateLimit(
        _ key : String,
        _ value : Int
        ) throws {
        
        try database.write { db in
            try db.execute(
                sql: "UPDATE `limits` SET `limitValue` = :limitValue WHERE `limitKey` = :limitKey",
                arguments: ["limitKey": key, "limitValue": value])
        }
    }
    
    public func shouldWeUpdateOrRejectValue(
        limitKey key : String,
        limitValue value : Int,
        sign : Sign
        ) throws {
        
        var numberOfFoundValue = 0
        var numberOfEqualValue = 0
        var limitValue = 999999
        
        try database.read { db in
            numberOfFoundValue = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM `limits` WHERE `limitValue` \(sign.rawValue) \(value) AND `limitKey` = '\(key)'") ?? 0
            numberOfEqualValue = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM `limits` WHERE `limitValue` = \(value) AND `limitKey` = '\(key)'") ?? 0
            limitValue = try Int.fetchOne(db, sql: "SELECT `limitValue` FROM `limits` WHERE `limitKey` = '\(key)'") ?? 999999
        }
        
        switch (numberOfFoundValue, numberOfEqualValue) {
        case (0, 0):
            try updateLimit(key, value)
            print("😆 - We have update the saved value to \(value).")
        case (0, 1):
            print("😐 - The new value(\(value)) is equal to the stored value.")
        case (1, 0), (1, 1):
            throw "😫 - The test of \"\(value) \(sign.rawValue) \(limitValue)\" failed."
        default:
            throw "Impossible 🧐"
        }
    }
}
