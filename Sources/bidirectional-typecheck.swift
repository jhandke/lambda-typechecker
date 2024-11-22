//
// typecheck.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

enum BidirectionalTypecheckError: Error {
    case checkFailed(term: Term, type: Type, context: Context)
    case inferFailed(term: Term, context: Context)
    case noCheckRule(term: Term, type: Type, context: Context)
    case noInferRule(term: Term, context: Context)
}

func checkTypeBidirectional(term: Term, type: Type, context: Context) -> Bool {
    switch term {
    // (Fun<==)
    case let .abstraction(name, body):
        if case let .function(argumentType, resultType) = type {
            let updatedContext = context.merging([name: argumentType]) { _, new in new }
            return checkTypeBidirectional(term: body, type: resultType, context: updatedContext)
        }
        return false
    // (Check<==)
    default:
        do {
            let inferredType = try inferTypeBidirectional(term: term, context: context)
            if type == inferredType {
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
}

func inferTypeBidirectional(term: Term, context: Context) throws(BidirectionalTypecheckError) -> Type {
    switch term {
    // (True==>), (False==>)
    case .trueConstant, .falseConstant: return .boolean
    // (Int==>)
    case .integerConstant: return .integer
    // (Add==>)
    case let .addition(lhs, rhs):
        guard checkTypeBidirectional(term: lhs, type: .integer, context: context) else {
            fatalError("Typecheck error: \(lhs) is not an integer.")
        }
        guard checkTypeBidirectional(term: rhs, type: .integer, context: context) else {
            fatalError("Typecheck error: \(rhs) is not an integer.")
        }
        return .integer
    // (If==>)
    case let .conditional(test, thenBranch, elseBranch):
        if checkTypeBidirectional(term: test, type: .boolean, context: context) {
            let type2 = try inferTypeBidirectional(term: thenBranch, context: context)
            let type3 = try inferTypeBidirectional(term: elseBranch, context: context)
            if type2 == type3 {
                return type2
            }
        }
        throw BidirectionalTypecheckError.inferFailed(term: term, context: context)
    // (IsZero==>)
    case let .isZero(term):
        if checkTypeBidirectional(term: term, type: .integer, context: context) {
            return .boolean
        }
        throw BidirectionalTypecheckError.checkFailed(term: term, type: .integer, context: context)
    // (Var==>)
    case let .variable(name):
        if let type = context[name] {
            return type
        }
        throw BidirectionalTypecheckError.inferFailed(term: term, context: context)
    // (Apply==>)
    case let .application(function, argument):
        let functionType = try inferTypeBidirectional(term: function, context: context)
        if case let .function(argumentType, resultType) = functionType,
           checkTypeBidirectional(term: argument, type: argumentType, context: context) {
            return resultType
        }
        throw BidirectionalTypecheckError.inferFailed(term: term, context: context)
    // (Ascription==>)
    case let .ascription(term, type):
        if checkTypeBidirectional(term: term, type: type, context: context) {
            return type
        }
        throw BidirectionalTypecheckError.checkFailed(term: term, type: type, context: context)
    case .unit:
        return .unit
    default:
        throw BidirectionalTypecheckError.noInferRule(term: term, context: context)
    }
}
