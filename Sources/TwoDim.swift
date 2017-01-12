//
//  TwoDim.swift
//  CcittCodec
//
//  Created by Yang Zhou on 2016-10-29.
//
//

import Foundation

let passCode = "0001"
let horizontalCodeHead = "001"
let verticalCode = ["0000011","000011","011","1","010","000010","0000010"]

enum Mode {
    case pass
    case horizontal
    case vertical (Int)
    case error
}

enum Color : String {
    case white = "0"
    case black = "1"
}

extension String {
    func nextChangingElement(after: String.Index, ref: String) -> String.Index {
        guard after != self.endIndex else {
            return after
        }
        for nextIndex in self.characters.indices[self.index(after: after)..<self.endIndex] {
            if (self[nextIndex] != ref[after]) && (self[self.index(before: nextIndex)] == ref[after]) {
                return nextIndex
            }
        }
        return self.endIndex
    }
}


func twodEncSingleLine (ref: String, line: String) -> String {
    print("The reference line and coding line is: \n\\begin{verbatim}\n\(ref)\n\(line)\\end{verbatim}")
    var encoded = [endOfLine+"0"]
    let line = "0" + line
    let ref = "0" + ref
    var a0 = line.startIndex
    while a0 < line.endIndex {
        let a1 = line.nextChangingElement(after: a0, ref: line)
        let b1 = ref.nextChangingElement(after: a0, ref: line)
        let b2 = ref.nextChangingElement(after: b1, ref: ref)
        
        print("The pointers' status is now as below.")
        print(showPointerPosition(ref: ref, line: line, a0: a0, a1: a1, b1: b1, b2: b2))
        
        if b2 < a1 { //Pass Mode
            encoded.append(passCode)
            a0 = b2
            
            print("$b_2$ is to the left of $a_1$. This should be encoded as Pass Mode. So the encoded sequence is \(passCode).")
        } else if abs(line.characters.distance(from: a1, to: b1)) <= 3 {
            // Vertical Mode
            let delta = line.characters.distance(from: a1, to: b1)
            let v = verticalCode[delta + 3]
            encoded.append(v)
            a0 = a1
            
            print("$b_2$ is not to the left of $a_1$ and $|a_1b_1| \\leq 3$. This should be encoded as Vertical Mode and delta is \(delta). So the encoded sequence is \(v).")
        } else {
            // Horizontal Mode
            let a2 = line.nextChangingElement(after: a1, ref: line)
            
            let a0a1 = (a0 == line.startIndex) ? (line.substring(with: (line.index(after: a0) ..< a1))) : (line.substring(with: a0..<a1))

            
            let mA0a1 = a0a1.hasPrefix("0") ? whiteTermCode[a0a1.characters.count] : blackTermCode[a0a1.characters.count]
            let a1a2 = line.substring(with: a1..<a2)
            let mA1a2 = a1a2.hasPrefix("0") ? whiteTermCode[a1a2.characters.count] : blackTermCode[a1a2.characters.count]
            encoded.append(horizontalCodeHead + mA0a1 + mA1a2)
            a0 = a2
            
            print("$b_2$ is not to the left of $a_1$ and $|a_1b_1| > 3$.")
            print("This should be encoded as Horizontal Mode which is H+M(\(a0a1.characters.count))+M(\(a1a2.characters.count))")
            print("So the encoded sequence is \(horizontalCodeHead + mA0a1 + mA1a2).")
        }
    }
    return encoded.joined()
}

func twodEncode(_ message : [String], k: Int) -> String {
    var encoded = [String]()
    for (order, line) in message.enumerated() {
        if (order % k) == 0 {
            let encodedLine = String(onedEncSingleLine(line: line).characters.dropFirst(endOfLine.characters.count))
            print("This line is encoded with one-dimensional coding, so prepending EOL+1 to the result.")
            encoded.append(endOfLine + "1" + encodedLine)
        } else {
            print("This line is encoded with two-dimensional coding, so prepending EOL+0 to the result.")
            encoded.append(twodEncSingleLine(ref: message[order-1], line: message[order]))
        }
    }
//    encoded.append(String(repeating: endOfLine, count: 6))
    return encoded.joined()
}


func twodDecSingleLine (ref: String, msg: String) -> String {
    print("This line is leaded by EOL+0, meaning it's encoded with two-dimensional coding.")
    var line = "0"
    let ref = "0" + ref
    var a0 = line.startIndex
    
    var codeword = ""
    var color = "0"
    var index = msg.startIndex
    while index < msg.endIndex {
        let c = msg[index]
        let b1 = ref.nextChangingElement(after: a0, ref: line)
        let b2 = ref.nextChangingElement(after: b1, ref: ref)
        

        codeword += String(c)
        if codeword == passCode {
            print("The status of pointers is as below:")
            print(showPointerPosition(ref: ref, line: line, a0: a0, a1: a0, b1: b1, b2: b2))
            
            print("Codeword \(codeword) is Pass Mode Code. So put $a_0$ under $b_2$, extending the decoding line with the same color.")
            codeword = ""
            for _ in ref.characters.indices[a0..<b2] {
                line += color
            }
            a0 = line.index(before: line.endIndex)
        } else if var delta = verticalCode.index(of: codeword) {
            print("The status of pointers is as below:")
            print(showPointerPosition(ref: ref, line: line, a0: a0, a1: a0, b1: b1, b2: b2))
            
            print("Codeword \(codeword) is Vertical(\(delta)) Mode Code.")
            print("So extend the decoding line with the same color and append one pel alternative color.")
            codeword = ""
            delta = 3 - delta
            let b1p = ref.index(b1, offsetBy: delta)
            let n = ref.distance(from: a0, to: b1p)
            line += String(repeating: color, count: n-1)
            color = color == "0" ? "1" : "0"
            if b1p != ref.endIndex {
                line += color
            }
            a0 = line.index(before: line.endIndex)
        } else if codeword == horizontalCodeHead {
            print("The status of pointers is as below:")
            print(showPointerPosition(ref: ref, line: line, a0: a0, a1: a0, b1: b1, b2: b2))
            
            print("Codeword \(codeword) is Horizontal Mode Code.")
            print("So the next two codewords present two segments of alternative color, whose lengths are ",terminator: " ")
            codeword = ""
            let colorOrder = [color, color == "0" ? "1" : "0"]
            var mcode = ""
            print("[", terminator: "")
            for col in colorOrder {
                index = msg.index(after: index)
                while index < msg.endIndex {
                    mcode += String(msg[index])
                    if let len = (col == "0") ? whiteTermCode.index(of: mcode) : blackTermCode.index(of: mcode) {
                        mcode = ""
                        line += String(repeating: col, count: len)
                        print("\(len), ", terminator:"")
                        break
                    }
                    index = msg.index(after: index)
                }
            }
            print("].\nAppend these two segments to the decoding line.")
            a0 = line.index(before: line.endIndex)
        }
        index = msg.index(after: index)
    }
    return String(line.characters.dropFirst())
}

func twodDecode (_ message : String) -> [String] {
    var decoded = [String]()
    let lines = message.components(separatedBy: endOfLine).dropFirst()
    for line in lines {
        print("The \\textbf{next} line's bitstream is \\begin{verbtim}\n\(String(line.characters.dropFirst()))\\end{verbtim}")
        if line[line.startIndex] == "1" {
            decoded.append(onedDecSingleLine(line: String(line.characters.dropFirst())))
        } else {
            let decodedLine = twodDecSingleLine(ref: decoded[decoded.count-1], msg: String(line.characters.dropFirst()))
            decoded.append(decodedLine)
        }
    }
    return decoded
}
