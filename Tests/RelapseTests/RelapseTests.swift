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
    
    func testExample() throws {
        
        let arguments = [
            ([], "Bad number of argument\n"),
            (["warning_relapse"], "Bad number of argument\n"),
            (["warning_relapse", "1"], "Bad number of argument\n"),
            (["warning_relapse", "1", ">"], "Bad number of argument\n"),
            (["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😆 - We have update the saved value to 1.\n"),
            (["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😐 - The new value(1) is equal to the stored value.\n"),
            (["warning_relapse", "5", ">", ".test/ci/ci.sqlite3"], "😆 - We have update the saved value to 5.\n"),
            (["warning_relapse", "1", ">", ".test/ci/ci.sqlite3"], "😫 - The test of \"1 > 5\" failed.\n"),
        ]
        
        for (args, expectedOutput) in arguments {
            print("Performing \(args) expect \(expectedOutput)")
            try performTest(args, expectedOutput)
        }
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
        ("testExample", testExample),
    ]
}
