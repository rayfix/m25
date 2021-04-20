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


  mutating func run() throws {

    let orderedQuestions = numbersToStudy.flatMap { numberToStudy in
      (from...to).map { b in
        Multiplication(a: numberToStudy, b: b)
      }
    }

    let allQuestions = isOrdered ? orderedQuestions : orderedQuestions.shuffled()

    let questions = limit.map { Array(allQuestions.prefix($0)) } ?? allQuestions

    var correctResponseCount = 0

    for question in questions {

      print(question.question)

      let response = readLine(strippingNewline: true)?
        .trimmingCharacters(in: .whitespaces)

      if response == question.answer {
        print("Correct!")
        correctResponseCount += 1
      }
      else {
        print("Incorrect. The correct answer is \(question.answer)")
      }
    }

    let performance = Int(Double(correctResponseCount) / Double(questions.count) * 100)
    print("Finished \(performance)%")
  }
}

RunQuiz.main()
