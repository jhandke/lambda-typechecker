//
// bidirectional-typecheck.swift
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
        let inferredType = inferTypeBidirectional(term: term, context: context)
        if type == inferredType {
            return true
        }
        return false
    }
}

func inferTypeBidirectional(term: Term, context: Context) -> Type {
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
        guard checkTypeBidirectional(term: test, type: .boolean, context: context) else {
            fatalError("Type error: \(test) is not of type boolean.")
        }
        let type2 = inferTypeBidirectional(term: thenBranch, context: context)
        let type3 = inferTypeBidirectional(term: elseBranch, context: context)
        guard type2 == type3 else {
            fatalError("Type error: \(type2) and \(type3) are not equal.")
        }
        return type2
    // (IsZero==>)
    case let .isZero(term):
        guard checkTypeBidirectional(term: term, type: .integer, context: context) else {
            fatalError("Type error: \(term) is not of type integer.")
        }
        return .boolean
    // (Var==>)
    case let .variable(name):
        guard let type = context[name] else {
            fatalError("Type error: Variable \(name) does not exist in context.")
        }
        return type
    // (Apply==>)
    case let .application(function, argument):
        let functionType = inferTypeBidirectional(term: function, context: context)
        guard case let .function(argumentType, resultType) = functionType else {
            fatalError("Type error: \(functionType)")
        }
        guard checkTypeBidirectional(term: argument, type: argumentType, context: context) else {
            fatalError("Type error: \(argument) is not of type \(argumentType).")
        }
        return resultType
    // (Ascription==>)
    case let .ascription(term, type):
        guard checkTypeBidirectional(term: term, type: type, context: context) else {
            fatalError("Type error: \(term) is not of type \(type).")
        }
        return type
    // default:
    //     fatalError("Type error: No rule implemented for term \(term).")
    case .string:
        return .stringType
    case .unit:
        return .unit
    case .nilTerm:
        return .list(type: .unit) // ?
    case let .head(list):
        return inferTypeBidirectional(term: list, context: context)
    case let .tail(list):
        return inferTypeBidirectional(term: list, context: context)
    default:
        fatalError("Type error: No infer rule available for \(term).")
    }
}
