//
// main.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

let firstIf: Term = .conditional(test: .variable(name: "x"),
                                 thenBranch: .abstraction(name: "x", body: .variable(name: "x")),
                                 elseBranch: .variable(name: "x"))

let secondIf: Term = .conditional(test: .variable(name: "x"),
                                  thenBranch: .abstraction(name: "z", body: .variable(name: "x")),
                                  elseBranch: .variable(name: "x"))

let testIsZero: Term = .conditional(test: .isZero(term: .application(function: .abstraction(name: "x", body: .variable(name: "x")),
                                                                     argument: .integerConstant(value: 0))),
                                    thenBranch: .integerConstant(value: 42),
                                    elseBranch: .integerConstant(value: 1337))

let testApplication: Term = .application(function: .abstraction(name: "x",
                                                                body: .conditional(test: .isZero(term: .variable(name: "x")),
                                                                                   thenBranch: .integerConstant(value: 23),
                                                                                   elseBranch: .integerConstant(value: 100))),
                                         argument: .integerConstant(value: 2))

do {
    try print("Result: \(evaluate(inputTerm: testApplication))")
} catch {
    print(error)
}

// _ = substitute(inputTerm: firstIf, variableName: "x", replacementTerm: .integerConstant(value: 20), debug: true)
// _ = substitute(inputTerm: secondIf, variableName: "x", replacementTerm: .isZero(term: .variable(name: "y")), debug: true)

// do {
//     let isZeroResult = try evaluate(inputTerm: testIsZero)
//     print(isZeroResult)
// } catch {
//     print(error)
// }
