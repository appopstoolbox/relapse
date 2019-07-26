import Foundation

do {
    let tool = try CLI()
    try tool.run()
} catch {
    print("Error: \(error)")
    exit(EXIT_FAILURE)
}
exit(EXIT_SUCCESS)
