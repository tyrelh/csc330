# Structs
Two ways to implement datatypes in Racket:
* with lists
* with structs

```
(struct thing (cat dog bird) #:transparent)
```
This defines a new kind of thing and introduces several new functions:
* `(thing e1 e2 e3)` returns a "thing"
  * with `cat`, `dog`, and `bird` fields
  * holding results of evaluating `e1`, `e2`, `e3`
* `(thing? e)` evaluates `e` and returns `#t` if and only if the result is something that was created with the `thing` function
* `(thing-cat e)` get the value of `cat` field from `e`
* `(thing-dog e)` get the value of `dog` field from `e`
* `(thing-bird e)` get the value of `bird` field from `e`

The `#:transparent` flag allows the actions on the internals of the struct to be visible, whereas the default behaviour is to hide that.
