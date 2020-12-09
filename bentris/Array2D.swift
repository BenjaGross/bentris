//
//  Array2D.swift
//  bentris
//
//  Created by Ben Gross on 12/8/20.
//

class Array2D<T> {
  let columns: Int
  let rows: Int

  var array: Array<T?>

  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows

//    let size = rows*columns

    array = Array<T?>(repeating: nil, count: rows*columns)
  }

  subscript(column: Int, row: Int) -> T? {
    get {
      return array[(row * columns) + column]
    }
    set(newValue) {
      array[(row * columns) + column] = newValue
    }
  }
}
