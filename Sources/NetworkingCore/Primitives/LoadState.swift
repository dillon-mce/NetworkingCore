//
//  LoadState.swift
//  brightwheelExercise
//
//  Created by Dillon McElhinney on 6/11/22.
//

public enum LoadState<T> {
    case loading
    case loaded(T)
}
