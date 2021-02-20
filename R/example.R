#' Example: an inner function
#'
#' Along with [outer_function()], this function provides an example of the use
#' of `copy_dots()` in a package. See [outer_function()].
#'
#' @param x A parameter
#' @param y A parameter with a default
#' @param z Another parameter with a default
#'
#' @examples
#'
#' ## See outer_function()
#'
#' @family example
#' @seealso [copy_dots()]
#' @export
inner_function = function(x, y = "old_y_default", z = "z_default") {
  cat(x, " ", y, " ", z, "\n")
}

#' Example: an outer function
#'
#' Along with [inner_function()], this function provides an example of the use
#' of `copy_dots()` in a package. Ellipsis parameters (`...`) from this function
#' are passed to [inner_function()], but `copy_dots()` is unsed in the function
#' definition so that those parameters appear as parameters in the definition
#' and documentation of [outer_function()].
#'
#' @inheritParams inner_function
#' @param ... Parameters passed to `inner_function()`
#'
#' @examples
#'
#' inner_function(x = "inner_x_value")
#' outer_function(x = "outer_x_value")
#'
#' @family example
#' @seealso [copy_dots()]
#' @export
outer_function = copy_dots(inner_function, function(y = "new_y_default", ...) {
  inner_function(y = y, ...)
})
