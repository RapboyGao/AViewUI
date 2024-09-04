import Foundation
import Numerics

extension AMathExpression {
    static func createFunctions() -> [String: @Sendable ([ANumber?]) -> ANumber?] {
        // 常量用于度数和弧度之间的转换
        let degreesToRadians: ANumber = 0.01745329251994329576924 // π / 180
        let radiansToDegrees: ANumber = 57.29577951308232087680 // 180 / π

        return [
            "sqrt": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.sqrt(number)
            },
            "cbrt": { values in
                guard let firstValue = values.first, let value = firstValue
                else { return nil }
                return ANumber.pow(value, 3)
            },
            "log": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.log(number)
            },
            "log10": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.log10(number)
            },
            "sin": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.sin(number * degreesToRadians) // 使用度数
            },
            "cos": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.cos(number * degreesToRadians) // 使用度数
            },
            "tan": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.tan(number * degreesToRadians) // 使用度数
            },
            "asin": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.asin(number) * radiansToDegrees // 结果转换为度数
            },
            "acos": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.acos(number) * radiansToDegrees // 结果转换为度数
            },
            "atan": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.atan(number) * radiansToDegrees // 结果转换为度数
            },
            "sinh": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.sinh(number * degreesToRadians) // 使用度数
            },
            "cosh": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.cosh(number * degreesToRadians) // 使用度数
            },
            "tanh": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.tanh(number * degreesToRadians) // 使用度数
            },
            "exp": { values in
                guard let value = values.first, let number = value else { return nil }
                return ANumber.exp(number)
            },
            "pow": { values in
                guard values.count == 2, let base = values[0], let exponent = values[1] else { return nil }
                return ANumber.pow(base, exponent)
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
                return numbers.reduce(0, +) / ANumber(numbers.count)
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
                return ANumber.atan2(y: y, x: x) * radiansToDegrees // 结果转换为度数
            },
            "hypot": { values in
                guard values.count == 2, let x = values[0], let y = values[1] else { return nil }
                return ANumber.hypot(x, y)
            }
        ]
    }
}
