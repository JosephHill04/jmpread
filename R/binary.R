# Binary layout adapted from jumpio (MIT), see inst/COPYRIGHTS.
.jmp_error <- function(message) stop(message, call. = FALSE)

# All positions are zero-based byte offsets. Every read checks its bounds.
.jmp_slice <- function(x, pos, n) {
  if (length(pos) != 1L || length(n) != 1L || !is.finite(pos) ||
      !is.finite(n) || pos < 0 || n < 0 || pos != floor(pos) ||
      n != floor(n) || pos + n > length(x))
    .jmp_error(sprintf("Invalid or truncated JMP data at byte %s (length %s).", pos, n))
  if (!n) return(raw())
  x[seq.int(pos + 1, length.out = n)]
}

.jmp_uint <- function(x, pos, width) {
  b <- as.numeric(.jmp_slice(x, pos, width))
  if (!width %in% c(1, 2, 4, 8)) .jmp_error("Unsupported integer width.")
  # R doubles exactly represent integers only up to 2^53 - 1.
  if (width == 8 && (b[8] != 0 || b[7] > 31))
    .jmp_error("64-bit size or offset exceeds R's exact integer range.")
  sum(b * 256^(seq_len(width) - 1))
}

.jmp_ints <- function(x, pos, n, width, signed = TRUE) {
  if (!width %in% c(1, 2, 4)) .jmp_error("Unsupported integer width.")
  z <- .jmp_slice(x, pos, n * width)
  if (!n) return(numeric())
  m <- matrix(as.numeric(z), nrow = width)
  out <- as.numeric(crossprod(256^(seq_len(width) - 1), m))
  if (signed) out[out >= 2^(8 * width - 1)] <-
    out[out >= 2^(8 * width - 1)] - 2^(8 * width)
  out
}

.jmp_doubles <- function(x, pos, n) {
  z <- .jmp_slice(x, pos, n * 8)
  readBin(z, double(), n = n, size = 8L, endian = "little")
}

.jmp_find <- function(x, pattern, start = 0) {
  if (start + length(pattern) > length(x)) return(NA_real_)
  candidates <- which(x[seq.int(start + 1, length(x))] == pattern[1]) + start - 1
  candidates <- candidates[candidates + length(pattern) <= length(x)]
  for (p in candidates) {
    if (identical(.jmp_slice(x, p, length(pattern)), pattern)) return(p)
  }
  NA_real_
}

.jmp_text <- function(x, encoding) {
  if (!length(x)) return("")
  # R character vectors cannot represent embedded NULs.
  if (any(x == as.raw(0))) .jmp_error("Embedded NUL in a JMP string is unsupported.")
  result <- iconv(rawToChar(x), from = encoding, to = "UTF-8", sub = NA)
  if (is.na(result)) .jmp_error(sprintf("Invalid text for encoding '%s'.", encoding))
  result
}

.jmp_trim_null <- function(x) {
  k <- which(x != as.raw(0))
  if (!length(k)) raw() else x[seq_len(max(k))]
}

.jmp_string <- function(x, pos, width, encoding = "UTF-8") {
  n <- .jmp_ints(x, pos, 1, width)
  list(value = .jmp_text(.jmp_slice(x, pos + width, n), encoding),
       end = pos + width + n)
}

.jmp_magic <- as.raw(c(255,255,0,0,7,0,0,0,4,0,0,0,1,0,1,0,2,0))
.jmp_epoch <- -2082844800 # 1904-01-01 UTC relative to the Unix epoch

.jmp_metadata <- function(x, encoding) {
  if (length(x) < 18 || !identical(x[1:18], .jmp_magic))
    .jmp_error("Not a supported JMP file (magic mismatch).")
  anchor <- .jmp_find(x, as.raw(c(7,0,8,0,0,0)))
  if (is.na(anchor)) .jmp_error("JMP structured header was not found.")
  p <- anchor + 6 - 38
  nr <- .jmp_uint(x, p, 8)
  nc <- .jmp_uint(x, p + 8, 4)
  if (nr > .Machine$integer.max || nc > floor(length(x) / 8))
    .jmp_error("Implausible JMP dimensions or table too large for this reader.")
  slen <- .jmp_ints(x, p + 22, 1, 4)
  charset <- .jmp_text(.jmp_trim_null(.jmp_slice(x, p + 26, slen)), "UTF-8")
  p <- p + 26 + slen + 6
  saved <- .jmp_doubles(x, p, 1)
  build <- .jmp_string(x, p + 10, 4)$value
  if (is.null(encoding)) encoding <- charset
  if (!nzchar(encoding) || is.na(iconv("test", from = encoding, to = "UTF-8")))
    .jmp_error("Unsupported JMP character encoding; supply 'encoding' explicitly.")
  p <- 2
  found <- FALSE
  for (attempt in seq_len(100000L)) {
    k <- .jmp_find(x, as.raw(c(255,255)), p)
    if (is.na(k)) break
    p <- k + 2
    while (p < length(x) && x[p + 1] == as.raw(255)) p <- p + 1
    if (p + 26 > length(x)) break
    nv <- .jmp_uint(x, p + 10, 4)
    nh <- .jmp_uint(x, p + 14, 4)
    if (nv + nh == nc) { found <- TRUE; p <- p + 26; break }
    p <- p + 8
  }
  if (!found) .jmp_error("JMP column-offsets section was not found.")
  visible <- .jmp_ints(x, p, nv, 4, FALSE); p <- p + 4 * nv
  hidden <- .jmp_ints(x, p, nh, 4, FALSE); p <- p + 4 * nh
  widths <- .jmp_ints(x, p, nc, 2, FALSE); p <- p + 2 * nc
  repeat {
    tag <- .jmp_uint(x, p, 2)
    if (!tag %in% 65532:65535) break
    n <- .jmp_uint(x, p + 2, 8)
    .jmp_slice(x, p + 10, n)
    p <- p + 10 + n
  }
  if (.jmp_uint(x, p, 4) != nc) .jmp_error("JMP column count mismatch.")
  p <- p + 4
  offsets <- vapply(seq_len(nc), function(i) .jmp_uint(x, p + (i - 1) * 8, 8), 0)
  if (any(offsets < p + 8 * nc) || any(offsets >= length(x)) ||
      is.unsorted(offsets, strictly = TRUE)) .jmp_error("Invalid JMP column offsets.")
  names <- vapply(offsets, function(off) .jmp_string(x, off, 2, encoding)$value, "")
  list(nrows = nr, ncols = nc, charset = charset, encoding = encoding,
       saved = structure(saved + .jmp_epoch, class = c("POSIXct", "POSIXt"), tzone = "UTC"),
       build = build, column_names = names, offsets = offsets,
       display_widths = widths, visible = visible, hidden = hidden)
}
