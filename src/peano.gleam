//// Natural numbers (integers greater or equal to 0) based on
//// Peano axioms.
//// 
//// Every function is tail-recursive unless specified
//// otherwise.
//// 
//// ## Substraction
//// 
//// Any substraction that would normally lead to a negative
//// integer in the realm of `int`s is clamped to 0.
//// 
//// ## Division
//// 
//// This module exposes two different division functions:
//// - `divide()` returns a `Result` as it can fail if the
//// divisor is 0
//// - `divide_total()` behaves the same as `int` division, that
//// is, it returns `0` when the divisor is `0`.

// ============= Conventions used in this library =============
//
// For functions that have an equivalent in gleam/int, we
// try to provide the same interface, with one exception:
// If the original parameter is named `x`, we use `n`.
//
// For functions where meaningful parameter names don't matter,
// we can use, in order, the following names: `n`, `m`, `p`, `q`
// If more than four parameters are required, we continue in the
// latin alphabet - hopefully never having to go beyond `z`.
//
// When pattern matching on a natural number `n`, for the branch
// where it matches `S(...)`, we choose to name the interior
// binding `n_pred`. This makes sense because if a number `n`
// is the successor of a number `m`, `m` is then the predecessor
// of `n`.
//
// Beware of the seemingly obvious, and comment on every design
// decision you take - reducing the complexity of the code's
// mental model should be our priority.
//
// =============================================================

// `bool.guard` is used for division
import gleam/bool

// `list.fold` is used for `sum` and `product` functions
import gleam/list

// We provide an ordering interface to `Nat`
import gleam/order

// `divide` and `modulo` are implemented from a fallible
// `divmod` function, so we use `result.map`
import gleam/result

/// A non-negative integer.
/// 
/// This inductive definition is based on the Peano axioms:
/// - 0 is a `Nat`.
/// - For every `n` of type `Nat`, `S(n)` is also of type `Nat`.
/// - 0 is not the successor of any `Nat`.
///   That is, there is no `n` such that `S(n)` = 0.
/// - For every `n` and `m` of type `Nat`, if `S(n)` = `S(m)`,
///   then `n` = `m`.
/// 
/// The reflexive, symmetric and transitive properties of
/// equality hold for `Nat` values as well.
/// Furthermore, `Nat` is closed under equality: for every `n`
/// and `m`, if `n` is of type `Nat` and `n` = `m`, then `m` is
/// also of type `Nat`. This guarantee is provided by the
/// homogeneous nature of equality in Gleam.
/// 
/// This library makes the choice of using the same constructor
/// names as the Rocq (formerly Coq) proof assistant, which uses
/// `O` and `S` to represent 0 and the successor function
/// respectively.
pub type Nat {
  O
  S(Nat)
}

// ## Digits
//
// We define digits from one to nine included for convenience.

pub const one = S(O)

pub const two = S(one)

pub const three = S(two)

pub const four = S(three)

pub const five = S(four)

pub const six = S(five)

pub const seven = S(six)

pub const eight = S(seven)

pub const nine = S(eight)

// ## Successor, predecessor

/// `successor(n)` returns the number that succeeds `n` on the
/// line of natural integers. It is equivalent to adding one to
/// `n`.
/// 
/// ## Examples
/// 
/// ```gleam
/// successor(O)
/// // -> S(O)  // one
/// ```
/// 
/// ```gleam
/// successor(four)
/// // -> S(S(S(S(S(O)))))  // six
/// ```
pub fn successor(n: Nat) -> Nat {
  S(n)
}

/// `predecessor(n)` returns the value that precedes `n` on the
/// line of natural integers.
/// 
/// Since 0 does not have a predecessor, this function is
/// fallible. If you are looking for a version where 0 is its
/// own predecessor, check out `predecessor_total()`.
/// 
/// ## Examples
/// 
/// ```gleam
/// predecessor(three)
/// // -> Ok(S(S(O)))  // two
/// ```
/// 
/// ```gleam
/// predecessor(O)
/// // -> Error(Nil)
/// ```
pub fn predecessor(n: Nat) -> Result(Nat, Nil) {
  case n {
    O -> Error(Nil)
    S(n_pred) -> Ok(n_pred)
  }
}

/// `predecessor_total(n)` returns the value that precedes `n`
/// on the line of natural integers if there is one, otherwise
/// 0.
/// 
/// ## Examples
/// 
/// ```gleam
/// predecessor_total(three)
/// // -> S(S(O))  // two
/// ```
/// 
/// ```gleam
/// predecessor_total(O)
/// // -> O
/// ```
pub fn predecessor_total(n: Nat) -> Nat {
  case n {
    O -> O
    S(n_pred) -> n_pred
  }
}

