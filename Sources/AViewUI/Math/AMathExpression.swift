import Foundation

enum AMathExpression: Codable, Sendable, Hashable, CustomStringConvertible {
    case number(Double) // A number (e.g., 1, 2.5, etc.)
    indirect case addition(AMathExpression, AMathExpression) // Addition operation (e.g., a + b)
    indirect case subtraction(AMathExpression, AMathExpression) // Subtraction operation (e.g., a - b)
    indirect case multiplication(AMathExpression, AMathExpression) // Multiplication operation (e.g., a * b)
    indirect case division(AMathExpression, AMathExpression) // Division operation (e.g., a / b)
    indirect case modulus(AMathExpression, AMathExpression) // Modulus operation (e.g., a % b)
    indirect case power(AMathExpression, AMathExpression) // Power operation (e.g., a ^ b)
    indirect case function(String, [AMathExpression]) // Function with a name and arguments (e.g., sin(x), log(x))
    indirect case parenthesis(AMathExpression) // Parentheses for grouping (e.g., (a + b))

    init?(_ string: String) {
        let parser = Parser()
        guard let result = parser.parse(string) ?? parser.parse(string + ")") else {
            return nil
        }
        self = result
    }

    func evaluate(_ functions: [String: @Sendable ([Double?]) -> Double?] = AMathExpression.mathFunctions) -> Double? {
        switch self {
        case .number(let value):
            return value
        case .addition(let left, let right):
            if let leftValue = left.evaluate(functions), let rightValue = right.evaluate(functions) {
                return leftValue + rightValue
            }
        case .subtraction(let left, let right):
            if let leftValue = left.evaluate(functions), let rightValue = right.evaluate(functions) {
                return leftValue - rightValue
            }
        case .multiplication(let left, let right):
            if let leftValue = left.evaluate(functions), let rightValue = right.evaluate(functions) {
                return leftValue * rightValue
            }
        case .division(let left, let right):
            if let leftValue = left.evaluate(functions), let rightValue = right.evaluate(functions), rightValue != 0 {
                return leftValue / rightValue
            }
        case .modulus(let left, let right):
            if let leftValue = left.evaluate(functions), let rightValue = right.evaluate(functions), rightValue != 0 {
                return leftValue.truncatingRemainder(dividingBy: rightValue)
            }
        case .power(let base, let exponent):
            if let baseValue = base.evaluate(functions), let exponentValue = exponent.evaluate(functions) {
                return pow(baseValue, exponentValue)
            }
        case .function(let name, let arguments):
            let evaluatedArguments = arguments.map { $0.evaluate(functions) }
            if let function = functions[name] {
                return function(evaluatedArguments)
            }
        case .parenthesis(let expression):
            return expression.evaluate(functions)
        }
        return nil
    }

    var priority: Int {
        switch self {
        case .addition, .subtraction:
            return 1 // Addition and subtraction have the same priority.
        case .multiplication, .division, .modulus:
            return 2 // Multiplication, division, and modulus have higher priority than addition and subtraction.
        case .power:
            return 3 // Power operation has higher priority than multiplication/division.
        case .function:
            return 4 // Functions have the highest priority (depending on implementation, this might vary).
        case .parenthesis:
            return 5 // Parentheses are used to alter normal precedence and should be treated as the highest priority.
        case .number:
            return 6 // Numbers have the highest priority as they are just values.
        }
    }

    var description: String {
        switch self {
        case .number(let value):
            return "\(value)"
        case .addition(let left, let right):
            return "\(left.wrapIfNeeded(priority: 1)) + \(right.wrapIfNeeded(priority: 1))"
        case .subtraction(let left, let right):
            return "\(left.wrapIfNeeded(priority: 1)) - \(right.wrapIfNeeded(priority: 1))"
        case .multiplication(let left, let right):
            return "\(left.wrapIfNeeded(priority: 2)) * \(right.wrapIfNeeded(priority: 2))"
        case .division(let left, let right):
            return "\(left.wrapIfNeeded(priority: 2)) / \(right.wrapIfNeeded(priority: 2))"
        case .modulus(let left, let right):
            return "\(left.wrapIfNeeded(priority: 2)) % \(right.wrapIfNeeded(priority: 2))"
        case .power(let base, let exponent):
            return "\(base.wrapIfNeeded(priority: 3)) ^ \(exponent.wrapIfNeeded(priority: 3))"
        case .function(let name, let arguments):
            let args = arguments.map { $0.description }.joined(separator: ", ")
            return "\(name)(\(args))"
        case .parenthesis(let expression):
            return "(\(expression.description))"
        }
    }

    private func wrapIfNeeded(priority currentPriority: Int) -> String {
        if priority < currentPriority {
            return "(\(description))"
        } else {
            return description
        }
    }
}

extension AMathExpression {
    struct Parser {
        func parse(_ input: String) -> AMathExpression? {
            var tokens = tokenize(input)
            return parseExpression(&tokens)
        }

