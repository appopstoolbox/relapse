import XCTest
import class Foundation.Bundle

final class RelapseTests: XCTestCase {
    
    func performTest(_ args : [String], _ expectedOutput : String) throws {
        guard #available(macOS 10.13, *) else { return }

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
        
        XCTAssertEqual(output, expectedOutput)
    }
    
    
    //// BadNumberOfArgument
    
    func test_01_BadNumberOfArgument1() throws {
        try performTest([], "Bad number of argument\n")
    }

    func test_02_BadNumberOfArgument2() throws {
        try performTest(["test_relapse_superior_to"], "Bad number of argument\n")
    }

    func test_03_BadNumberOfArgument3() throws {
        try performTest(["test_relapse_superior_to", "1"], "Bad number of argument\n")
    }

    func test_04_BadNumberOfArgument4() throws {
        try performTest(["test_relapse_superior_to", "1", ">"], "Bad number of argument\n")
    }
    
    //// SuperiorTo

    func test_05_AddSuperiorTo() throws {
        try performTest(["test_relapse_superior_to", "1", ">", ".test/ci/ci.sqlite3"], "😆 - We have added this new value.\n")
    }

    func test_06_NoUpdateSuperiorTo() throws {
        try performTest(["test_relapse_superior_to", "1", ">", ".test/ci/ci.sqlite3"], "😐 - The new value(1) is equal to the stored value.\n")
    }
    
    func test_07_UpdateSuperiorTo() throws {
        try performTest(["test_relapse_superior_to", "5", ">", ".test/ci/ci.sqlite3"], "😆 - We have update the saved value to 5.\n")
    }
    
    func test_08_FailSuperiorTo() throws {
        try performTest(["test_relapse_superior_to", "3", ">", ".test/ci/ci.sqlite3"], "😫 - The test of \"3 > 5\" failed.\n")
    }

    //// InferiorTo
    
    func test_09_AddInferiorTo() throws {
        try performTest(["test_relapse_inferior_to", "25", "<", ".test/ci/ci.sqlite3"], "😆 - We have added this new value.\n")
    }
    
    func test_10_NoUpdateInferiorTo() throws {
        try performTest(["test_relapse_inferior_to", "25", "<", ".test/ci/ci.sqlite3"], "😐 - The new value(25) is equal to the stored value.\n")
    }
    
    func test_11_UpdateInferiorTo() throws {
        try performTest(["test_relapse_inferior_to", "2", "<", ".test/ci/ci.sqlite3"], "😆 - We have update the saved value to 2.\n")
    }
    
    func test_12_FailInferiorTo() throws {
        try performTest(["test_relapse_inferior_to", "23", "<", ".test/ci/ci.sqlite3"], "😫 - The test of \"23 < 2\" failed.\n")
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
    ]
}
