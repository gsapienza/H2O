import UIKit
import XCTest
@testable import HexColors

class HexColorsTests: XCTestCase {

  func testThreeCharacterCount() {
    let color = UIColor(hex: "#FFF")
    XCTAssertNotNil(color, "Should not be nil.")
  }

  func testSixCharacterCount() {
    let color = UIColor(hex: "#FFFFFF")
    XCTAssertNotNil(color, "Should not be nil.")
  }

  func testOtherCharacterCount() {
    let color = UIColor(hex: "#F")
    XCTAssertNil(color, "Should be nil.")
  }

  func testAlphaChannel() {
    let color = UIColor(hex: "#FFF", alpha: 0.5)
    XCTAssertNotNil(color, "Should not be nil.")
  }
}
