import Foundation
import Network
import Hydrazine


let urlString = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "gemini://gemini.circumlunar.space/"
switch GeminiURL.parse(urlString: urlString) {
case .url(let url):
    GeminiTransaction(url: url, delegate: Delegate()).run()
case .error(let error):
    print(error.errorMessage)
    exit(EXIT_FAILURE)
}

RunLoop.current.run()
