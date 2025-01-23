import gleam/order
import gleeunit
import gleeunit/should
import peano

// Note: constants defined in the section "Digits" are assumed
// to be correct and, as such, they are left untested.

pub fn successor_test() {
  peano.O |> peano.successor |> should.equal(peano.one)

  peano.three |> peano.successor |> should.equal(peano.four)
}

pub fn predecessor_test() {
  peano.O |> peano.predecessor |> should.be_error |> should.equal(Nil)

  peano.five |> peano.predecessor |> should.be_ok |> should.equal(peano.four)
}

pub fn predecessor_total_test() {
  peano.O |> peano.predecessor_total |> should.equal(peano.O)

  peano.seven |> peano.predecessor_total |> should.equal(peano.six)
}

// `increment` and `decrement` being aliases, it is not
// necessary to test them individually. 

pub fn compare_test() {
  // 2 < 3
  peano.two |> peano.compare(with: peano.three) |> should.equal(order.Lt)

  // 4 > 3
  peano.four |> peano.compare(with: peano.three) |> should.equal(order.Gt)

  // 3 = 3
  peano.three |> peano.compare(with: peano.three) |> should.equal(order.Eq)
}

pub fn equals_test() {
  // 2 ≠ 4
  peano.two |> peano.equals(to: peano.four) |> should.be_false

  // 5 = 5
  peano.five |> peano.equals(to: peano.five) |> should.be_true
}

pub fn is_greater_test() {
  // 5 > 3
  peano.five |> peano.is_greater(than: peano.three) |> should.be_true

  // 2 < 4
  peano.two |> peano.is_greater(than: peano.four) |> should.be_false

  // 6 = 6
  peano.six |> peano.is_greater(than: peano.six) |> should.be_false
}

pub fn is_greater_or_equal_test() {
  // 7 >= 2
  peano.seven |> peano.is_greater_or_equal(than: peano.two) |> should.be_true

  // 1 >= 1
  peano.one |> peano.is_greater_or_equal(than: peano.one) |> should.be_true

  // 4 < 8
  peano.four |> peano.is_greater_or_equal(than: peano.eight) |> should.be_false
}

pub fn is_less_test() {
  // 3 < 9
  peano.three |> peano.is_less(than: peano.nine) |> should.be_true

  // 5 = 5
  peano.five |> peano.is_less(than: peano.five) |> should.be_false

  // 7 > 1
  peano.seven |> peano.is_less(than: peano.one) |> should.be_false
}

pub fn is_less_or_equal_test() {
  // 4 <= 6
  peano.four |> peano.is_less_or_equal(than: peano.six) |> should.be_true

  // 8 <= 8
  peano.eight |> peano.is_less_or_equal(than: peano.eight) |> should.be_true

  // 2 > 1
  peano.two |> peano.is_less_or_equal(than: peano.one) |> should.be_false
}

pub fn min_test() {
  peano.min(peano.two, peano.three) |> should.equal(peano.two)

  peano.min(peano.six, peano.four) |> should.equal(peano.four)

  peano.min(peano.O, peano.five) |> should.equal(peano.O)
}

pub fn max_test() {
  peano.max(peano.two, peano.three) |> should.equal(peano.three)

  peano.max(peano.six, peano.four) |> should.equal(peano.six)

  peano.max(peano.O, peano.five) |> should.equal(peano.five)
}

pub fn add_test() {
  peano.O |> peano.add(to: peano.four) |> should.equal(peano.four)

  peano.six |> peano.add(to: peano.O) |> should.equal(peano.six)

  peano.five |> peano.add(to: peano.two) |> should.equal(peano.seven)

  // associativity
  peano.add(peano.add(peano.three, to: peano.four), to: peano.eight)
  |> should.equal(peano.add(
    peano.three,
    to: peano.add(peano.four, to: peano.eight),
  ))
}

pub fn main() {
  gleeunit.main()
}
