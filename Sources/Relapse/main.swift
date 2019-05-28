import Foundation

do {
    let tool = try CLI()
    try tool.run()
} catch {
    print(error)
    exit(1)
}
exit(0)
