import UIKit

public extension UIColor {

  /**
   Define UIColor with hex color string.

   - parameter hex:   hex color string, just like #fff or #ffffff
   - parameter alpha: a number between 0 and 1

   - returns: UIColor
   */
  public convenience init?(hex: String, alpha: Float = 1.0) {

    if hex.rangeOfString("(^#?[0-9A-Fa-f]{6}$)|(^#?[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) == nil {
      self.init()
      return nil
    }

    var red: String
    var green: String
    var blue: String
    var hexString: String = hex

    // Check for hash and remove the hash
    if hexString.hasPrefix("#") {
      hexString = hexString.substringFromIndex(hexString.startIndex.advancedBy(1))
    }

    // Deal with 3 character hex strings
    if hexString.characters.count == 3 {
      red = (hexString as NSString).substringToIndex(1)
      green = (hexString as NSString).substringWithRange(NSMakeRange(1, 1))
      blue = (hexString as NSString).substringFromIndex(2)

      red += red
      green += green
      blue += blue
    } else {
      red = (hexString as NSString).substringToIndex(2)
      green = (hexString as NSString).substringWithRange(NSMakeRange(2, 2))
      blue = (hexString as NSString).substringFromIndex(4)
    }

    var redInt: CUnsignedInt = 0
    var greenInt: CUnsignedInt = 0
    var blueInt: CUnsignedInt = 0

    NSScanner(string: red).scanHexInt(&redInt)
    NSScanner(string: green).scanHexInt(&greenInt)
    NSScanner(string: blue).scanHexInt(&blueInt)

    self.init(
      red: CGFloat(redInt) / 255.0,
      green: CGFloat(greenInt) / 255.0,
      blue: CGFloat(blueInt) / 255.0,
      alpha: CGFloat(alpha)
    )
  }

}
