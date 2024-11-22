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

func evaluate(inputTerm: Term) -> Value {
    switch inputTerm {
    case let .abstraction(name, body):
        return .functionValue(name: name, body: body)
    case let .addition(lhs, rhs):
        // rewrite with do try syntax
        let lhsEvaluated = evaluate(inputTerm: lhs)
        let rhsEvaluated = evaluate(inputTerm: rhs)
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
        let evaluatedFunction = evaluate(inputTerm: function)
        let evaluatedArgument = evaluate(inputTerm: argument)
        let mappedArgument: Term = map(evaluatedArgument)
        switch evaluatedFunction {
        case let .functionValue(name, body):
            let substituted = substitute(
                inputTerm: body,
                variableName: name,
                replacementTerm: mappedArgument
            )
            let result = evaluate(inputTerm: substituted)
            return result
        case .wildcard:
            fatalError("Not implemented.")
        default:
            fatalError("Evaluation error: \(evaluatedFunction) is not a function nor a wildcard.")
        }
    case let .ascription(term, _):
        return evaluate(inputTerm: term)
    case let .conditional(test, thenBranch, elseBranch):
        let evaluatedTest = evaluate(inputTerm: test)
        switch evaluatedTest {
        case .trueValue:
            let evaluatedThen = evaluate(inputTerm: thenBranch)
            return evaluatedThen
        case .falseValue:
            let evaluatedElse = evaluate(inputTerm: elseBranch)
            return evaluatedElse
        default:
            fatalError("Evaluation error: Expected boolean value in \(evaluatedTest)")
        }
    case .falseConstant: return .falseValue
    case .trueConstant: return .trueValue
    case let .integerConstant(value): return .integerValue(value: value)
    case let .isZero(term):
        let evaluatedTerm = evaluate(inputTerm: term)
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
        let evaluatedHead = evaluate(inputTerm: head)
        let evaluatedTail = evaluate(inputTerm: tail)
        return .cons(evaluatedHead, evaluatedTail)
    case let .isEmpty(list):
        let evaluatedList = evaluate(inputTerm: list)
        if case .nilValue = evaluatedList {
            return .trueValue
        }
        return .falseValue
    case let .head(list):
        if case let .cons(head, _) = list {
            return evaluate(inputTerm: head)
        }
        fatalError("Evaluation error: \(list) is not a list.")
    case let .tail(list: list):
        if case let .cons(_, tail) = list {
            return evaluate(inputTerm: tail)
        }
        fatalError("Evaluation error: \(list) is not a list.")
    case let .string(value):
        return .string(value: value)
    case let .wildcard(body):
        return .wildcard(body: evaluate(inputTerm: body))
    }
    fatalError("Evaluation error: No rule for \(inputTerm)")
}
