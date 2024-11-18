//
// constraint-typecheck.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

enum TypeScheme {
    case variable(String)
    case type(Type)

    @MainActor private static var usedTypeVariables = [String]()
    @MainActor private static var typeVariables = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "μ",
                                                   "ν", "ξ", "ο", "π", "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"]

    @MainActor static var newTypeVariable: String {
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
}

typealias Constraint = (TypeScheme, TypeScheme)
typealias ConstraintContext = [String: TypeScheme]

// func typecheckConstraint(term: Term, context: ConstraintContext) -> (TypeScheme, [Constraint]) {
//     switch term {
//     // (C-True), (C-False)
//     case .trueConstant, .falseConstant: return (.type(.boolean), [])
//     // (C-Int)
//     case .integerConstant: return (.type(.boolean), [])
//     // (C-IsZero)
//     case let .isZero(term):
//         var (type, constraints) = typecheckConstraint(term: term, context: context)
//         constraints.append(Constraint(type, .type(.integer)))
//         return (.type(.boolean), constraints)
//     // (C-Ascription)
//     case let .ascription(term, type):
        
//     // (C-Fun)
//     case let .abstraction(name, body):
//         let extendedContext = context.merge([], uniquingKeysWith: (TypeScheme, TypeScheme) throws -> TypeScheme)
//     }
// }