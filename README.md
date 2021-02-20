# Copy ellipsis arguments from one function to another

_Matthew Kay, Northwestern University, <mjskay@northwestern.edu>_

This is an R package defining two functions, `copy_dots()` and `merge_dots()`,
which is an experiment in improving R package documentation. If you want to use it, the
most sensible plan is probably to just copy either the `copy_dots()` function
([R/copy_dots.R](R/copy_dots.R)) or `merge_dots()` function ([R/merge_dots.R](R/merge_dots.R))
into your package.

The idea is that we often write functions in packages like this:

```r
inner_function = function(x, y = "old_y_default", z = "z_default") {
  cat(x, " ", y, " ", z, "\n")
}
outer_function = function(y = "new_y_default", ...) {
  inner_function(y = y, ...)
}
```

Yet when you do this, the parameter list for `outer_function()` will not 
include the arguments `x` or `z`, so autocomplete in IDEs will not find
those arguments. 

One solution would be to manually copy over the parameters from
`inner_function()` to `outer_function()`, but that presents a maintenance
nightmare and defeats the purpose of using `...` in the first place.

`copy_dots()` tries to solve this by copying over the parameters from one or
more other functions into the definition of another function. The idea is to
augment the above definition of `outer_function()` with a call to `copy_dots()`
listing all the other functions that are called down to using `...` parameters
(in this case, `inner_function()`):

```r
outer_function = copy_dots(inner_function, function(y = "new_y_default", ...) {
  inner_function(y = y, ...)
})
```

The definition of `outer_function()` will now look something like this
(exception that you don't have to type it!):

```r
outer_function = function(y = "new_y_default", ..., x, z = "z_default") {
  (function (y = "new_y_default", ...) {
    inner_function(y = y, ...)
  })(y = y, ..., x = x, z = z)
}
```

`merge_dots()` takes a slightly different approach, and tries to rewrite the
passed function (instead of wrapping it) by merging the copied arguments into
any functions calls using the source functions. You use it the same way as
`copy_dots()`:

```r
outer_function = merge_dots(inner_function, function(y = "new_y_default", ...) {
  inner_function(y = y, ...)
})
```

But it generates a function definition that looks like this:

```r
outer_function = function(y = "new_y_default", ..., x, z = "z_default") {
  inner_function(y = y, ..., x = x, z = z)
}
```

Do note that this is an ugly hack! Think hard before using something like this
in practice. Hopefully one day the R help system and/or R IDEs will provide a
better solution to this problem.
