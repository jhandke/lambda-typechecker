//
// TypeSubstitution.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

import Collections

// struct TypeSubstitutionItem {
//     let name: String
//     let type: Type
// }

typealias TypeSubstitution = OrderedDictionary<String, Type> // [TypeSubstitutionItem]

extension TypeSubstitution {
    mutating func merge(_ other: TypeSubstitution) {
        self.merge(other) { _, new in new }
    }
}


func substituteTypes(type: Type, substitutions: TypeSubstitution) -> Type {
    return substitutions.reversed().reduce(type) { resultType, substitutionItem in
        substituteType(
            type: resultType, name: substitutionItem.key, substitutionType: substitutionItem.value
        )
    }

    func substituteType(type: Type, name: String, substitutionType: Type) -> Type {
        switch type {
        case .boolean, .integer, .unit, .stringType: return type
        case let .function(argumentType, resultType):
            let substitutedArgumentType = substituteType(
                type: argumentType, name: name, substitutionType: substitutionType
            )
            let substitutedResultType = substituteType(
                type: resultType, name: name, substitutionType: substitutionType
            )
            return .function(
                argumentType: substitutedArgumentType, resultType: substitutedResultType
            )
        case let .variable(variableName):
            if variableName == name {
                return substitutionType
            }
            return type
        case let .list(elementType):
            let substitutedType = substituteType(type: elementType, name: name, substitutionType: substitutionType)
            return .list(type: substitutedType)
        }
    }
}

func unifyTypes(left: Type, right: Type) -> TypeSubstitution {
    switch (left, right) {
    case (_, _) where left == right:
        return [:]
    case let (.variable(leftName), _) where !isFree(leftName, in: right):
        return [leftName: right]
    case let (_, .variable(rightName)) where !isFree(rightName, in: left):
        return [rightName: left]
    case let (.function(leftArgumentType, leftResultType), .function(rightArgumentType, rightResultType)):
        let unifiedArgumentTypes = unifyTypes(left: leftArgumentType, right: rightArgumentType)
        let unifiedResultTypes = unifyTypes(
            left: substituteTypes(type: leftResultType, substitutions: unifiedArgumentTypes),
            right: substituteTypes(type: rightResultType, substitutions: unifiedArgumentTypes)
        )
        return unifiedArgumentTypes.merging(unifiedResultTypes) { _, new in new }
    default:
        fatalError("Type error: Can not unify types \(left) and \(right).")
    }

    func isFree(_ variableName: String, in typeScheme: Type) -> Bool {
        return switch typeScheme {
        case .boolean, .integer, .unit, .stringType: false
        case let .function(argumentType, resultType):
            isFree(variableName, in: argumentType) || isFree(variableName, in: resultType)
        case let .variable(name): variableName == name
        case let .list(elementType):
            isFree(variableName, in: elementType)
        }
    }
}
