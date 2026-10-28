#' Read a JMP binary table
#'
#' @param path Path to a local JMP file.
#' @param select,exclude Character column names to include or exclude, mutually
#'   exclusive. Columns retain their order in the source table.
#' @param encoding Override the declared character encoding, or NULL.
#' @param temporal "convert" for UTC POSIXct dates/times and difftime durations,
#'   "raw" for the original seconds since 1904-01-01.
#' @param metadata Attach source metadata to the result and each column.
#' @param max_bytes Maximum input size, in bytes. Defaults to 256 MiB.
#' @return A data.frame with original column names and optional jmp_metadata.
#' @export
read_jmp <- function(path, select = NULL, exclude = NULL, encoding = NULL,
                     temporal = c("convert", "raw"), metadata = TRUE,
                     max_bytes = 256 * 1024^2) {
  temporal <- match.arg(temporal)
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path))
    .jmp_error("'path' must be one non-empty file path.")
  if (!is.null(encoding) && (!is.character(encoding) || length(encoding) != 1L ||
                            is.na(encoding) || !nzchar(encoding)))
    .jmp_error("'encoding' must be NULL or one non-empty encoding name.")
  if (!is.logical(metadata) || length(metadata) != 1L || is.na(metadata))
    .jmp_error("'metadata' must be TRUE or FALSE.")
  if (!is.numeric(max_bytes) || length(max_bytes) != 1L ||
      !is.finite(max_bytes) || max_bytes <= 0)
    .jmp_error("'max_bytes' must be one positive finite number.")
  info <- file.info(path)
  if (is.na(info$size) || isTRUE(info$isdir)) .jmp_error("JMP file does not exist or is not a file.")
  if (info$size == 0) .jmp_error("JMP file is empty.")
  if (info$size > max_bytes) .jmp_error("JMP file exceeds 'max_bytes'.")
  con <- file(path, "rb"); on.exit(close(con), add = TRUE)
  x <- readBin(con, "raw", n = info$size)
  if (length(x) != info$size) .jmp_error("Could not read the entire JMP file.")
  meta <- .jmp_metadata(x, encoding)
  if (!is.null(select) && !is.null(exclude)) .jmp_error("Supply 'select' or 'exclude', not both.")
  for (arg in c("select", "exclude")) {
    value <- get(arg)
    if (!is.null(value) && (!is.character(value) || anyNA(value) || anyDuplicated(value)))
      .jmp_error(paste0("'", arg, "' must contain unique, non-missing column names."))
    if (any(!value %in% meta$column_names))
      .jmp_error(paste0("Unknown column in '", arg, "': ", paste(setdiff(value, meta$column_names), collapse = ", ")))
  }
  keep <- seq_len(meta$ncols)
  if (!is.null(select)) keep <- keep[meta$column_names %in% select]
  if (!is.null(exclude)) keep <- keep[!meta$column_names %in% exclude]
  ends <- c(meta$offsets[-1], length(x))
  columns <- lapply(keep, function(i) {
    result <- tryCatch(.jmp_column(.jmp_slice(x, meta$offsets[i], ends[i] - meta$offsets[i]),
                                  meta$nrows, meta$encoding, temporal),
      error = function(e) .jmp_error(sprintf("Column '%s': %s", meta$column_names[i], conditionMessage(e))))
    if (metadata) {
      result$metadata$display_width <- meta$display_widths[i]
      attr(result$values, "jmp_metadata") <- result$metadata
    }
    result$values
  })
  names(columns) <- meta$column_names[keep]
  # Direct construction preserves arbitrary and duplicate JMP column names,
  # list columns, zero rows, and zero selected columns.
  attr(columns, "row.names") <- if (meta$nrows) c(NA_integer_, -as.integer(meta$nrows)) else integer()
  class(columns) <- "data.frame"
  if (metadata) {
    meta$selected <- keep
    meta$source <- normalizePath(path, winslash = "/", mustWork = TRUE)
    attr(columns, "jmp_metadata") <- meta
  }
  columns
}
