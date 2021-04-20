//
//  main.swift
//
//  Created by Ray Fix on 4/19/21.
//

import Foundation
import ArgumentParser

struct Multiplication {
  var a, b: Int
  var question: String { "\(a)·\(b)" }
  var answer: String { "\(a*b)" }
}

struct RunQuiz: ParsableCommand {

  static var configuration: CommandConfiguration {
    CommandConfiguration(commandName: "m25")
  }

  @Argument(help: "Specify the numbers to study.")
  var numbersToStudy: [Int]

  @Option(name: .shortAndLong)
  var limit: Int?

  @Option(name: .shortAndLong)
  var from: Int = 2

  @Option(name: .shortAndLong)
  var to: Int = 25

  @Flag(name: .customLong("order"), help: "Do not shuffle the questions.")
  var isOrdered: Bool = false

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

    print("Multiplication Practice for \(numbersToStudy.map(String.init).joined(separator: ", ")).")

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
