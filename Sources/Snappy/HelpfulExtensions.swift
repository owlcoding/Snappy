
import SwiftUI

/// The extension allows to add two CGPoint values.
/// The addition is a vector sum of the two points.
extension CGPoint: @retroactive AdditiveArithmetic {
    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public func distance(to other: Self) -> Double {
        sqrt(Double((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y)))
    }
}

/// The extension allows to add two CGSize values.
/// The addition is a vector sum of the two sizes.
extension CGSize: @retroactive AdditiveArithmetic {
    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

/// This extension allows to use + and - operators on Sets.
/// - Note: The `zero` value is an empty set.
/// - Note: The `+` operator is the union operator.
/// - Note: The `-` operator is the subtraction operator.
/// - Note: The `+` and `-` operators can also be used with a single element.
/// - Note: The `+` operator with a single element makes a union with the set containing the element.
/// - Note: The `-` operator with a single element makes a subtraction with the set containing the element.
extension Set: @retroactive AdditiveArithmetic {
    public static var zero: Set<Element> {
        []
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        lhs.subtracting(rhs)
    }
    
    public static func +(lhs: Self, rhs: Element) -> Self {
        lhs.union([rhs])
    }
    
    public static func -(lhs: Self, rhs: Element) -> Self {
        lhs.subtracting([rhs])
    }
}

/// A set of `UnitPoint` values.
/// - Note:
///
///    - The `all` set contains all `UnitPoint` values (i.e. corners, horizontalCenters, verticalCenters, and center - values are (0, 0), (0, 1), (1, 0), (1, 1), (0.5, 0.5), (0, 0.5), (1, 0.5), (0.5, 0), (0.5, 1)).
///    - The `corners` set contains only the corner values (i.e. (0, 0), (0, 1), (1, 0), (1, 1)).
///    - The `horizontalCenters` set contains only the horizontal center values (i.e. (0.5, 0), (0.5, 1)).
///    - The `verticalCenters` set contains only the vertical center values (i.e. (0, 0.5), (1, 0.5)).
///    - The `center` set contains only the center value (i.e. (0.5, 0.5)).
///    - The `corners`, `horizontalCenters`, `verticalCenters`, and `center` sets are subsets of the `all` set.
///
extension Set where Element == UnitPoint {
    public static var all: Set<UnitPoint> {
        corners + horizontalCenters + verticalCenters + center
    }
    
    public static var corners: Set<UnitPoint> {
        [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
    }
    
    public static var horizontalCenters: Set<UnitPoint> {
        [.leading, .trailing]
    }
    
    public static var verticalCenters: Set<UnitPoint> {
        [.top, .bottom]
    }
    
    public static var center: Set<UnitPoint> {
        [.center]
    }
}
