import Foundation

extension AMathExpression {
    // 常量用于度数和弧度之间的转换
    static let degreesToRadians = 0.01745329251994329576924 // π / 180
    static let radiansToDegrees = 57.29577951308232087680 // 180 / π

    // 定义字典类型的变量
    static let mathFunctions: [String: @Sendable ([Double?]) -> Double?] = [
        "sqrt": { values in
            guard let value = values.first, let number = value else { return nil }
            return sqrt(number)
        },
        "cbrt": { values in
            guard let value = values.first, let number = value else { return nil }
            return cbrt(number)
        },
        "log": { values in
            guard let value = values.first, let number = value else { return nil }
            return log(number)
        },
        "log10": { values in
            guard let value = values.first, let number = value else { return nil }
            return log10(number)
        },
        "sin": { values in
            guard let value = values.first, let number = value else { return nil }
            return sin(number * degreesToRadians) // 使用度数
        },
        "cos": { values in
            guard let value = values.first, let number = value else { return nil }
            return cos(number * degreesToRadians) // 使用度数
        },
        "tan": { values in
            guard let value = values.first, let number = value else { return nil }
            return tan(number * degreesToRadians) // 使用度数
        },
        "asin": { values in
            guard let value = values.first, let number = value else { return nil }
            return asin(number) * radiansToDegrees // 结果转换为度数
        },
        "acos": { values in
            guard let value = values.first, let number = value else { return nil }
            return acos(number) * radiansToDegrees // 结果转换为度数
        },
        "atan": { values in
            guard let value = values.first, let number = value else { return nil }
            return atan(number) * radiansToDegrees // 结果转换为度数
        },
        "sinh": { values in
            guard let value = values.first, let number = value else { return nil }
            return sinh(number * degreesToRadians) // 使用度数
        },
        "cosh": { values in
            guard let value = values.first, let number = value else { return nil }
            return cosh(number * degreesToRadians) // 使用度数
        },
        "tanh": { values in
            guard let value = values.first, let number = value else { return nil }
            return tanh(number * degreesToRadians) // 使用度数
        },
        "exp": { values in
            guard let value = values.first, let number = value else { return nil }
            return exp(number)
        },
        "pow": { values in
            guard values.count == 2, let base = values[0], let exponent = values[1] else { return nil }
            return pow(base, exponent)
        },
        "max": { values in
            let numbers = values.compactMap { $0 }
            return numbers.max()
        },
        "min": { values in
            let numbers = values.compactMap { $0 }
            return numbers.min()
        },
        "average": { values in
            let numbers = values.compactMap { $0 }
            guard !numbers.isEmpty else { return nil }
            return numbers.reduce(0, +) / Double(numbers.count)
        },
        "abs": { values in
            guard let value = values.first, let number = value else { return nil }
            return abs(number)
        },
        "ceil": { values in
            guard let value = values.first, let number = value else { return nil }
            return ceil(number)
        },
        "floor": { values in
            guard let value = values.first, let number = value else { return nil }
            return floor(number)
        },
        "round": { values in
            guard let value = values.first, let number = value else { return nil }
            return round(number)
        },
        "atan2": { values in
            guard values.count == 2, let y = values[0], let x = values[1] else { return nil }
            return atan2(y, x) * radiansToDegrees // 结果转换为度数
        },
        "hypot": { values in
            guard values.count == 2, let x = values[0], let y = values[1] else { return nil }
            return hypot(x, y)
        }
    ]
}