// ## Increment, decrement
// 
// `increment` and `decrement` are aliases for `successor` and
// `predecessor_total` respectively, for semantic purposes.

/// `increment(n)` adds one to `n` and returns the result.
/// 
/// ## Examples
/// 
/// ```gleam
/// increment(zero)
/// // -> S(O)  // one
/// ```
/// 
/// ```gleam
/// increment(three)
/// // -> S(S(S(S(O))))  // four
/// ```
pub const increment = successor

/// `decrement(n)` removes one to `n` and returns the result.
/// 
/// ## Examples
/// 
/// ```gleam
/// decrement(three)
/// // -> S(S(O))  // two
/// ```
/// 
/// ```gleam
/// decrement(zero)
/// // -> O
/// ```
pub const decrement = predecessor_total

// ## Comparison, ordering

/// `compare(n, with: m)` returns whether `n` is equal, greater
/// or less than `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// compare(two, with: three)
/// // -> Lt
/// ```
/// 
/// ```gleam
/// compare(four, with: three)
/// // -> Gt
/// ```
/// 
/// ```gleam
/// compare(three, with: three)
/// // -> Eq
/// ```
pub fn compare(n: Nat, with m: Nat) -> order.Order {
  case n, m {
    O, O -> order.Eq
    O, S(_) -> order.Lt
    S(_), O -> order.Gt
    S(n_pred), S(m_pred) -> compare(n_pred, m_pred)
  }
}

/// `equals(n, with: m)` returns whether `n` is equal to `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// equals(two, with: four)
/// // -> False
/// ```
/// 
/// ```gleam
/// equals(five, with: five)
/// // -> True
/// ```
pub fn equals(n: Nat, with m: Nat) -> Bool {
  case compare(n, with: m) {
    order.Eq -> True
    order.Gt | order.Lt -> False
  }
}

/// `is_greater(n, than: m)` returns whether `n` is greater than
/// `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// is_greater(five, than: three)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_greater(two, than: four)
/// // -> False
/// ```
/// 
/// ```gleam
/// is_greater(six, than: six)
/// // -> False
/// ```
pub fn is_greater(n: Nat, than m: Nat) -> Bool {
  case compare(n, with: m) {
    order.Gt -> True
    order.Eq | order.Lt -> False
  }
}

/// `is_greater_or_equal(n, than: m)` returns whether `n` is
/// greater or equal than `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// is_greater_or_equal(seven, than: two)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_greater_or_equal(one, than: one)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_greater_or_equal(four, than: eight)
/// // -> False
/// ```
pub fn is_greater_or_equal(n: Nat, than m: Nat) -> Bool {
  case compare(n, with: m) {
    order.Eq | order.Gt -> True
    order.Lt -> False
  }
}

/// `is_less(n, than: m)` returns whether `n` is less than `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// is_less(three, than: nine)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_less(five, than: five)
/// // -> False
/// ```
/// 
/// ```gleam
/// is_less(seven, than: one)
/// // -> False
/// ```
pub fn is_less(n: Nat, than m: Nat) -> Bool {
  !is_greater_or_equal(n, than: m)
}

/// `is_less_or_equal(n, than: m)` returns whether `n` is less
/// or equal than `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// is_less_or_equal(four, than: six)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_less_or_equal(eight, than: eight)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_less_or_equal(two, than: one)
/// // -> False
/// ```
pub fn is_less_or_equal(n: Nat, than m: Nat) -> Bool {
  !is_greater(n, than: m)
}

/// `min(n, m)` returns the smaller between `n` and `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// min(two, three)
/// // -> S(S(O))  // two
/// ```
pub fn min(n: Nat, m: Nat) -> Nat {
  case is_less(n, m) {
    True -> n
    False -> m
  }
}

/// `max(n, m)` returns the larger between `n` and `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// max(two, three)
/// // -> S(S(S(O)))  // three
/// ```
pub fn max(n: Nat, m: Nat) -> Nat {
  case is_greater(n, m) {
    True -> n
    False -> m
  }
}

// ## Arithmetic

/// `add(n, to: m)` adds `n` to `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// add(five, to: two)
/// // -> S(S(S(S(S(S(S(O)))))))  // seven
/// ```
pub fn add(n: Nat, to m: Nat) -> Nat {
  case n, m {
    _, O -> n
    O, _ -> m
    S(_), S(m_pred) -> add(S(n), to: m_pred)
  }
}

