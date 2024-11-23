//
// substitute.swift
// Typechecker
//
// Copyright © 2024 Jakob Handke.
//

func substitute(inputTerm: Term, variableName: String, replacementTerm: Term, debug: Bool = false) -> Term {
    if debug {
        print("Replacing variable \(variableName) with \(replacementTerm) in\n\(inputTerm)")
    }
    let result = substitute(inputTerm: inputTerm, variableName: variableName, replacementTerm: replacementTerm)
    if debug {
        print("Result: \(result)")
    }
    return result
}

func substitute(inputTerm: Term, variableName: String, replacementTerm: Term) -> Term {
    return switch inputTerm {
    case .trueConstant, .falseConstant, .integerConstant, .string, .unit, .nilTerm:
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
                replacementTerm: replacementTerm
            ),
            rhs: substitute(
                inputTerm: rhs,
                variableName: variableName,
                replacementTerm: replacementTerm
            )
        )
    case let .ascription(term, type):
        .ascription(term: substitute(inputTerm: term, variableName: variableName, replacementTerm: replacementTerm), type: type)
    case let .application(function, argument):
        .application(
            function: substitute(inputTerm: function, variableName: variableName, replacementTerm: replacementTerm),
            argument: substitute(inputTerm: argument, variableName: variableName, replacementTerm: replacementTerm)
        )
    case let .conditional(test, thenBranch, elseBranch):
        .conditional(
            test: substitute(
                inputTerm: test,
                variableName: variableName,
                replacementTerm: replacementTerm
            ),
            thenBranch: substitute(
                inputTerm: thenBranch,
                variableName: variableName,
                replacementTerm: replacementTerm
            ),
            elseBranch: substitute(
                inputTerm: elseBranch,
                variableName: variableName,
                replacementTerm: replacementTerm
            )
        )
    case let .isZero(term):
        .isZero(term: substitute(inputTerm: term, variableName: variableName, replacementTerm: replacementTerm))
    case let .variable(name):
        if variableName == name {
            replacementTerm
        } else {
            inputTerm
        }
    case let .cons(head, tail):
        .cons(head: substitute(inputTerm: head, variableName: variableName, replacementTerm: replacementTerm),
              tail: substitute(inputTerm: tail, variableName: variableName, replacementTerm: replacementTerm))
    case let .isEmpty(list):
        .isEmpty(list: substitute(inputTerm: list, variableName: variableName, replacementTerm: replacementTerm))
    case let .head(list):
        .head(list: substitute(inputTerm: list, variableName: variableName, replacementTerm: replacementTerm))
    case let .tail(list):
        .tail(list: substitute(inputTerm: list, variableName: variableName, replacementTerm: replacementTerm))
    case let .wildcard(body):
        .wildcard(body: substitute(inputTerm: body, variableName: variableName, replacementTerm: replacementTerm))
    case let .letBinding(name, value, body):
        .letBinding(name: name,
                    value: substitute(inputTerm: value,
                                      variableName: variableName,
                                      replacementTerm: replacementTerm),
                    body: substitute(inputTerm: body,
                                     variableName: variableName,
                                     replacementTerm: replacementTerm))
    }
}
