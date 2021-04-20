// Copyright 2021 Ray Fix
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import ArgumentParser

struct Multiplication {
  var a, b: Int
  var question: String { "\(a)·\(b)" }
  var answer: String { "\(a*b)" }
}

struct RunQuiz: ParsableCommand {

  static var configuration: CommandConfiguration {
    CommandConfiguration(commandName: "m25",
                         discussion: """
        Practice multiplication tables 25x25

        Examples:
           # Practice 12x2 up to 12x25 scrambled.
           m25 12

           # Practice 12x2 up to 12x25, present questions in order.
           m25 --order 12

           # Practice 12, 13, and 14
           m25 12 13 14

           # Practice 15, 16 but limit to 10 questions.
           m25 15 16 --limit 10

           # Show 12x2 to 12x25 in order and exit.
           m25 12 --show --order

           # Show 12x12 to 12x24 in order and exit
           m25 12 --show --order --from 12 --to 24
      """)
  }

  @Argument(help: "Specify the numbers to study.")
  var numbersToStudy: [Int]

  @Option(name: .shortAndLong, help: "Limit the number of questions.")
  var limit: Int?

  @Option(name: .shortAndLong, help: "The start of the multiplication table.")
  var from: Int = 2

  @Option(name: .shortAndLong, help: "The end of the multiplication table.")
  var to: Int = 25

  @Flag(name: .customLong("order"), help: "Do not shuffle the questions.")
  var isOrdered: Bool = false

  @Flag(name: .customLong("show"), help: "Show answers and exit.")
  var showAnswersAndExit = false

  private func separator(isDouble: Bool) -> String {
    String(repeating: isDouble ? "=" : "-", count: 50)
  }

  mutating func run() throws {

    let orderedMultiplications = numbersToStudy.flatMap { numberToStudy in
      (from...to).map { b in
        Multiplication(a: numberToStudy, b: b)
      }
    }

    let allMultiplications = isOrdered ? orderedMultiplications : orderedMultiplications.shuffled()

    let multiplications = limit.map { Array(allMultiplications.prefix($0)) } ?? allMultiplications

    var correctResponseCount = 0

    print("Multiplication \(numbersToStudy.map(String.init).joined(separator: ", ")).")
    print(separator(isDouble: true))

    guard !showAnswersAndExit else {
      multiplications.forEach { multiplication in
        print(multiplication.question, "=", multiplication.answer)
      }
      return
    }

    for (offset, multiplication) in multiplications.enumerated() {

      print(separator(isDouble: false))
      print("Question \(offset+1) of \(multiplications.count)")
      print(multiplication.question)

      let response = readLine(strippingNewline: true)?
        .trimmingCharacters(in: .whitespaces)

      if response == multiplication.answer {
        print("⭐️ Correct")
        correctResponseCount += 1
      }
      else {
        print("❌ Incorrect \(multiplication.question) = \(multiplication.answer)")
      }
    }

    let performance = Int(Double(correctResponseCount) / Double(multiplications.count) * 100)
    print(separator(isDouble: true))
    print("🏁🏁🏁 Finished \(performance)% 🏁🏁🏁")
    print(separator(isDouble: true))
  }
}

RunQuiz.main()
