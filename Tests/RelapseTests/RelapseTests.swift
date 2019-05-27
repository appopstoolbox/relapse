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
    
    func testBasNumberOfArgument1() throws {
        try performTest([], "Bad number of argument\n")
    }

    func testBasNumberOfArgument2() throws {
        try performTest(["warning_relapse"], "Bad number of argument\n")
    }

    func testBasNumberOfArgument3() throws {
        try performTest(["warning_relapse", "1"], "Bad number of argument\n")
    }

    func testBasNumberOfArgument4() throws {
        try performTest(["warning_relapse", "1", ">"], "Bad number of argument\n")
    }

    func testBasNumberOfArgument5() throws {
        try performTest(["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😆 - We have added this new value.\n")
    }

    func testBasNumberOfArgument6() throws {
        try performTest(["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😐 - The new value(1) is equal to the stored value.\n")
    }
    
    func testBasNumberOfArgument7() throws {
        try performTest(["warning_relapse", "5", ">", ".test/ci/ci.sqlite3"], "😆 - We have update the saved value to 5.\n")
    }
    
    func testBasNumberOfArgument8() throws {
        try performTest(["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😫 - The test of \"1 > 5\" failed.\n")
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
        ("testBasNumberOfArgument1", testBasNumberOfArgument1),
        ("testBasNumberOfArgument2", testBasNumberOfArgument2),
        ("testBasNumberOfArgument3", testBasNumberOfArgument3),
        ("testBasNumberOfArgument4", testBasNumberOfArgument4),
        ("testBasNumberOfArgument5", testBasNumberOfArgument5),
        ("testBasNumberOfArgument6", testBasNumberOfArgument6),
        ("testBasNumberOfArgument7", testBasNumberOfArgument7),
        ("testBasNumberOfArgument8", testBasNumberOfArgument8),
    ]
}
