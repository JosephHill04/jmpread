# Compare all values against independently generated jumpio CSVs.
# Usage: Rscript compare_exports.R EXPORT_DIR JMP_FILE_OR_DIRECTORY...
# CSVs use __JMPREAD_MISSING__ for NA, raw JMP seconds for temporal values.
library(jmpread)
args <- commandArgs(TRUE)
stopifnot(length(args) >= 2)
paths <- unlist(lapply(args[-1], function(p)
  if (dir.exists(p)) list.files(p, "[.]jmp$", recursive=TRUE, full.names=TRUE) else p))
report <- lapply(paths, function(p) {
  d <- read_jmp(p, temporal="raw", metadata=FALSE)
  d <- d[, !vapply(d, is.list, FALSE), drop=FALSE]
  if (ncol(d) == 0L) return(data.frame(file=basename(p), rows=nrow(d),
    columns=0, cells=0, result="OMITTED: raw row states tested separately"))
  csv <- file.path(args[1], sub("[.]jmp$", ".csv", basename(p)))
  e <- read.csv(csv, check.names=FALSE, colClasses="character", encoding="UTF-8",
                na.strings="__JMPREAD_MISSING__", strip.white=FALSE)
  stopifnot(identical(names(d), names(e)), nrow(d) == nrow(e))
  for (i in seq_along(d)) {
    expected <- if (is.numeric(d[[i]])) as.numeric(e[[i]]) else e[[i]]
    if (!isTRUE(all.equal(d[[i]], expected, check.attributes=FALSE, tolerance=1e-12)))
      stop("Value mismatch: ", basename(p), " / ", names(d)[i])
  }
  data.frame(file=basename(p), rows=nrow(d), columns=ncol(d),
             cells=nrow(d)*ncol(d), result="PASS")
})
report <- do.call(rbind, report)
print(report, row.names=FALSE)
write.csv(report, file.path(args[1], "comparison-report.csv"), row.names=FALSE)
