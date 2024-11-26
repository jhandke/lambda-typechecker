//
// bidirectional-typecheck.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

func checkTypeBidirectional(term: Term, type: Type, context: Context) throws(TypeError) -> Bool {
    switch term {
    // (Fun<==)
    case let .abstraction(name, body):
        if case let .function(argumentType, resultType) = type {
            let updatedContext = context.merging([name: argumentType]) { _, new in new }
            return try checkTypeBidirectional(term: body, type: resultType, context: updatedContext)
        }
        return false
    // (Wildcard<==)
    case let .wildcard(body):
        if case let .function(_, resultType) = type {
            return try checkTypeBidirectional(term: body, type: resultType, context: context)
        }
        return false
    // (Nil<==)
    case .nilTerm:
        if case .list = type {
            return true
        }
        return false
    // (Check<==)
    default:
        let inferredType = try inferTypeBidirectional(term: term, context: context)
        if type == inferredType {
            return true
        }
        return false
    }
}

func inferTypeBidirectional(term: Term, context: Context) throws(TypeError) -> Type {
    switch term {
    // (True==>), (False==>)
    case .trueConstant, .falseConstant: return .boolean
    // (Int==>)
    case .integerConstant: return .integer
    // (Add==>)
    case let .addition(lhs, rhs):
        guard try checkTypeBidirectional(term: lhs, type: .integer, context: context) else {
            throw .checkFailed(term: lhs, expectedType: .integer)
        }
        guard try checkTypeBidirectional(term: rhs, type: .integer, context: context) else {
            throw .checkFailed(term: rhs, expectedType: .integer)
        }
        return .integer
    // (If==>)
    case let .conditional(test, thenBranch, elseBranch):
        guard try checkTypeBidirectional(term: test, type: .boolean, context: context) else {
            throw .checkFailed(term: test, expectedType: .boolean)
        }
        let thenType = try inferTypeBidirectional(term: thenBranch, context: context)
        let elseType = try inferTypeBidirectional(term: elseBranch, context: context)
        guard thenType == elseType else {
            throw .typeMismatch(thenType, elseType)
        }
        return thenType
    // (IsZero==>)
    case let .isZero(term):
        guard try checkTypeBidirectional(term: term, type: .integer, context: context) else {
            throw .checkFailed(term: term, expectedType: .integer)
        }
        return .boolean
    // (Var==>)
    case let .variable(name):
        guard let type = context[name] else {
            throw .variableNotInContext(name: name)
        }
        return type
    // (Apply==>)
    case let .application(function, argument):
        let functionType = try inferTypeBidirectional(term: function, context: context)
        guard case let .function(argumentType, resultType) = functionType else {
            throw .typeMismatch(functionType, .function(argumentType: .variable(name: "any"), resultType: .variable(name: "any")))
        }
        guard try checkTypeBidirectional(term: argument, type: argumentType, context: context) else {
            throw .checkFailed(term: argument, expectedType: argumentType)
        }
        return resultType
    // (Ascription==>)
    case let .ascription(term, type):
        guard try checkTypeBidirectional(term: term, type: type, context: context) else {
            throw .checkFailed(term: term, expectedType: type)
        }
        return type
    // (String==>)
    case .string:
        return .stringType
    // (Unit==>)
    case .unit:
        return .unit
    // (Cons==>)
    case let .cons(head, tail):
        let headType = try inferTypeBidirectional(term: head, context: context)
        let listType: Type = .list(type: headType)
        guard try checkTypeBidirectional(term: tail, type: listType, context: context) else {
            throw .typeMismatch(headType, listType)
        }
        return listType
    // (Head==>)
    case let .head(list):
        let listType = try inferTypeBidirectional(term: list, context: context)
        guard case let .list(elementType) = listType else {
            throw .badTypeIn(term: list, actualType: listType, expectedType: .list(type: .variable(name: "any")))
        }
        return elementType
    case let .tail(list):
        return try inferTypeBidirectional(term: list, context: context)
    case let .isEmpty(list):
        let listType = try inferTypeBidirectional(term: list, context: context)
        guard case .list = listType else {
            throw .badTypeIn(term: list, actualType: listType, expectedType: .list(type: .variable(name: "any")))
        }
        return .boolean
    default:
        fatalError("Type error: No infer rule available for \(term).")
    }
}
