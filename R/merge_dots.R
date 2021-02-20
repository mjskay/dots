#' Copy ellipsis arguments from one set of functions to a wrapper function
#'
#' Alternative approach to `copy_dots()` to copy arguments from multiple source functions into a
#' destination function that uses the ellipsis (`...`) to pass arguments to
#' those functions in order to improve documentation. This approach rewrites function calls
#' inside the wrapped function to pass the corresponding arguments.
#'
#' @param ... A list of functions. The last function in the list is used as
#'   a *destination* function, and all previous functions in the list are
#'   considered *source* functions. Arguments from the *source* functions
#'   that do not already appear in the definition of the *destination* function
#'   are copied into the function definition of a wrapper around the
#'   *destination* function.
#'
#' @seealso `copy_dots()` for another approach.
#' @examples
#'
#' # Given these function definitions:
#' inner_function = function(x, y = "old_y_default", z = "z_default") {
#'   cat(x, " ", y, " ", z, "\n")
#' }
#' outer_function = function(y = "new_y_default", ...) {
#'   inner_function(y = y, ...)
#' }
#'
#' # the argument list and documentation of outer_function above will not
#' # include parameters from inner_function, making it harder to
#' # understand. However, copying out these arguments manually is not
#' # a great solution either. `merge_dots()` copies the arguments to the
#' # function definition and merges them with any function calls for the
#' # source functions used inside the function as well:
#' outer_function = copy_dots(inner_function, function(y = "new_y_default", ...) {
#'   inner_function(y = y, ...)
#' })
#'
#' # The resulting definition of `outer_function` is equivalent to this:
#' outer_function = function(y = "new_y_default", ..., x, z = "z_default") {
#'   inner_function(y = y, ..., x = x, z = z)
#' }
#'
#' @export
merge_dots = function(...) {
  funs = list(...)
  source_funs = funs[-length(funs)]
  dest_fun = funs[[length(funs)]]

  fun_exprs = as.list(substitute(list(...))[-1])
  source_fun_names = as.character(fun_exprs[-length(fun_exprs)])
  dest_fun_expr = fun_exprs[[length(fun_exprs)]]

  # build up list of arguments from source functions -> dot_args
  dest_args = formals(dest_fun)
  dot_args = list()
  for (source_fun in source_funs) {
    source_args = formals(source_fun)
    dot_args[names(source_args)] = source_args
  }
  # remove any args that are already in the destination function
  dot_args[names(dest_args)] = NULL

  # arguments we will use for the outer function definition
  outer_args = c(dest_args, dot_args)

  # arguments we will merge into calls to nested functions
  call_arg_names = names(outer_args)[names(outer_args) != "..."]
  call_args = lapply(call_arg_names, as.name)
  names(call_args) = call_arg_names

  # recursively rewrite calls contained in the function to pass on arguments
  # that were contained in the dots explicitly
  dest_fun_expr = merge_arguments(dest_fun_expr, source_fun_names, call_args)

  # update arguments in the outer call
  dest_fun_expr[[2]] = as.pairlist(outer_args)

  # remove srcref (otherwise printing the function is confusing)
  dest_fun_expr[[4]] = NULL

  eval(dest_fun_expr, envir = parent.frame())
}

merge_arguments <- function(x, fun_names, args) {
  if (is.call(x)) {
    x_list = lapply(x, merge_arguments, fun_names, args)

    # if this is a call to one of the functions we're merging and it uses dots,
    # add on the new arguments to that function call
    if (as.character(x_list[[1]]) %in% fun_names && "..." %in% as.character(x_list[-1])) {
      new_args = args[setdiff(names(args), names(x_list[-1]))]
      x_list = c(x_list, new_args)
    }

    as.call(x_list)
  } else if (is.pairlist(x)) {
    as.pairlist(lapply(x, merge_arguments, fun_names, args))
  } else {
    x
  }
}


