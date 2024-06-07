//
//  SourceEditorCommand.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/1.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // 获取当前选中的文本段落
        let selections = invocation.buffer.selections
        guard let textRange = selections.firstObject as? XCSourceTextRange else {
            completionHandler(nil) // 如果没有选中内容，则不进行任何操作
            return
        }
        // 根据选中范围，获取文本内容
        let startLine = textRange.start.line
        let endLine = textRange.end.line
        let startColumn = textRange.start.column
        let endColumn = textRange.end.column
        
        var selectedText: String = ""
        
        if startLine == endLine {
            // 如果选中内容在同一行
            let line = invocation.buffer.lines[startLine] as! String
            let range = line.index(line.startIndex, offsetBy: startColumn)...line.index(line.startIndex, offsetBy: endColumn)
            selectedText = String(line[range])
        } 
        else {
            // 如果选中内容跨多行
            for i in startLine...endLine {
                if let line = invocation.buffer.lines[i] as? String {
                    if i == startLine {
                        // 选中的第一行
                        let range = line.index(line.startIndex, offsetBy: startColumn)..<line.endIndex
                        selectedText.append(contentsOf: line[range])
                    } else if i == endLine {
                        // 选中的最后一行
                        let range = line.startIndex...line.index(line.startIndex, offsetBy: endColumn)
                        selectedText.append(contentsOf: line[range])
                    } else {
                        // 完全选中的中间行
                        selectedText.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    // 为了保持格式，在行之间添加换行符
                    if i < endLine {
                        selectedText.append("\n")
                    }
                }
            }
        }
         
        let identifier = invocation.commandIdentifier
        print(identifier)
        if identifier == TLGenerateLazyMethodIdentifier,
           let varName = extractVariableNames(from: selectedText)?.first {
            
             
            let startStr =  """
        private lazy var \(varName) = {
        
        """
            let endStr =  """
                            
        return \(varName)
        }()
        """
            
            // 在选中文本的最开头和最结尾插入自定义字符串
            invocation.buffer.lines.insert(startStr, at: startLine)
            // 这里为啥是+2
            invocation.buffer.lines.insert(endStr, at: endLine+2)
            
        }
        completionHandler(nil)
    }
    func extractVariableNames(from text: String) -> [String]? {
        var variableNames: [String]? = []
        
        do {
            let pattern = "\\b(?:let|var)\\s+([a-zA-Z_][a-zA-Z0-9_]*)"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let variableName = text[range]
                    variableNames?.append(String(variableName))
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        return variableNames
    }
}
