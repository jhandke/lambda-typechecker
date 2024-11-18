//
// Type.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

typealias Context = [String: Type]

indirect enum Type {
    case boolean
    case integer
    case function(argumentType: Type, resultType: Type)
    case variable(name: String)
}

extension Type: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.boolean, .boolean), (.integer, .integer): return true
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
        }
    }
}
