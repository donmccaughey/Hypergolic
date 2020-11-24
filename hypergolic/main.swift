import Foundation
import Network
import Hydrazine


let urlString = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "gemini://gemini.circumlunar.space/"
let url: URL
switch GeminiURL.parse(urlString: urlString) {
case .url(let value):
    url = value
case .error(let error):
    print(error.errorMessage)
    exit(EXIT_FAILURE)
}

let transaction = GeminiTransaction(url: url, delegate: Delegate())

NSLog("Starting")
transaction.connection.start(queue: transaction.queue)

NSLog("Sending")
let requestString = "\(transaction.url)\r\n"
NSLog(">>> \(requestString)")
let request = requestString.data(using: .utf8)
transaction.connection.send(content: request, completion: .idempotent)

func receive() {
    NSLog("Receiving")
    transaction.connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { (data, contentContext, isComplete, error) in
        if let data = data, !data.isEmpty {
            if let response = String(data: data, encoding: .utf8) {
                print("<<< \(response)")
            } else {
                NSLog("Encoding error in response")
                exit(EXIT_FAILURE)
            }
        }
        if let contentContext = contentContext, contentContext.isFinal {
            NSLog("Received final content")
            exit(EXIT_SUCCESS);
        }
        if isComplete {
            NSLog("Receive complete")
            exit(EXIT_SUCCESS);
        }
        if let error = error {
            NSLog("Receive error: \(error)")
            exit(EXIT_FAILURE)
        }
        receive()
    }
}
receive()

RunLoop.current.run()
