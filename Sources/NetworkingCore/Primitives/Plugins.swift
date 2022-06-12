//
//  Plugins.swift
//  brightwheelExercise
//
//  Created by Dillon McElhinney on 6/11/22.
//

public typealias Plugin<T> = (T) -> T
public typealias Modifier<T> = (inout T) -> Void

public struct PluginCollection<Value> {
    private var plugins = [Plugin<Value>]()

    public init() {}

    public mutating func add(_ plugin: @escaping Plugin<Value>) {
        plugins.append(plugin)
    }

    public mutating func addModifier(_ modifier: @escaping Modifier<Value>) {
        plugins.append { value in
            var mutableValue = value
            modifier(&mutableValue)
            return mutableValue
        }
    }

    public func combining(_ other: PluginCollection<Value>) -> PluginCollection<Value> {
        var mutable = other
        plugins.forEach { mutable.add($0) }
        return mutable
    }

    public func apply(to value: Value) -> Value {
        plugins.reduce(value) { value, plugin in
            plugin(value)
        }
    }
}
