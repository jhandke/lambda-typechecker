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
        substitution.append(unifyTypes(bodyType, .integer))
        return substituteTypes(type: .boolean, substitutions: substitution)
    // (C-Add)
    case let .addition(lhs, rhs):
        let lhsType = inferTypesUnification(term: lhs, context: context)
        substitution.append(unifyTypes(lhsType, .integer))
        let rhsType = inferTypesUnification(term: rhs, context: context)
        substitution.append(unifyTypes(rhsType, .integer))
        return substituteTypes(type: .integer, substitutions: substitution)
    // (C-Ascription)
    case let .ascription(term, type):
        let termType = inferTypesUnification(term: term, context: context)
        substitution.append(unifyTypes(type, termType))
        return substituteTypes(type: type, substitutions: substitution)
    // (C-If)
    case let .conditional(test, thenBranch, elseBranch):
        let testType = inferTypesUnification(term: test, context: context)
        substitution.append(unifyTypes(testType, .boolean))
        let thenType = inferTypesUnification(term: thenBranch, context: context)
        let elseType = inferTypesUnification(term: elseBranch, context: context)
        substitution.append(unifyTypes(thenType, elseType))
        return substituteTypes(type: thenType, substitutions: substitution)
    // return thenType
    // (C-Fun)
    case let .abstraction(name, body):
        let variableType: Type = .variable(name: newTypeVariable())
        let extendedContext = context.adding(name: name, type: variableType)
        let bodyType = inferTypesUnification(term: body, context: extendedContext)
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
        substitution.append(unifyTypes(functionType, .function(argumentType: argumentType, resultType: variable)))
        return substituteTypes(type: variable, substitutions: substitution)
    case .string:
        return .stringType
    case .nilTerm:
        return .list(type: .unit) // ?
    case let .cons(head, tail):
        let headType = inferTypesUnification(term: head, context: context)
        let tailType = inferTypesUnification(term: tail, context: context)
        substitution.append(unifyTypes(.list(type: headType), tailType))
        return substituteTypes(type: tailType, substitutions: substitution)
    case let .isEmpty(list):
        let listType = inferTypesUnification(term: list, context: context)
        substitution.append(unifyTypes(listType, .list(type: .unit)))
        return substituteTypes(type: .boolean, substitutions: substitution)
    case let .head(list):
        let listType = inferTypesUnification(term: list, context: context)
        substitution.append(unifyTypes(listType, .list(type: .unit)))
        fatalError("TBI")
    case .tail(list: let list):
        fatalError("TBI")
    case .wildcard(body: let body):
        fatalError("TBI")
    case .letBinding(name: let name, value: let value, body: let body):
        let valueType = inferTypesUnification(term: value, context: context)
        let extendedContext = context.adding(name: name, type: valueType)
        let bodyType = inferTypesUnification(term: body, context: extendedContext)

    }
}
