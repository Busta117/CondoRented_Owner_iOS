import Foundation

/// Formats large currency values in compact form: 1.2M, 350K, etc.
/// Designed for COP and other currencies with large nominal values.
func compactCurrency(_ value: Double, currencyId: String = "") -> String {
    let abs = abs(value)
    let sign = value < 0 ? "-" : ""
    let prefix = currencyId.isEmpty ? "$" : "$"

    switch abs {
    case 1_000_000_000...:
        return "\(sign)\(prefix)\(String(format: "%.1f", abs / 1_000_000_000))B"
    case 1_000_000...:
        return "\(sign)\(prefix)\(String(format: "%.1f", abs / 1_000_000))M"
    case 1_000...:
        return "\(sign)\(prefix)\(String(format: "%.0f", abs / 1_000))K"
    default:
        return "\(sign)\(prefix)\(String(format: "%.0f", abs))"
    }
}
