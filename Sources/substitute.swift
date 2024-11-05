//
// substitute.swift
// Created by Jakob Handke on 2024-10-22.
//

func substitute(inputTerm: Term, variableName: String, replacementTerm: Term, debug: Bool = false) -> Term {
    print("Replacing variable \(variableName) with \(replacementTerm) in\n\(inputTerm)")
    let result = substitute(inputTerm: inputTerm, variableName: variableName, replacementTerm: replacementTerm)
    print("Result: \(result)")
    return result
}

func substitute(inputTerm: Term, variableName: String, replacementTerm: Term) -> Term {
    return switch inputTerm {
    case .trueConstant, .falseConstant, .integerConstant:
        inputTerm
    case let .abstraction(name, body):
        if variableName == name {
            inputTerm
        } else {
            .abstraction(
                name: name,
                body: substitute(
                    inputTerm: body,
                    variableName: variableName,
                    replacementTerm: replacementTerm
                )
            )
        }
    case let .addition(lhs, rhs):
        .addition(
            lhs: substitute(
                inputTerm: lhs,
                variableName: variableName,
                replacementTerm: replacementTerm),
            rhs: substitute(
                inputTerm: rhs,
                variableName: variableName,
                replacementTerm: replacementTerm)
        )
    case let .application(function, argument):
        .application(
            function: substitute(inputTerm: function, variableName: variableName, replacementTerm: replacementTerm),
            argument: substitute(inputTerm: argument, variableName: variableName, replacementTerm: replacementTerm))
    case let .conditional(test, thenBranch, elseBranch):
        .conditional(
            test: substitute(
                inputTerm: test,
                variableName: variableName,
                replacementTerm: replacementTerm),
            thenBranch: substitute(
                inputTerm: thenBranch,
                variableName: variableName,
                replacementTerm: replacementTerm),
            elseBranch: substitute(
                inputTerm: elseBranch,
                variableName: variableName,
                replacementTerm: replacementTerm)
        )
    case let .isZero(term):
        .isZero(term: substitute(inputTerm: term, variableName: variableName, replacementTerm: replacementTerm))
    case let .variable(name):
        if variableName == name {
            replacementTerm
        } else {
            inputTerm
        }
    }
}
