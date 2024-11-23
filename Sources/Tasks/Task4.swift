//
// Task4.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

func task4() {
    // MARK: Task 4.7

    print("Task 4.7")
    let example1substitution: TypeSubstitution = ["beta": .integer]
    let example1type: Type = .function(argumentType: .variable(name: "beta"), resultType: .boolean)
    print(example1substitution, example1type)
    print(substituteTypes(type: example1type, substitutions: example1substitution))
    print("-----")

    let example2substitution: TypeSubstitution = ["alpha": .function(argumentType: .boolean, resultType: .boolean), "beta": .variable(name: "alpha")]
    let example2type: Type = .variable(name: "beta")
    print(example2substitution, example2type)
    print(substituteTypes(type: example2type, substitutions: example2substitution))
    print("-----")

    let example3substitution: TypeSubstitution = ["beta": .variable(name: "gamma"), "alpha": .function(argumentType: .variable(name: "beta"), resultType: .variable(name: "beta"))]
    let example3type: Type = .function(argumentType: .variable(name: "alpha"), resultType: .variable(name: "alpha"))
    print(example3substitution, example3type)
    print(substituteTypes(type: example3type, substitutions: example3substitution))
    print("---------------")

    // MARK: Task 4.9

    print("Task 4.9")
    print(unifyTypes(.function(argumentType: .variable(name: "alpha"), resultType: .function(argumentType: .integer, resultType: .variable(name: "beta"))),
                     .function(argumentType: .boolean, resultType: .variable(name: "gamma"))))

    print(unifyTypes(.function(argumentType: .integer, resultType: .function(argumentType: .variable(name: "alpha"), resultType: .integer)),
                     .function(argumentType: .variable(name: "beta"), resultType: .variable(name: "gamma"))))

    print(unifyTypes(.function(argumentType: .variable(name: "alpha"), resultType: .function(argumentType: .integer, resultType: .variable(name: "beta"))),
                     .function(argumentType: .boolean, resultType: .variable(name: "alpha"))))
}
