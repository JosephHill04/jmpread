# Validate an actual JMP CSV export without automatic type guessing.
# Usage: Rscript validate_jmp_export.R TABLE.jmp TRUSTED.csv
# Export all rows, columns in source order, and numeric values at full precision.
# For this initial validator, temporal and row-state columns require a separate
# normalization agreement and are deliberately rejected.
library(jmpread)
args <- commandArgs(TRUE)
stopifnot(length(args) == 2)
d <- read_jmp(args[1])
flavors <- vapply(d, function(x) attr(x,"jmp_metadata")$storage, "")
if (any(flavors %in% c("date","datetime","time","duration","rowstate")))
  stop("Normalize temporal/row-state exports explicitly before comparing.")
e <- read.csv(args[2], check.names=FALSE, colClasses="character",
              encoding="UTF-8", na.strings=character())
stopifnot(identical(names(d),names(e)), nrow(d) == nrow(e))
for (i in seq_along(d)) {
  actual <- d[[i]]; attributes(actual) <- NULL
  expected <- e[[i]]
  if (is.numeric(actual)) {
    missing <- expected %in% c("", ".")
    converted <- suppressWarnings(as.numeric(expected))
    if (any(is.na(converted) & !missing)) stop("Invalid numeric export in ", names(d)[i])
    expected <- converted
  }
  if (!isTRUE(all.equal(actual,expected,check.attributes=FALSE,tolerance=1e-12)))
    stop("Value mismatch in ",names(d)[i])
}
cat("PASS: all column names, dimensions, missing values and cells agree.\n")
