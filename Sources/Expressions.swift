//
// Expressions.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
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
    case string(value: String)
    case unit
    case nilTerm
    case cons(head: Term, tail: Term)
    case isEmpty(list: Term)
    case head(list: Term)
    case tail(list: Term)
    case variable(name: String)
    case wildcard(body: Term)
}

extension Term: Equatable {
    static func == (lhs: Term, rhs: Term) -> Bool {
        switch (lhs, rhs) {
        case (.falseConstant, .falseConstant), (.trueConstant, .trueConstant), (.unit, .unit): return true
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
        case let (.string(lhsString), .string(rhsString)): return lhsString == rhsString
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
        case .unit:
            return "unit"
        case .nilTerm:
            return "nil"
        case let .cons(first, second):
            return "(list \(first), \(second))"
        case let .isEmpty(list):
            return "(isEmpty? \(list))"
        case let .head(list):
            return "(head \(list))"
        case let .tail(list):
            return "(tail \(list))"
        case let .string(value):
            return "\"\(value)\""
        case .wildcard(body: let body):
            return "(λ_.\(body))"
        }
    }
}

// MARK: Value

indirect enum Value {
    case falseValue
    case trueValue
    case integerValue(value: Int)
    case functionValue(name: String, body: Term)
    case unit
    case nilValue
    case cons(Value, Value)
    case string(value: String)
    case wildcard(body: Value)
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
        case .unit:
            return "unit"
        case let .string(value):
            return "\"\(value)\""
        case .nilValue:
            return "nil"
        case let .cons(first, second):
            return "(cons \(first) \(second))"
        case let .wildcard(body):
            return "(🔧_.\(body))"
        }
    }
}

extension Value: Equatable {
    static func == (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.falseValue, .falseValue), (.trueValue, .trueValue), (.unit, .unit):
            return true
        case let (.integerValue(lhsValue), .integerValue(rhsValue)):
            return lhsValue == rhsValue
        case let (.functionValue(lhsName, lhsBody), .functionValue(rhsName, rhsBody)):
            return lhsName == rhsName && lhsBody == rhsBody
        case let (.string(lhsValue), .string(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
