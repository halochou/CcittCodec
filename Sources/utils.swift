//
//  utils.swift
//  CcittCodec
//
//  Created by Yang Zhou on 2016-10-31.
//
//

import Foundation

func showPointerPosition(ref: String, line: String,
                         a0: String.Index, a1: String.Index,
                         b1: String.Index, b2: String.Index) -> String {
    var upper = ""
    var i = ref.startIndex
    while i < ref.endIndex {
        upper += (i==b1 || i==b2) ? "v" : " "
        i = ref.index(after: i)
    }
    
    var lower = ""
    var j = line.startIndex
    while j < line.endIndex {
        lower += (j==a0 || j==a1) ? "^" : " "
        j = ref.index(after: j)
    }
    let ref = " " + String(ref.characters.dropFirst())
    let line = " " + String(line.characters.dropFirst())
    return "\\begin{verbatim}\n\(upper)\n\(ref)\n\(line)\n\(lower)\n\\end{verbatim}"
}
