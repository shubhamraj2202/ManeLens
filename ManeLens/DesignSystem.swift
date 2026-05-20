import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let hairPurple      = Color(red: 0.486, green: 0.227, blue: 0.929)   // #7C3AED — fixed brand
    static let hairPink        = Color(red: 0.925, green: 0.286, blue: 0.600)   // #EC4899 — fixed brand
    static let hairText        = Color(UIColor.label)                            // adaptive
    static let hairTextSec     = Color(UIColor.secondaryLabel)                   // adaptive
    static let hairBg          = Color(UIColor.systemBackground)                 // adaptive
    static let hairBgOff       = Color(UIColor.secondarySystemBackground)        // adaptive
    // Adaptive: light purple tint in light mode, dark purple tint in dark mode
    static let hairPurpleLight = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.13, blue: 0.29, alpha: 1.0)   // dark purple
            : UIColor(red: 0.961, green: 0.953, blue: 1.000, alpha: 1.0) // #F5F3FF
    })
    // Adaptive: purple-on-white tint vs purple-on-dark tint
    static let hairPurpleAlpha = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.486, green: 0.227, blue: 0.929, alpha: 0.22)
            : UIColor(red: 0.486, green: 0.227, blue: 0.929, alpha: 0.10)
    })
    static let hairBorder      = Color(UIColor.separator)                        // adaptive
}

// MARK: - Gradient
extension LinearGradient {
    static let hairBrand = LinearGradient(
        colors: [.hairPurple, .hairPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Layout constants
enum DS {
    static let radiusCard: CGFloat   = 16
    static let radiusButton: CGFloat = 14
    static let radiusInput: CGFloat  = 12
    static let buttonHeight: CGFloat = 56
    static let paddingPage: CGFloat  = 16
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var variant: ButtonVariant = .primary
    var disabled: Bool = false
    var action: () -> Void

    enum ButtonVariant { case primary, gradient, secondary, tertiary, destructive, white }

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Text(icon).font(.system(size: 17)) }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.buttonHeight)
            .foregroundStyle(fgColor)
            .background(bgView)
            .cornerRadius(DS.radiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: DS.radiusButton)
                    .stroke(borderColor, lineWidth: variant == .secondary ? 1.5 : 0)
            )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    @ViewBuilder private var bgView: some View {
        switch variant {
        case .gradient:   LinearGradient.hairBrand
        case .primary:    Color.hairPurple
        case .secondary:  Color.hairPurpleAlpha
        case .white:      Color.white
        default:          Color.clear
        }
    }

    private var fgColor: Color {
        switch variant {
        case .primary, .gradient:  .white
        case .secondary:           .hairPurple
        case .tertiary:            .hairPurple
        case .destructive:         Color(red: 0.937, green: 0.267, blue: 0.267)
        case .white:               Color(red: 0.1, green: 0.05, blue: 0.2)
        }
    }

    private var borderColor: Color {
        variant == .secondary ? Color.hairPurple.opacity(0.25) : .clear
    }
}

// MARK: - Credit Pill
struct CreditPill: View {
    let credits: Int
    var body: some View {
        HStack(spacing: 4) {
            Text("💎").font(.system(size: 12))
            Text("\(credits)").font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(Color.hairPurple)
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(Color.hairPurpleAlpha)
        .overlay(Capsule().stroke(Color.hairPurple.opacity(0.3), lineWidth: 1))
        .clipShape(Capsule())
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? .white : Color.hairTextSec)
                .padding(.horizontal, 16)
                .frame(height: 34)
                .background(selected ? Color.hairPurple : Color.black.opacity(0.06))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Screen Nav Bar
struct ScreenNav: View {
    let title: String
    var onBack: (() -> Void)? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack {
            // Leading
            ZStack(alignment: .leading) {
                if let onBack {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundStyle(Color.hairPurple)
                    }
                }
            }
            .frame(width: 70, alignment: .leading)

            Spacer()

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.hairText)
                .lineLimit(1)

            Spacer()

            // Trailing
            ZStack(alignment: .trailing) {
                if let trailing { trailing }
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, DS.paddingPage)
        .frame(height: 52)
    }
}

// MARK: - Card Shadow Modifier
struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.hairBg)
            .cornerRadius(DS.radiusCard)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardShadow() -> some View { modifier(CardShadow()) }
}
