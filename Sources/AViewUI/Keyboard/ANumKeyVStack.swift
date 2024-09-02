import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ANumKeyVStack: View {
    var number: Int
    private let lettersFont: Font
    private let numbersFont: Font

    public var body: some View {
        switch number {
        case 1:
            VStack {
                Text("1").font(numbersFont)
                Text(" ").font(lettersFont)
            }
        case 2:
            VStack {
                Text("2").font(numbersFont)
                Text("A B C").font(lettersFont)
            }
        case 3:
            VStack {
                Text("3").font(numbersFont)
                Text("D E F").font(lettersFont)
            }
        case 4:
            VStack {
                Text("4").font(numbersFont)
                Text("G H I").font(lettersFont)
            }
        case 5:
            VStack {
                Text("5").font(numbersFont)
                Text("J K L").font(lettersFont)
            }
        case 6:
            VStack {
                Text("6").font(numbersFont)
                Text("M N O").font(lettersFont)
            }
        case 7:
            VStack {
                Text("7").font(numbersFont)
                Text("P Q R S").font(lettersFont)
            }
        case 8:
            VStack {
                Text("8").font(numbersFont)
                Text("T U V").font(lettersFont)
            }
        case 9:
            VStack {
                Text("9").font(numbersFont)
                Text("W X Y Z").font(lettersFont)
            }
        default:
            Text(number.formatted()).font(numbersFont)
        }
    }

    /// 初始化方法，用于设置数字和字体
    /// - Parameters:
    ///   - number: 要显示的数字
    ///   - lettersFont: 显示字母的字体，默认大小为10
    ///   - numbersFont: 显示数字的字体，默认大小为23
    public init(_ number: Int, letters lettersFont: Font = .system(size: 10), number numbersFont: Font = .system(size: 23)) {
        self.number = number
        self.lettersFont = lettersFont
        self.numbersFont = numbersFont
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    AKeyboardBackgroundView { _ in
        KeyBoardSpaceAroundStack(columns: 3, rowSpace: 4, columnSpace: 4) {
            ForEach(1 ..< 10) { number in
                AKeyButton(4) {} content: { _ in
                    ANumKeyVStack(number)
                }
            }
            AKeyButton(4) {} content: { _ in
                ANumKeyVStack(0)
            }
        }
        .frame(height: 270)
    }
}
