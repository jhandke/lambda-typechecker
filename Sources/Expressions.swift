//
// Expressions.swift
// Created by Jakob Handke on 2024-10-23.
//

// MARK: Term

indirect enum Term {
    case abstraction(name: String, body: Term)
    case addition(lhs: Term, rhs: Term)
    case application(function: Term, argument: Term)
    case ascription(term: Term, type: Type)
    case conditional(test: Term, thenBranch: Term, elseBranch: Term)
    case integerConstant(value: Int)
    case isZero(term: Term)
    case falseConstant
    case trueConstant
    case variable(name: String)
}

extension Term: Equatable {
    static func == (lhs: Term, rhs: Term) -> Bool {
        switch (lhs, rhs) {
        case (.falseConstant, .falseConstant), (.trueConstant, .trueConstant): return true
        case let (.abstraction(lhsName, lhsBody), .abstraction(rhsName, rhsBody)):
            return lhsName == rhsName && lhsBody == rhsBody
        case let (.application(lhsFunction, lhsArgument), .application(rhsFunction, rhsArgument)):
            return lhsFunction == rhsFunction && lhsArgument == rhsArgument
        case let (.ascription(lhsTerm, lhsType), .ascription(rhsTerm, rhsType)):
            return lhsTerm == rhsTerm && lhsType == rhsType
        case let (.conditional(lhsTest, lhsThen, lhsElse), .conditional(rhsTest, rhsThen, rhsElse)):
            return lhsTest == rhsTest && lhsThen == rhsThen && lhsElse == rhsElse
        case let (.integerConstant(lhsValue), .integerConstant(rhsValue)):
            return lhsValue == rhsValue
        case let (.isZero(lhsTerm), .isZero(rhsTerm)):
            return lhsTerm == rhsTerm
        case let (.variable(lhsName), .variable(name: rhsName)):
            return lhsName == rhsName
        default: return false
        }
    }
}

extension Term: CustomStringConvertible {
    var description: String {
        switch self {
        case let .abstraction(name, body):
            return "(λ\(name).\(body))"
        case let .addition(lhs, rhs):
            return "(+ \(lhs) \(rhs))"
        case let .application(function, argument):
            return "(\(function) \(argument))"
        case let .ascription(term, type):
            return "(\(term) : \(type))"
        case let .conditional(test, thenBranch, elseBranch):
            return "(if \(test) \(thenBranch) \(elseBranch))"
        case .falseConstant:
            return "false"
        case .trueConstant:
            return "true"
        case let .integerConstant(value):
            return "\(value)"
        case let .isZero(term):
            return "(isZero? \(term))"
        case let .variable(name):
            return name
        }
    }
}

// MARK: Value

enum Value {
    case falseValue
    case trueValue
    case integerValue(value: Int)
    case functionValue(name: String, body: Term)
}

extension Value: CustomStringConvertible {
    var description: String {
        switch self {
        case .falseValue:
            return "false"
        case .trueValue:
            return "true"
        case let .integerValue(value):
            return "\(value)"
        case let .functionValue(name, body):
            return "(🔧\(name).\(body))"
        }
    }
}

extension Value: Equatable {
    static func == (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.falseValue, .falseValue), (.trueValue, .trueValue):
            return true
        case let (.integerValue(lhsValue), .integerValue(rhsValue)):
            return lhsValue == rhsValue
        case let (.functionValue(lhsName, lhsBody), .functionValue(rhsName, rhsBody)):
            return lhsName == rhsName && lhsBody == rhsBody
        default:
            return false
        }
    }
}

// MARK: EvaluationError

enum EvaluationError: Error {
    // case unsupported(input: Term)
    case additionError(lhs: Term, rhs: Term)
    case ascriptionFailed(term: Term, type: Type)
    case wrongValue(actual: Value, message: String)
    case notAFunction(Term)
    case unexpectedVariable
    case isZeroFailed(Term)
    case conditionalFailed(Term)
    case applicationFailed(function: Term, argument: Term)
}
