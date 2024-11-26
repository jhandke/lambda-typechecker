//
// TypeSubstitution.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

import Collections

typealias TypeSubstitution = OrderedDictionary<String, Type> // [TypeSubstitutionItem]

extension TypeSubstitution {
    mutating func append(_ other: TypeSubstitution) {
        self.merge(other) { _, new in new }
    }

    func appending(_ other: TypeSubstitution) -> Self {
        var copy = self
        copy.append(other)
        return copy
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

func unifyTypes(_ left: Type, _ right: Type) throws(TypeError) -> TypeSubstitution {
    switch (left, right) {
    case (_, _) where left == right:
        return [:]
    case let (.variable(leftName), _) where !occurs(leftName, in: right):
        return [leftName: right]
    case let (_, .variable(rightName)) where !occurs(rightName, in: left):
        return [rightName: left]
    case let (.function(leftArgumentType, leftResultType), .function(rightArgumentType, rightResultType)):
        let unifiedArgumentTypes = try unifyTypes(leftArgumentType, rightArgumentType)
        let unifiedResultTypes = try unifyTypes(
            substituteTypes(type: leftResultType, substitutions: unifiedArgumentTypes),
            substituteTypes(type: rightResultType, substitutions: unifiedArgumentTypes)
        )
        return unifiedArgumentTypes.appending(unifiedResultTypes)
    case let (.list(leftType), .list(rightType)):
        return try unifyTypes(leftType, rightType)
    default:
        throw .unificationFailed(left, right)
    }

    func occurs(_ variableName: String, in typeScheme: Type) -> Bool {
        return switch typeScheme {
        case .boolean, .integer, .unit, .stringType: false
        case let .function(argumentType, resultType):
            occurs(variableName, in: argumentType) || occurs(variableName, in: resultType)
        case let .variable(name): variableName == name
        case let .list(elementType):
            occurs(variableName, in: elementType)
        }
    }
}