        private func tokenize(_ input: String) -> [String] {
            var tokens: [String] = []
            var currentToken = ""
            var previousChar: Character?
            var parenthesisLevel = 0

            for char in input {
                if char.isWhitespace {
                    continue
                }
                if char == "(" || char == "（" {
                    parenthesisLevel += 1
                } else if char == ")" || char == "）" {
                    parenthesisLevel -= 1
                }
                
                if char.isNumber || char == "." || (char == "-" && (previousChar == nil || previousChar == "(" || previousChar == "（" || "+-×*/%^÷".contains(previousChar!))) {
                    currentToken.append(char)
                } else if char == "," && parenthesisLevel == 0 && !currentToken.isEmpty && currentToken.last?.isNumber == true {
                    continue // Ignore commas within numbers outside parentheses
                } else if char.isLetter || char == "e" {
                    currentToken.append(char) // Accumulate letters for function names or scientific notation
                } else {
                    if !currentToken.isEmpty {
                        tokens.append(currentToken)
                        currentToken = ""
                    }
                    // Check for Chinese parentheses and treat them as their English counterparts
                    if char == "（" {
                        tokens.append("(")
                    } else if char == "）" {
                        tokens.append(")")
                    } else if char == "÷" {
                        tokens.append("/") // Treat `÷` as `/`
                    } else {
                        tokens.append(String(char))
                    }
                }
                previousChar = char
            }
            if !currentToken.isEmpty {
                tokens.append(currentToken)
            }

            return tokens
        }

        private func parseExpression(_ tokens: inout [String]) -> AMathExpression? {
            var leftExpression = parseTerm(&tokens)

            while let token = tokens.first, token == "+" || token == "-" {
                tokens.removeFirst()
                let rightExpression = parseTerm(&tokens)
                if let left = leftExpression, let right = rightExpression {
                    if token == "+" {
                        leftExpression = .addition(left, right)
                    } else {
                        leftExpression = .subtraction(left, right)
                    }
                } else {
                    return nil
                }
            }

            return leftExpression
        }

        private func parseTerm(_ tokens: inout [String]) -> AMathExpression? {
            var leftExpression = parseFactor(&tokens)

            while let token = tokens.first, token == "*" || token == "/" || token == "%" || token == "×" || token == "÷" {
                tokens.removeFirst()
                let rightExpression = parseFactor(&tokens)
                if let left = leftExpression, let right = rightExpression {
                    switch token {
                    case "*", "×": // 支持 "*" 和 "×" 符号作为乘法运算符
                        leftExpression = .multiplication(left, right)
                    case "/", "÷": // 支持 "/" 和 "÷" 符号作为除法运算符
                        leftExpression = .division(left, right)
                    case "%":
                        leftExpression = .modulus(left, right)
                    default:
                        return nil
                    }
                } else {
                    return nil
                }
            }

            return leftExpression
        }

        private func parseFactor(_ tokens: inout [String]) -> AMathExpression? {
            var leftExpression = parsePrimary(&tokens)

            while let token = tokens.first, token == "^" {
                tokens.removeFirst()
                let rightExpression = parsePrimary(&tokens)
                if let left = leftExpression, let right = rightExpression {
                    leftExpression = .power(left, right)
                } else {
                    return nil
                }
            }

            return leftExpression
        }

        private func parsePrimary(_ tokens: inout [String]) -> AMathExpression? {
            guard let token = tokens.first else {
                return nil
            }

            // Check if the token is a function name
            if token.allSatisfy({ $0.isLetter }) && tokens.count > 1 {
                tokens.removeFirst() // Remove the function name token
                return parseFunction(token, &tokens)
            }

            tokens.removeFirst()

            // Remove commas and try to parse the number
            let sanitizedToken = token.replacingOccurrences(of: ",", with: "")
            if let number = Double(sanitizedToken) {
                return .number(number)
            } else if token == "(" || token == "（" { // 支持中文和英文的左括号
                let expression = parseExpression(&tokens)
                if tokens.first == ")" || tokens.first == "）" { // 支持中文和英文的右括号
                    tokens.removeFirst()
                }
                return expression.map { .parenthesis($0) }
            }

            return nil
        }

        private func parseFunction(_ name: String, _ tokens: inout [String]) -> AMathExpression? {
            // Ensure there's an opening parenthesis
            guard let nextToken = tokens.first, nextToken == "(" || nextToken == "（" else {
                return nil
            }
            tokens.removeFirst() // Remove the opening parenthesis

            var arguments: [AMathExpression] = []
            while let argument = parseExpression(&tokens) {
                arguments.append(argument)
                // Check for a comma for additional arguments
                if let comma = tokens.first, comma == "," {
                    tokens.removeFirst() // Remove the comma
                } else {
                    break // No more arguments
                }
            }

            // Ensure there's a closing parenthesis
            if tokens.first == ")" || tokens.first == "）" {
                tokens.removeFirst()
            } else {
                return nil // Mismatched parenthesis
            }

            return .function(name, arguments)
        }
    }
}
