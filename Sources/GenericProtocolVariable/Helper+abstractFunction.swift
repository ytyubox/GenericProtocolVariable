//
/*
 *		Created by 游宗諭 in 2021/8/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 12.0
 */

func abstractFunction(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("abstract Function should never be call", file: file, line: line)
}
