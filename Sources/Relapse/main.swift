import Foundation

do {
    let tool = try CLI()
    try tool.run()
} catch {
    print(error)
    exit(0)
}
exit(1)
