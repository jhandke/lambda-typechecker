//
// evaluate.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

func evaluate(inputTerm: Term) throws(EvaluationError) -> Value {
    switch inputTerm {
    case let .abstraction(name, body):
        return .functionValue(name: name, body: body)
    case let .addition(lhs, rhs):
        if let lhsEvaluated = try? evaluate(inputTerm: lhs),
           let rhsEvaluated = try? evaluate(inputTerm: rhs),
           case let .integerValue(lhsValue) = lhsEvaluated,
           case let .integerValue(rhsValue) = rhsEvaluated {
            return Value.integerValue(value: lhsValue + rhsValue)
        } else {
            throw .additionError(lhs: lhs, rhs: rhs)
        }
    case let .application(function, argument):
        do {
            let evaluatedFunction = try evaluate(inputTerm: function)
            if case let .functionValue(name, body) = evaluatedFunction {
                let evaluatedArgument = try evaluate(inputTerm: argument)
                let mappedTerm: Term =
                    switch evaluatedArgument {
                    case .falseValue: .falseConstant
                    case .trueValue: .trueConstant
                    case let .functionValue(name, body): .abstraction(name: name, body: body)
                    case let .integerValue(value): .integerConstant(value: value)
                    }
                let substituted = substitute(inputTerm: body,
                                             variableName: name,
                                             replacementTerm: mappedTerm)
                let result = try evaluate(inputTerm: substituted)
                return result
            } else {
                throw EvaluationError.notAFunction(function)
            }
        } catch {
            print(error)
            throw .applicationFailed(function: function, argument: argument)
        }
    case let .conditional(test, thenBranch, elseBranch):
        do {
            let evaluatedTest = try evaluate(inputTerm: test)
            switch evaluatedTest {
            case .trueValue:
                let evaluatedThen = try evaluate(inputTerm: thenBranch)
                return evaluatedThen
            case .falseValue:
                let evaluatedElse = try evaluate(inputTerm: elseBranch)
                return evaluatedElse
            default:
                throw EvaluationError.wrongValue(actual: evaluatedTest, message: "Expected boolean value.")
            }
        } catch {
            print(error)
            throw .conditionalFailed(test)
        }
    case .falseConstant: return .falseValue
    case .trueConstant: return .trueValue
    case let .integerConstant(value): return .integerValue(value: value)
    case let .isZero(term):
        do {
            let evaluatedTerm = try evaluate(inputTerm: term)
            switch evaluatedTerm {
            case let .integerValue(value):
                if value == 0 {
                    return .trueValue
                } else {
                    return .falseValue
                }
            default:
                throw EvaluationError.wrongValue(actual: evaluatedTerm, message: "Expected integer value.")
            }
        } catch {
            print(error)
            throw .isZeroFailed(term)
        }
    case .variable:
        throw .unexpectedVariable
    }
}
