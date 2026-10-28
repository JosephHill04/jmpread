# Encodings and display-format classifications adapted from jumpio (MIT).
.jmp_flavor <- function(a, b) {
  pair <- paste(a, b, sep = ":")
  if ((a == b && a %in% c(0,3,66:68,89,96,99,95,81:86)) || b %in% c(94,99))
    return("numeric")
  if ((a == b && a %in% c(101:103,110:114,117,118,122,127,136,139)) ||
      pair %in% c("103:101","111:101","114:101","114:111","114:127",
                   "114:128","127:114","136:101","136:122")) return("date")
  if ((b %in% c(105,106,115,116,119,120,126,129) &&
       a %in% c(105,106,108,109,115,116,119:121,123:126,128:130,134:138)) ||
      (a == b && a %in% c(121,125)) ||
      pair %in% c("119:128","119:127","137:101")) return("datetime")
  if (a == 130 && b == 130) return("time")
  if ((a == b && a %in% c(12,107:109,131:133)) || pair == "132:121")
    return("duration")
  "numeric"
}

.jmp_trailing <- function(x, n) .jmp_slice(x, length(x) - n, n)

.jmp_strings <- function(data, widths, encoding) {
  if (any(!is.finite(widths) | widths < 0)) .jmp_error("Invalid JMP string lengths.")
  payload <- .jmp_trailing(data, sum(widths))
  ends <- cumsum(widths)
  vapply(seq_along(widths), function(i)
    .jmp_text(.jmp_slice(payload, ends[i] - widths[i], widths[i]), encoding), "")
}

.jmp_character <- function(body, data, t, nr, compressed, encoding) {
  w <- t[5]
  pooled <- t[3] == 0 && t[4] == 0 && w %in% c(1,2,4) &&
    length(body) >= 26 && all(body[1:4] == as.raw(0)) &&
    .jmp_uint(body, 4, 2) != 0 && .jmp_uint(body, 14, 2) == 4
  if (pooled) {
    size <- .jmp_uint(body, 16, 8)
    count <- .jmp_uint(body, 24, 2)
    pooldata <- .jmp_slice(body, 26, size - 2)
    pool <- character(count); p <- 0
    for (i in seq_len(count)) {
      end <- .jmp_find(pooldata, as.raw(0), p)
      if (is.na(end)) .jmp_error("Unterminated JMP pool entry.")
      pool[i] <- .jmp_text(.jmp_slice(pooldata, p, end - p), encoding)
      p <- end + 1
    }
    indices <- .jmp_ints(.jmp_trailing(data, nr * w), 0, nr, w, FALSE)
    missing <- indices == 2^(8 * w) - 1
    if (any(indices[!missing] >= count)) .jmp_error("JMP pool index out of range.")
    result <- rep(NA_character_, nr)
    result[!missing] <- pool[indices[!missing] + 1]
    return(result)
  }
  constant <- (t[3] == 0 && t[4] == 0 && w > 0) ||
    (t[3] %in% 1:7 && t[4] == 0 && w > 0)
  if (constant) {
    payload <- .jmp_trailing(data, nr * w)
    return(vapply(seq_len(nr), function(i)
      .jmp_text(.jmp_trim_null(.jmp_slice(payload, (i - 1) * w, w)), encoding), ""))
  }
  if (any(t[3:5] != 0)) .jmp_error("Unsupported JMP character encoding.")
  if (compressed && length(data) >= 8 && .jmp_uint(data, 0, 8) == length(data)) {
    iw <- .jmp_uint(data, 25, 1)
    idx <- .jmp_ints(data, 26, nr, iw, FALSE)
    p <- 26 + nr * iw
    lw <- .jmp_uint(data, p, 1); p <- p + 1
    if (!lw %in% c(1,2)) .jmp_error("Unsupported JMP pool length width.")
    count <- if (length(idx)) max(idx) else 0
    if (count > length(data)) .jmp_error("Implausible JMP pool size.")
    pool <- character(count)
    for (i in seq_len(count)) {
      s <- .jmp_string(data, p, lw, encoding); pool[i] <- s$value; p <- s$end
    }
    return(c("", pool)[idx + 1])
  }
  if (compressed) {
    wb <- .jmp_uint(data, 8, 1); p <- 13
    widths <- .jmp_ints(data, p, nr, wb)
    payload <- .jmp_slice(data, p + nr * wb, length(data) - p - nr * wb)
    if (sum(widths) != length(payload)) .jmp_error("JMP string payload length mismatch.")
    return(.jmp_strings(payload, widths, encoding))
  }
  p <- 6
  n1 <- .jmp_uint(body, p, 8); p <- p + 8 + n1 + 2
  n2 <- .jmp_uint(body, p, 4); p <- p + 4 + n2 + 8
  wb <- .jmp_uint(body, p, 1)
  widths <- .jmp_ints(body, p + 5, nr, wb)
  if (p + 5 + nr * wb + sum(widths) > length(body))
    .jmp_error("Truncated JMP variable-width strings.")
  .jmp_strings(data, widths, encoding)
}

