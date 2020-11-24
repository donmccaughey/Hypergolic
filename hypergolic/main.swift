import Foundation
import Network
import Hydrazine


let urlString = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "gemini://gemini.circumlunar.space/"
switch GeminiURL.parse(string: urlString) {
case .success(let geminiURL):
    GeminiTransaction(url: geminiURL.url, delegate: Delegate()).run()
    RunLoop.current.run()
case .failure(let error):
    print(error.errorMessage)
    exit(EXIT_FAILURE)
}
