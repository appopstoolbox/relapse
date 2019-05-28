import XCTest
import SnapshotTesting
import Foundation

import class Foundation.Bundle


extension String {
    func removeCharacters(match : String, with : String) -> String {
        if let hexaRange = self.range(of: match, options: .regularExpression) {
            return self.replacingCharacters(in: hexaRange, with: with)
        }
        return self
    }
}

extension Snapshotting where Value == String, Format == String {
    /// A snapshot strategy for comparing nserror based on equality
    /// This strategy remove pointer informations from NSError in order to make them retestable
    public static let nserror: Snapshotting = Snapshotting<String, String>.lines.pullback { err -> String in
        if let hexaRange = err.range(of: ###"(0x[\w]{9})"###, options: .regularExpression) {
            return err.replacingCharacters(in: hexaRange, with: "<pointer_info>")
        }
        return err
    }
}

final class RelapseTests: XCTestCase {
    
    func performTest(_ args : [String]) throws -> String {
        let fooBinary = productsDirectory.appendingPathComponent("Relapse")
        
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        return output ?? "<vide>"
    }
    
    func test_00_clean_init() throws {
        do {
            try FileManager.default.removeItem(atPath: ".test/ci")
        } catch {
            print(error)
        }
    }

    //// BadNumberOfArgument
    
    func test_01_BadNumberOfArgument1() throws {
        let output = try performTest([])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_02_BadNumberOfArgument2() throws {
        let output = try performTest(["test_relapse_superior_to"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_03_BadNumberOfArgument3() throws {
        let output = try performTest(["test_relapse_superior_to", "1"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_04_BadNumberOfArgument4() throws {
        let output = try performTest(["test_relapse_superior_to", "1", ">"])
        assertSnapshot(matching: output, as: .lines)
    }
    
    //// SuperiorTo

    func test_05_AddSuperiorTo() throws {
        let output = try performTest(["test_relapse_superior_to", "1", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_06_NoUpdateSuperiorTo() throws {
        let output = try performTest(["test_relapse_superior_to", "1", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }
    
    func test_07_UpdateSuperiorTo() throws {
        let output = try performTest(["test_relapse_superior_to", "5", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }
    
    func test_08_FailSuperiorTo() throws {
        let output = try performTest(["test_relapse_superior_to", "3", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }

    //// InferiorTo
    
    func test_09_AddInferiorTo() throws {
        let output = try performTest(["test_relapse_inferior_to", "25", "<", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)

    }
    
    func test_10_NoUpdateInferiorTo() throws {
        let output = try performTest(["test_relapse_inferior_to", "25", "<", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)

    }
    
    func test_11_UpdateInferiorTo() throws {
        let output = try performTest(["test_relapse_inferior_to", "2", "<", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)

    }
    
    func test_12_FailInferiorTo() throws {
        let output = try performTest(["test_relapse_inferior_to", "23", "<", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }
    
    
    /// Bizarro
    
    func test_13_BadPath() throws {
        let output = try performTest(["test_bad_path", "1", ">", "/etc/foo/bar/toto/ci.ci.sqlite3"])
        assertSnapshot(matching: output, as: .nserror)
    }

    func test_14_BadSign() throws {
        let output = try performTest(["test_bad_sign", "1", "-", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_15_BadNumber() throws {
        let output = try performTest(["test_bad_number", "aa", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_16_BadNumber() throws {
        let output = try performTest(["test_bad_number", "1.3", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }

    func test_17_Bad_LimiterKey() throws {
        let output = try performTest(["", "1", ">", ".test/ci/ci.sqlite3"])
        assertSnapshot(matching: output, as: .lines)
    }
    


    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("test_00_clean_init", test_00_clean_init),
        ("test_01_BadNumberOfArgument1", test_01_BadNumberOfArgument1),
        ("test_02_BadNumberOfArgument2", test_02_BadNumberOfArgument2),
        ("test_03_BadNumberOfArgument3", test_03_BadNumberOfArgument3),
        ("test_04_BadNumberOfArgument4", test_04_BadNumberOfArgument4),
        ("test_05_AddSuperiorTo", test_05_AddSuperiorTo),
        ("test_06_NoUpdateSuperiorTo", test_06_NoUpdateSuperiorTo),
        ("test_07_UpdateSuperiorTo", test_07_UpdateSuperiorTo),
        ("test_08_FailSuperiorTo", test_08_FailSuperiorTo),
        ("test_09_AddInferiorTo", test_09_AddInferiorTo),
        ("test_10_NoUpdateInferiorTo", test_10_NoUpdateInferiorTo),
        ("test_11_UpdateInferiorTo", test_11_UpdateInferiorTo),
        ("test_12_FailInferiorTo", test_12_FailInferiorTo),
        ("test_13_BadPath", test_13_BadPath),
        ("test_14_BadSign", test_14_BadSign),
        ("test_15_BadNumber", test_15_BadNumber),
        ("test_16_BadNumber", test_16_BadNumber),
        ("test_17_Bad_LimiterKey", test_17_Bad_LimiterKey),
    ]
}
