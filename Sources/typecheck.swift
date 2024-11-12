//
// typecheck.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

enum TypecheckError: Error {
    case checkFailed(term: Term, type: Type, context: Context)
    case inferFailed(term: Term, context: Context)
    case noCheckRule(term: Term, type: Type, context: Context)
    case noInferRule(term: Term, context: Context)
}

func checkType(term: Term, type: Type, context: Context) -> Bool {
    switch term {
    // (Fun<==)
    case let .abstraction(name, body):
        if case let .function(argumentType, resultType) = type {
            let updatedContext = context.merging([name: argumentType]) { _, new in new }
            return checkType(term: body, type: resultType, context: updatedContext)
        }
        return false
    // (Check<==)
    default:
        do {
            let inferredType = try inferType(term: term, context: context)
            if type == inferredType {
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
}

func inferType(term: Term, context: Context) throws(TypecheckError) -> Type {
    switch term {
    // (True==>), (False==>)
    case .trueConstant, .falseConstant: return .boolean
    // (Int==>)
    case .integerConstant: return .integer
    // (If==>)
    case let .conditional(test, thenBranch, elseBranch):
        if checkType(term: test, type: .boolean, context: context) {
            let type2 = try inferType(term: thenBranch, context: context)
            let type3 = try inferType(term: elseBranch, context: context)
            if type2 == type3 {
                return type2
            }
        }
        throw TypecheckError.inferFailed(term: term, context: context)
    // (IsZero==>)
    case let .isZero(term):
        if checkType(term: term, type: .integer, context: context) {
            return .boolean
        }
        throw TypecheckError.checkFailed(term: term, type: .integer, context: context)
    // (Var==>)
    case let .variable(name):
        if let type = context[name] {
            return type
        }
        throw TypecheckError.inferFailed(term: term, context: context)
    // (Apply==>)
    case let .application(function, argument):
        let functionType = try inferType(term: function, context: context)
        if case let .function(argumentType, resultType) = functionType,
           checkType(term: argument, type: argumentType, context: context) {
            return resultType
        }
        throw TypecheckError.inferFailed(term: term, context: context)
    // (Ascription==>)
    case let .ascription(term, type):
        if checkType(term: term, type: type, context: context) {
            return type
        }
        throw TypecheckError.checkFailed(term: term, type: type, context: context)
    default:
        throw TypecheckError.noInferRule(term: term, context: context)
    }
}
