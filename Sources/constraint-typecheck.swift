//
// constraint-typecheck.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

enum TypeScheme {
    case variable(String)
    case type(Type)
}

// typealias Constraint = (Type, Type)

private var usedTypeVariables = [String]()
private var typeVariables = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "μ",
                             "ν", "ξ", "ο", "π", "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"]

func newTypeVariable() -> String {
    if let variable = typeVariables.first(where: { variable in
        !usedTypeVariables.contains(variable)
    }) {
        usedTypeVariables.append(variable)
        return variable
    } else {
        var number = 1
        var resultingVariable = typeVariables.first(where: { variable in
            !usedTypeVariables.contains("\(variable)\(number)")
        })
        while resultingVariable == nil {
            number += 1
            resultingVariable = typeVariables.first(where: { variable in
                !usedTypeVariables.contains("\(variable)\(number)")
            })
        }
        resultingVariable! += "\(number)"
        usedTypeVariables.append(resultingVariable!)
        return resultingVariable!
    }
}

func inferTypesUnification(term: Term, context: Context) -> Type {
    var substitution = TypeSubstitution()
    switch term {
    // (C-True), (C-False)
    case .trueConstant, .falseConstant: return .boolean
    // (C-Int)
    case .integerConstant: return .integer
    // (C-Unit)
    case .unit: return .unit
    // (C-IsZero)
    case let .isZero(body):
        let bodyType = inferTypesUnification(term: body, context: context)
        substitution = unifyTypes(left: bodyType, right: .integer)
        return substituteTypes(type: .boolean, substitutions: substitution)
    // return .boolean
    // (C-Add)
    case let .addition(lhs, rhs):
        let lhsType = inferTypesUnification(term: lhs, context: context)
        substitution.merge(unifyTypes(left: lhsType, right: .integer))
        let rhsType = inferTypesUnification(term: rhs, context: context)
        substitution.merge(unifyTypes(left: rhsType, right: .integer))
        // substitution.merge(lhsSubstitution)
        // substitution.merge(rhsSubstitution)
        // return .integer
        return substituteTypes(type: .integer, substitutions: substitution)
    // (C-Ascription)
    case let .ascription(term, type):
        let termType = inferTypesUnification(term: term, context: context)
        substitution.merge(unifyTypes(left: type, right: termType))
        // return type // ??
        return substituteTypes(type: type, substitutions: substitution)
    // (C-If)
    case let .conditional(test, thenBranch, elseBranch):
        let testType = inferTypesUnification(term: test, context: context)
        substitution.merge(unifyTypes(left: testType, right: .boolean))
        let thenType = inferTypesUnification(term: thenBranch, context: context)
        let elseType = inferTypesUnification(term: elseBranch, context: context)
        substitution.merge(unifyTypes(left: thenType, right: elseType))
        return substituteTypes(type: thenType, substitutions: substitution)
    // return thenType
    // (C-Fun)
    case let .abstraction(name, body):
        var extendedContext = context
        let variableType: Type = .variable(name: newTypeVariable())
        extendedContext[name] = variableType
        let bodyType = inferTypesUnification(term: body, context: extendedContext)
        // return .function(argumentType: variableType, resultType: bodyType)
        return substituteTypes(type: .function(argumentType: variableType, resultType: bodyType), substitutions: substitution)
    // (C-Var)
    case let .variable(name):
        if let type = context[name] {
            return type
        }
        fatalError("Typecheck error: Variable \(name) not found in context \(context).")
    // (C-Apply)
    case let .application(function, argument):
        let variable: Type = .variable(name: newTypeVariable())
        let functionType = inferTypesUnification(term: function, context: context)
        let argumentType = inferTypesUnification(term: argument, context: context)
        substitution.merge(unifyTypes(left: functionType, right: .function(argumentType: argumentType, resultType: variable)))
        // return variable
        return substituteTypes(type: variable, substitutions: substitution)
    default: fatalError("Not implemented.")
    }
}
