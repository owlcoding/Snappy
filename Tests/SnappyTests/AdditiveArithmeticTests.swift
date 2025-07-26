import XCTest
@testable import Snappy

final class AdditiveArithmeticTests: XCTestCase {
    func testCGPointAdditionAndSubtraction() {
        let p1 = CGPoint(x: 1, y: 2)
        let p2 = CGPoint(x: 3, y: 4)
        XCTAssertEqual(p1 + p2, CGPoint(x: 4, y: 6))
        XCTAssertEqual(p2 - p1, CGPoint(x: 2, y: 2))
        XCTAssertEqual(CGPoint.zero + .zero, .zero)
    }

    func testCGSizeAdditionAndSubtraction() {
        let s1 = CGSize(width: 5, height: 10)
        let s2 = CGSize(width: 2, height: 3)
        XCTAssertEqual(s1 + s2, CGSize(width: 7, height: 13))
        XCTAssertEqual(s1 - s2, CGSize(width: 3, height: 7))
        XCTAssertEqual(CGSize.zero + .zero, .zero)
    }

    func testSetAdditiveArithmetic() {
        let setA: Set<Int> = [1, 2]
        let setB: Set<Int> = [2, 3]

        XCTAssertEqual(setA + setB, [1, 2, 3])
        XCTAssertEqual(setA - setB, [1])

        XCTAssertEqual(setA + 3, [1, 2, 3])
        XCTAssertEqual(setA - 1, [2])

        XCTAssertEqual(Set<Int>.zero, [])
    }
}
