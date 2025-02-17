import AMathExpression
import SwiftUI

#if os(iOS)
@available(iOS 16, *)
public struct AMathExpressionKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View {

    private var uiTextField: UITextField
    private var formatStyle: AMathFormatStyle<ANumber>
    private let setString: (String) -> Void


    private var isIPad: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        case .unspecified, .phone, .tv, .carPlay, .mac, .vision:
            return false
        @unknown default:
            return false
        }

    }

    public var body: some View {
        if isIPad {
            AMathExpressionKeyboardIPad(uiTextField, format: formatStyle.displayedFormat, setString: setString)
        } else {
            AMathExpressionKeyboardIPhone(uiTextField, format: formatStyle.displayedFormat, setString: setString)
        }
    }
    
    public init(_ textfield: UITextField, format: FloatingPointFormatStyle<ANumber>, setString: @escaping (String) -> Void) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = setString
    }

    public init(_ textfield: UITextField, format: FloatingPointFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { textfield.text = $0 }
    }

    public init(_ textfield: UITextField, _ bindString: Binding<String>, format: FloatingPointFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { bindString.wrappedValue = $0 }
    }

    public init(_ textfield: UITextField, _ format: AMathFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = format
        self.setString = { textfield.text = $0 }
    }
}

@available(iOS 16, *)#Preview{
    AMathExpressionKeyboard<Double>(.init(), .fractionLength(5))
        .frame(height: 240)
}

#endif
