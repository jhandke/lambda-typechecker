//
// Type.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

import Foundation

typealias Context = [String: Type]

extension Context {
    mutating func add(name: String, type: Type) {
        self[name] = type
    }

    func adding(name: String, type: Type) -> Self {
        var copy = self
        copy.add(name: name, type: type)
        return copy
    }
}

indirect enum Type {
    case boolean
    case integer
    case function(argumentType: Type, resultType: Type)
    case unit
    case stringType
    case list(type: Type)
    case variable(name: String)
}

enum TypeError: Error {
    case typeMismatch(Type, Type)
    case badTypeIn(term: Term, actualType: Type, expectedType: Type)
    case checkFailed(term: Term, expectedType: Type)
    case variableNotInContext(name: String)
    case unificationFailed(Type, Type)
}

extension TypeError {
    var description: String {
        switch self {
        case let .typeMismatch(lhs, rhs):
            return "TypeError: Type mismatch between \(lhs) and \(rhs)."
        case let .badTypeIn(term, actualType, expectedType):
            return "TypeError: Exptected \(expectedType) but got \(actualType) in \(term)."
        case let .checkFailed(term, expectedType):
            return "TypeError: Type check failed with type \(expectedType) in \(term)."
        case let .variableNotInContext(name):
            return "TypeError: Variable \(name) not found in context."
        case let .unificationFailed(lhs, rhs):
            return "TypeError: Unification of \(lhs) and \(rhs) failed."
        }
    }
}

extension Type: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.boolean, .boolean), (.integer, .integer), (.stringType, .stringType): return true
        case let (.function(lhsArgumentType, lhsResultType), .function(rhsArgumentType, rhsResultType)):
            return lhsArgumentType == rhsArgumentType && lhsResultType == rhsResultType
        case let (.variable(lhsName), .variable(rhsName)): return lhsName == rhsName
        default: return false
        }
    }
}

extension Type: CustomStringConvertible {
    var description: String {
        switch self {
        case .boolean: "Bool"
        case .integer: "Int"
        case let .function(argumentType, resultType): "(\(argumentType) -> \(resultType))"
        case let .variable(name): "var(\(name))"
        case .stringType: "String"
        case .unit: "unit"
        case let .list(type): "List<\(type)>"
        }
    }
}
