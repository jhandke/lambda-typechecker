//
// main.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

// let firstIf: Term = .conditional(test: .variable(name: "x"),
//                                  thenBranch: .abstraction(name: "x", body: .variable(name: "x")),
//                                  elseBranch: .variable(name: "x"))

// let secondIf: Term = .conditional(test: .variable(name: "x"),
//                                   thenBranch: .abstraction(name: "z", body: .variable(name: "x")),
//                                   elseBranch: .variable(name: "x"))

// let testIsZero: Term = .conditional(test: .isZero(term: .integerConstant(value: 23)),
//                                     thenBranch: .integerConstant(value: 42),
//                                     elseBranch: .integerConstant(value: 1337))

// let testApplication: Term = .application(function: .ascription(term: .abstraction(name: "x",
//                                                                                   body: .conditional(test: .isZero(term: .variable(name: "x")),
//                                                                                                      thenBranch: .integerConstant(value: 23),
//                                                                                                      elseBranch: .integerConstant(value: 100))),
//                                                                type: .function(argumentType: .integer, resultType: .integer)),
//  argument: .integerConstant(value: 2))

// let secondExample: Term = .application(function: .ascription(term: .abstraction(name: "x", body: .isZero(term: .variable(name: "x"))),
//                                                              type: .function(argumentType: .integer, resultType: .boolean)), argument: .integerConstant(value: 1))

// print(secondExample)
// do {
//     let inferredType = try inferType(term: secondExample, context: [:])
//     print(inferredType)
// } catch {
//     print(error)
// }

// _ = substitute(inputTerm: firstIf, variableName: "x", replacementTerm: .integerConstant(value: 20), debug: true)
// _ = substitute(inputTerm: secondIf, variableName: "x", replacementTerm: .isZero(term: .variable(name: "y")), debug: true)

// do {
//     let isZeroResult = try evaluate(inputTerm: testIsZero)
//     print(isZeroResult)
// } catch {
//     print(error)
// }

// task4()

let term: Term = .conditional(test: .isZero(term: .integerConstant(value: 0)),
                              thenBranch: .application(function: .abstraction(name: "x",
                                                                              body: .addition(lhs: .variable(name: "x"),
                                                                                              rhs: .integerConstant(value: 2))),
                                                       argument: .integerConstant(value: 4)),
                              elseBranch: .falseConstant)
print(term)
print(inferTypesUnification(term: term, context: [:]))
