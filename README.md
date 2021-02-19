# Copy ellipsis arguments from one function to another

_Matthew Kay, Northwestern University, <mjskay@northwestern.edu>_

This is an R package defining a single function, `copy_dots()`, which is an
experiment in improving R package documentation. If you want to use it, the
most sensible plan is probably to just copy the `copy_dots()` function
into your package (see [R/copy_dots.R](R/copy_dots.R)).

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

Do note that this is an ugly hack! Think hard before using something like this
in practice. Hopefully one day the R help system and/or R IDEs will provide a
better solution to this problem.
