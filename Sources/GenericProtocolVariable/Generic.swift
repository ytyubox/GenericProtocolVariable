//
/* 
 *		Created by 游宗諭 in 2021/8/4
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 12.0
 */


public protocol Generic {
    associatedtype AnyType
    func getter() -> AnyType
}
