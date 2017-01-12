//
//  OneDim.swift
//  CcittCodec
//
//  Created by Yang Zhou on 2016-10-28.
//
//

import Foundation
let whiteTermCode = [
    "00110101", "000111", "0111", "1000", "1011", "1100", "1110",
    "1111", "10011", "10100", "00111", "01000", "001000", "000011",
    "110100", "110101", "101010", "101011", "0100111", "0001100",
    "0001000", "0010111", "0000011", "0000100", "0101000", "0101011",
    "0010011", "0100100", "0011000", "00000010", "00000011", "00011010",
    "00011011", "00010010", "00010011", "00010100", "00010101", "00010110",
    "00010111", "00101000", "00101001", "00101010", "00101011", "00101100",
    "00101101", "00000100", "00000101", "00001010", "00001011", "01010010",
    "01010011", "01010100", "01010101", "00100100", "00100101", "01011000",
    "01011001", "01011010", "01011011", "01001010", "01001011", "00110010", "00110011", "00110100"]

let blackTermCode = [
    "0000110111", "010", "11", "10", "011", "0011", "0010", "00011", "000101",
    "000100", "0000100", "0000101", "0000111", "00000100", "00000111", "000011000",
    "0000010111", "0000011000", "0000001000", "00001100111", "00001101000",
    "00001101100", "00000110111", "00000101000", "00000010111", "00000011000",
    "000011001010", "000011001011", "000011001100", "000011001101", "000001101000",
    "000001101001", "000001101010", "000001101011", "000011010010", "000011010011",
    "000011010100", "000011010101", "000011010110", "000011010111", "000001101100",
    "000001101101", "000011011010", "000011011011", "000001010100", "000001010101",
    "000001010110", "000001010111", "000001100100", "000001100101", "000001010010",
    "000001010011", "000000100100", "000000110111", "000000111000", "000000100111",
    "000000101000", "000001011000", "000001011001", "000000101011", "000000101100",
    "000001011010", "000001100110", "000001100111"]

let endOfLine = "000000000001"

extension String {
    func chunked() -> [String] {
        var chunked = [String]()
        var currentChar = self[self.startIndex]
        var currentChunk = ""
        for c in self.characters {
            if c == currentChar {
                currentChunk += String(c)
            } else {
                chunked.append(currentChunk)
                currentChar = c
                currentChunk = String(c)
            }
        }
        if !currentChunk.isEmpty {
            chunked.append(currentChunk)
        }
        //print("And the line can be chunked to $\(chunked)$.")
        return chunked
    }
}


func onedEncSingleLine (line : String) -> String {
    //print("The next line is $\(line)$.")
    let encodedLine = line.chunked()
        .map({s in s.hasPrefix("0") ? whiteTermCode[s.characters.count] : blackTermCode[s.characters.count]})
//        .joined()
    //print("Refer to RFC804, the encoded sequence should be $\(encodedLine)$.")
    //print("Prepending EOL to it, this line is encoded as \\[\(endOfLine + encodedLine.joined())\\]")
    return endOfLine + encodedLine.joined()
}

func onedEncode(_ message: [String]) -> String {
    return (message.map(onedEncSingleLine).joined()) + String(repeating: endOfLine, count: 6)
}

func onedDecSingleLine (line : String) -> String {
    var decodedLine = ""
    var currentSegment = ""
    var checkWhite = true
    for c in line.characters {
        currentSegment += String(c)
        if let len = (checkWhite ? whiteTermCode.index(of: currentSegment) : blackTermCode.index(of: currentSegment)) {
            decodedLine += String(repeating: (checkWhite ? "0" : "1"), count: len)
            checkWhite = !checkWhite
            currentSegment = ""
        }
    }
    return decodedLine
}

func onedDecode(_ message: String) -> [String] {
    var decoded = [String]()
    for line in message.components(separatedBy: endOfLine) {
        decoded.append(onedDecSingleLine(line: line))
    }
    
    return Array(decoded.dropLast(5).dropFirst())
}
