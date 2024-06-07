//
//  TLGenerateLazyCode.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/20.
//

import Cocoa
import XcodeKit

class TLGenerateLazyCode: TLSourceEditorCommondHandler {
    static let sharedInstance = TLGenerateLazyCode()
    lazy var lazyCodeArray: NSMutableArray = NSMutableArray.init()
    
    func processCodeWithInvocation(invocation: XCSourceEditorCommandInvocation) -> Void {
        for item in invocation.buffer.selections { // 遍历每一行选中的去添加lazy code
            self.addLazyCode(textRange: item as! XCSourceTextRange, invocation: invocation)
        }
    }
    
    private func addLazyCode(textRange: XCSourceTextRange, invocation: XCSourceEditorCommandInvocation) {
        self.lazyCodeArray.removeAllObjects()

        let startLine = textRange.start.line
        let endLine = textRange.end.line
        for lineIndex in startLine...endLine {
            var lineText: NSString = invocation.buffer.lines.object(at: lineIndex) as! NSString
            print("st tool lineText -- \(lineText)")
            if lineText.length <= 0 {
                continue
            }
            
            // 格式化代码
//             invocation.buffer.lines.replaceObject(at: lineIndex, with: formattedLineContent)
            
            
//            let currentClassName = invocation.buffer.lines
            
        }
    }
}