.jmp_column <- function(block, nr, encoding, temporal) {
  name <- .jmp_string(block, 0, 2, encoding)
  t <- as.integer(.jmp_slice(block, name$end, 6))
  body <- .jmp_slice(block, name$end + 6, length(block) - name$end - 6)
  compressed <- t[1] %in% c(9,10)
  data <- block
  if (compressed) {
    k <- .jmp_find(body, as.raw(c(239,190,254,202)))
    if (is.na(k)) .jmp_error("Missing JMP gzip marker.")
    gzlen <- .jmp_uint(body, k + 4, 8)
    unlen <- .jmp_uint(body, k + 12, 8)
    stream <- .jmp_slice(body, k + 20, gzlen)
    if (length(stream) < 18 || !identical(stream[1:3], as.raw(c(31,139,8))))
      .jmp_error("Invalid JMP gzip stream.")
    # Guard before inflation, memDecompress cannot cap output while inflating.
    if (unlen > getOption("jmpread.max_inflated_bytes", 256 * 1024^2))
      .jmp_error("JMP inflated column exceeds 'jmpread.max_inflated_bytes'.")
    data <- tryCatch(memDecompress(stream, type = "gzip"),
                     error = function(e) .jmp_error("JMP gzip decompression failed."))
    if (length(data) != unlen) .jmp_error("JMP decompressed length mismatch.")
  }
  flavor <- "numeric"
  if (t[1] %in% c(1,10,255,254,252)) {
    w <- if (t[1] %in% c(255,254,252)) t[5] else if (t[6] %in% c(1,2,4)) t[6] else 8
    bytes <- .jmp_trailing(data, nr * w)
    if (w == 8) {
      values <- .jmp_doubles(bytes, 0, nr)
      values[is.nan(values)] <- NA_real_
      flavor <- .jmp_flavor(t[4], t[5])
      if (temporal == "convert" && flavor %in% c("date","datetime","time"))
        values <- structure(values + .jmp_epoch, class = c("POSIXct","POSIXt"), tzone = "UTC")
      if (temporal == "convert" && flavor == "duration")
        values <- as.difftime(values, units = "secs")
    } else {
      values <- .jmp_ints(bytes, 0, nr, w)
      values[values == -2^(8 * w - 1) + 1] <- NA_real_
      # Keep int32 minimum as a double: R reserves that bit pattern for NA.
      if (!any(values == -2147483648, na.rm = TRUE)) values <- as.integer(values)
      flavor <- paste0("int", w * 8)
    }
  } else if (t[1] %in% c(2,9) && t[2] %in% c(1,2)) {
    values <- .jmp_character(body, data, t, nr, compressed, encoding)
    flavor <- "character"
  } else if (t[1] %in% c(3,9) && t[2] == 3) {
    if (t[5] < 7) .jmp_error("Invalid JMP row-state width.")
    bytes <- .jmp_trailing(data, nr * t[5])
    # Preserve raw states and indices, do not guess unknown palette meanings.
    values <- lapply(seq_len(nr), function(i) .jmp_slice(bytes, (i-1) * t[5], t[5]))
    flavor <- "rowstate"
  } else .jmp_error(paste("Unsupported JMP column type bytes:", paste(t, collapse = ",")))
  if (length(values) != nr) .jmp_error("Decoded JMP row count mismatch.")
  list(values = values, metadata = list(name = name$value, type_bytes = t,
       storage = flavor, compressed = compressed,
       raw_metadata = body))
}
