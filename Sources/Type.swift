//
// Type.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

typealias Context = [String: Type]

enum Type {
    case boolean
    case integer
    case function
}
