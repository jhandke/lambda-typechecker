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

func inferTypeUnification(term: Term, context: Context) throws(TypeError) -> Type {
    var usedTypeVariables = [String]()
    let typeVariables = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "μ",
                         "ν", "ξ", "ο", "π", "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"]

    return try inferType(term: term, context: context).0

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

    func substituteContext(_ context: Context, substitution: TypeSubstitution) -> Context {
        context.mapValues { type in
            substituteTypes(type: type, substitutions: substitution)
        }
    }

    func inferType(term: Term, context: Context) throws(TypeError) -> (Type, TypeSubstitution) {
        var substitution = TypeSubstitution()
        switch term {
        // (C-True), (C-False)
        case .trueConstant, .falseConstant: return (.boolean, substitution)
        // (C-Int)
        case .integerConstant: return (.integer, substitution)
        // (C-Unit)
        case .unit: return (.unit, substitution)
        // (C-IsZero)
        case let .isZero(body):
            let (bodyType, bodySubstitution) = try inferType(term: body, context: context)
            substitution.append(try unifyTypes(bodyType, .integer))
            substitution.append(bodySubstitution)
            return (.boolean, substitution)
        // (C-Add)
        case let .addition(lhs, rhs):
            let (lhsType, lhsSubstitution) = try inferType(term: lhs, context: context)
            let (rhsType, rhsSubstitution) = try inferType(term: rhs, context: substituteContext(context, substitution: lhsSubstitution))
            substitution.append(lhsSubstitution)
            substitution.append(rhsSubstitution)
            substitution.append(try unifyTypes(substituteTypes(type: lhsType, substitutions: rhsSubstitution), .integer))
            substitution.append(try unifyTypes(substituteTypes(type: rhsType, substitutions: substitution), .integer))
            return (.integer, substitution)
        // (C-Ascription)
        case let .ascription(term, type):
            let (termType, termSubstitution) = try inferType(term: term, context: context)
            substitution.append(termSubstitution)
            substitution.append(try unifyTypes(type, termType))
            return (type, substitution)
        // (C-If)
        case let .conditional(test, thenBranch, elseBranch):
            let (testType, testSubstitution) = try inferType(term: test, context: context)
            let (thenType, thenSubstitution) = try inferType(term: thenBranch, context: substituteContext(context, substitution: testSubstitution))
            substitution.append(testSubstitution)
            substitution.append(thenSubstitution)
            let (elseType, elseSubstitution) = try inferType(term: elseBranch, context: substituteContext(context, substitution: substitution))
            substitution.append(elseSubstitution)
            substitution.append(try unifyTypes(substituteTypes(type: testType, substitutions: substitution), .boolean))
            substitution.append(try unifyTypes(substituteTypes(type: thenType, substitutions: substitution),
                                           substituteTypes(type: elseType, substitutions: substitution)))
            return (substituteTypes(type: thenType, substitutions: substitution), substitution)
        // (C-Fun)
        case let .abstraction(name, body):
            let variableType: Type = .variable(name: newTypeVariable())
            let extendedContext = context.adding(name: name, type: variableType)
            let (bodyType, bodySubstitution) = try inferType(term: body, context: extendedContext)
            return (.function(argumentType: substituteTypes(type: variableType, substitutions: bodySubstitution),
                              resultType: bodyType),
                    bodySubstitution)
        // (C-Var)
        case let .variable(name):
            guard let type = context[name] else {
                throw .variableNotInContext(name: name)
            }
            return (type, substitution)
        // (C-Apply)
        case let .application(function, argument):
            let (functionType, functionSubstitution) = try inferType(term: function, context: context)
            substitution.append(functionSubstitution)
            let (argumentType, argumentSubstitution) = try inferType(term: argument, context: substituteContext(context, substitution: substitution))
            substitution.append(argumentSubstitution)
            let variableType: Type = .variable(name: newTypeVariable())
            substitution.append(
                try unifyTypes(substituteTypes(type: functionType, substitutions: argumentSubstitution),
                           .function(argumentType: argumentType, resultType: variableType))
            )
            return (substituteTypes(type: variableType, substitutions: substitution), substitution)
        case .string:
            return (.stringType, substitution)
        case .nilTerm:
            let variableType: Type = .variable(name: newTypeVariable())
            return (.list(type: variableType), substitution)
        case let .cons(head, tail):
            let (headType, headSubstitution) = try inferType(term: head, context: context)
            let (tailType, tailSubstitution) = try inferType(term: tail, context: substituteContext(context, substitution: headSubstitution))
            substitution.append(headSubstitution)
            substitution.append(tailSubstitution)
            substitution.append(try unifyTypes(.list(type: headType), tailType))
            return (substituteTypes(type: tailType, substitutions: substitution), substitution)
        case let .isEmpty(list):
            let (listType, _) = try inferType(term: list, context: context)
            substitution.append(try unifyTypes(listType, .variable(name: newTypeVariable())))
            return (.boolean, substitution)
        case let .head(list):
            let (listType, _) = try inferType(term: list, context: context)
            let variableType: Type = .variable(name: newTypeVariable())
            substitution = try unifyTypes(listType, .list(type: variableType))
            return (substituteTypes(type: variableType, substitutions: substitution), substitution)
        case let .tail(list):
            let (listType, _) = try inferType(term: list, context: context)
            substitution = try unifyTypes(listType, .list(type: .variable(name: newTypeVariable())))
            return (substituteTypes(type: listType, substitutions: substitution), substitution)
        case let .wildcard(body):
            let variableType: Type = .variable(name: newTypeVariable())
            let (bodyType, bodySubstitution) = try inferType(term: body, context: context)
            return (.function(argumentType: substituteTypes(type: variableType, substitutions: bodySubstitution), resultType: bodyType), substitution)
        case let .letBinding(name, value, body):
            let (valueType, valueSubstitution) = try inferType(term: value, context: context)
            substitution.append(valueSubstitution)
            let extendedContext = context.adding(name: name, type: valueType)
            let (bodyType, bodySubstitution) = try inferType(term: body, context: extendedContext)
            substitution.append(bodySubstitution)
            return (bodyType, substitution)
        }
    }
}