pub fn subtract(n: Nat, to m: Nat) -> Nat {
  todo
}

pub fn multiply(n: Nat, with m: Nat) -> Nat {
  todo
}

pub fn divmod(dividend: Nat, divisor: Nat) -> Result(#(Nat, Nat), Nil) {
  todo
}

pub fn divmod_total(dividend: Nat, divisor: Nat) -> #(Nat, Nat) {
  todo
}

pub fn divide(dividend: Nat, divisor: Nat) -> Result(Nat, Nil) {
  todo
}

pub fn divide_total(dividend: Nat, divisor: Nat) -> Nat {
  todo
}

pub fn modulo(dividend: Nat, divisor: Nat) -> Result(Nat, Nil) {
  todo
}

pub fn modulo_total(dividend: Nat, divisor: Nat) -> Nat {
  todo
}

pub fn power(base: Nat, exponent: Nat) -> Nat {
  todo
}

// ## Basic functions

pub fn double(n: Nat) -> Nat {
  todo
}

pub fn square(n: Nat) -> Nat {
  todo
}

pub fn square_root(n: Nat) -> Nat {
  todo
}

pub fn factorial(n: Nat) -> Nat {
  product(make_range(start: one, stop: n, step: one))
}

// ## Iterative functions

pub fn sum(numbers: List(Nat)) -> Nat {
  todo
}

pub fn product(numbers: List(Nat)) -> Nat {
  todo
}

// ## Ranges

pub fn make_range(start n: Nat, stop m: Nat, step p: Nat) -> List(Nat) {
  todo
}

pub fn up_to(stop n: Nat) -> List(Nat) {
  make_range(start: O, stop: n, step: one)
}

pub fn in_range(n: Nat, min min_bound: Nat, max max_bound: Nat) -> Bool {
  todo
}

pub fn clamp(n: Nat, min min_bound: Nat, max max_bound: Nat) -> Nat {
  todo
}

// ## Predicates

/// `is_even(n)` returns whether `n` is even. It's 0, 2, 4, ...
/// 
/// ## Examples
/// 
/// ```gleam
/// is_even(O)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_even(one)
/// // -> False
/// ```
/// 
/// ```gleam
/// is_even(six)
/// // -> True
/// ```
pub fn is_even(n: Nat) -> Bool {
  case n {
    O -> True
    S(O) -> False
    S(S(n_pred)) -> is_even(n_pred)
  }
}

/// `is_odd(n)` returns whether `n` is odd. It's 1, 3, 5, ...
/// 
/// ## Examples
/// 
/// ```gleam
/// is_odd(O)
/// // -> False
/// ```
/// 
/// ```gleam
/// is_odd(one)
/// // -> True
/// ```
/// 
/// ```gleam
/// is_odd(six)
/// // -> False
/// ```
pub fn is_odd(n: Nat) -> Bool {
  !is_even(n)
}

// ## Type conversion to Nat, of Nat

fn to_int_tailrec(n: Nat, acc: Int) -> Int {
  case n {
    O -> acc
    S(n_pred) -> to_int_tailrec(n_pred, 1 + acc)
  }
}

/// `to_int(n)` converts `n` into a built-in `Int` value.
/// 
/// ## Examples
/// 
/// ```gleam
/// to_int(O)
/// // -> 0
/// ```
/// 
/// ```gleam
/// to_int(three)
/// // -> 3
/// ```
pub fn to_int(n: Nat) -> Int {
  to_int_tailrec(n, 0)
}

fn to_float_tailrec(n: Nat, acc: Float) -> Float {
  case n {
    O -> acc
    S(n_pred) -> to_float_tailrec(n_pred, 1.0 +. acc)
  }
}

/// `to_float(n)` converts `n` into a built-in `Float` value.
/// 
/// BEWARE: conversion is done by repeatingly adding 1. As such,
/// due to the nature of floating-point numbers, the result can
/// be imprecise.
/// 
/// ## Examples
/// 
/// ```gleam
/// to_float(O)
/// // -> 0.0
/// ```
/// 
/// ```gleam
/// to_float(five)
/// // -> 5.0
/// ```
pub fn to_float(n: Nat) -> Float {
  to_float_tailrec(n, 0.0)
}

pub fn to_string(n: Nat) -> String {
  todo
}

pub fn to_numerical_representation(n: Nat) -> String {
  todo
}
