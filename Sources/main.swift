import Foundation

let origin = ["000000000000000000000000",
              "011110011110011110011110",
              "010000010000010000010010",
              "011100011100011100011110",
              "010000010000010000010000",
              "010000011110011110010000",
              "000000000000000000000000"]

//let encoded = onedEncode(origin)
//print(encoded)
//
//let decoded = onedDecode(encoded)
//print(decoded)

let twodEncoded = twodEncode(origin, k: 8)
print(twodEncoded)

//let twodEncoded = "0000000000011010100000000000000100010001110110010111011001011101100101110111000000000001010000010100000101000001010000010000010110000000000010100001110000111000011100011100000000000101000010100001010000101000001010000000000010111000001110000011111000000000001000010001000100011"
let twodDecoded = twodDecode(twodEncoded)
print(twodDecoded)
