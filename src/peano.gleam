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

/// `equals(n, to: m)` returns whether `n` is equal to `m`.
/// 
/// ## Examples
/// 
/// ```gleam
/// equals(two, to: four)
/// // -> False
/// ```
/// 
/// ```gleam
/// equals(five, to: five)
/// // -> True
/// ```
pub fn equals(n: Nat, to m: Nat) -> Bool {
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
// TODO: subtract, multiply, divmod, divide, modulo, power
// TODO: double, square, square_root, negate, absolute_value
// TODO: clamp, sum, product, factorial, is_even, is_odd
// TODO: to_int, to_float, to_string
