//
// evaluate.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

func map(_ value: Value) -> Term {
    return switch value {
    case .falseValue: .falseConstant
    case .trueValue: .trueConstant
    case let .functionValue(name, body): .abstraction(name: name, body: body)
    case let .integerValue(value): .integerConstant(value: value)
    case .unit: .unit
    case .nilValue: .nilTerm
    case let .cons(head, tail):
        .cons(head: map(head), tail: map(tail))
    case let .string(value): .string(value: value)
    case let .wildcard(body): .wildcard(body: map(body))
    }
}

func evaluate(inputTerm: Term) throws(TypeError) -> Value {
    switch inputTerm {
    case let .abstraction(name, body):
        return .functionValue(name: name, body: body)
    case let .addition(lhs, rhs):
        // rewrite with do try syntax
        let lhsEvaluated = try evaluate(inputTerm: lhs)
        let rhsEvaluated = try evaluate(inputTerm: rhs)
        if case let .integerValue(lhsValue) = lhsEvaluated {
            if case let .integerValue(rhsValue) = rhsEvaluated {
                return Value.integerValue(value: lhsValue + rhsValue)
            } else {
                fatalError("Evaluation error: \(rhsEvaluated) is not an integer value.")
            }
        } else {
            fatalError("Evaluation error: \(lhsEvaluated) is not an integer value.")
        }
    case let .application(function, argument):
        let evaluatedFunction = try evaluate(inputTerm: function)
        let evaluatedArgument = try evaluate(inputTerm: argument)
        let mappedArgument: Term = map(evaluatedArgument)
        switch evaluatedFunction {
        case let .functionValue(name, body):
            let substituted = substitute(
                inputTerm: body,
                variableName: name,
                replacementTerm: mappedArgument
            )
            let result = try evaluate(inputTerm: substituted)
            return result
        case .wildcard:
            fatalError("Not implemented.")
        default:
            fatalError("Evaluation error: \(evaluatedFunction) is not a function nor a wildcard.")
        }
    case let .ascription(term, _):
        return try evaluate(inputTerm: term)
    case let .conditional(test, thenBranch, elseBranch):
        let evaluatedTest = try evaluate(inputTerm: test)
        switch evaluatedTest {
        case .trueValue:
            let evaluatedThen = try evaluate(inputTerm: thenBranch)
            return evaluatedThen
        case .falseValue:
            let evaluatedElse = try evaluate(inputTerm: elseBranch)
            return evaluatedElse
        default:
            fatalError("Evaluation error: Expected boolean value in \(evaluatedTest)")
        }
    case .falseConstant: return .falseValue
    case .trueConstant: return .trueValue
    case let .integerConstant(value): return .integerValue(value: value)
    case let .isZero(term):
        let evaluatedTerm = try evaluate(inputTerm: term)
        switch evaluatedTerm {
        case let .integerValue(value):
            if value == 0 {
                return .trueValue
            } else {
                return .falseValue
            }
        default:
            fatalError("Evaluation error: Expected integer value in \(evaluatedTerm)")
        }
    case .variable:
        fatalError("Evaluation error: Unexpected variable.")
    case .unit:
        return .unit
    case .nilTerm:
        return .nilValue
    case let .cons(head, tail):
        let evaluatedHead = try evaluate(inputTerm: head)
        let evaluatedTail = try evaluate(inputTerm: tail)
        return .cons(head: evaluatedHead, tail: evaluatedTail)
    case let .isEmpty(list):
        let evaluatedList = try evaluate(inputTerm: list)
        switch evaluatedList {
        case .nilValue:
            return .trueValue
        case .cons:
            return .falseValue
        default: fatalError("Evaluation error: \(evaluatedList) is not a list.")
        }
    case let .head(list):
        guard case let .cons(head, _) = list else {
            fatalError("Evaluation error: \(list) is not a list.")
        }
        return try evaluate(inputTerm: head)
    case let .tail(list: list):
        guard case let .cons(_, tail) = list else {
            fatalError("Evaluation error: \(list) is not a list.")
        }
        return try evaluate(inputTerm: tail)
    case let .string(value):
        return .string(value: value)
    case let .wildcard(body):
        return .wildcard(body: try evaluate(inputTerm: body))
    case let .letBinding(name, value, body):
        let substitutedBody = substitute(inputTerm: body, variableName: name, replacementTerm: value)
        return try evaluate(inputTerm: substitutedBody)
    }
    fatalError("Evaluation error: No rule for \(inputTerm)")
}
