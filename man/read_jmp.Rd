\name{read_jmp}
\alias{read_jmp}
\title{Read a JMP Binary Data Table}
\usage{
read_jmp(path, select = NULL, exclude = NULL, encoding = NULL,
  temporal = c("convert", "raw"), metadata = TRUE,
  max_bytes = 256 * 1024^2)
}
\arguments{
\item{path}{One path to a local JMP file.}
\item{select, exclude}{Character vectors of column names to retain or omit,
respectively. Mutually exclusive. Source column order is preserved.}
\item{encoding}{A character encoding override, or \code{NULL} to use the header.}
\item{temporal}{Convert recognized date, datetime and time display formats to
UTC \code{POSIXct}, and durations to \code{difftime}, or return raw JMP seconds.}
\item{metadata}{Attach file and column metadata attributes.}
\item{max_bytes}{Maximum input file size in bytes. Defaults to 256 MiB.}
}
\value{A \code{data.frame} preserving original column names. With
\code{metadata = TRUE}, \code{attr(result, "jmp_metadata")} describes the
file and \code{attr(result[[i]], "jmp_metadata")} describes each column.}
\description{An experimental pure R reader for JMP binary files. Handles
common numeric, fixed and variable character, pooled character, compressed,
temporal and row-state storage. Unsupported encodings raise errors.}
\details{Numeric missing sentinels become \code{NA}. Empty character strings
remain empty strings, explicit pooled missing sentinels become \code{NA}.
Date-display columns retain their time of day, using \code{POSIXct} rather
than \code{Date}. JMP's epoch is 1904-01-01. Unknown numeric display formats
remain numeric, their type bytes are preserved in metadata.

Row-state columns are list columns of raw byte vectors. Palette meanings,
hidden/excluded row flags and JSL properties are not interpreted. Column
metadata retains the raw post-header block, including its data payload,
this may substantially increase memory use. Formulas are never executed.
Use \code{metadata = FALSE} to avoid retaining raw blocks.

The full input is read into memory. The option
\code{jmpread.max_inflated_bytes} limits each declared inflated column size
(default 256 MiB). It is not a streaming decompression memory limit; this
experimental reader is not hardened against adversarial compressed files.
Embedded NULs in text are rejected because R strings cannot represent them.}
\examples{
path <- system.file("extdata", "jmpreader_jl", "example1", "example1.jmp",
                    package = "jmpread")
table <- read_jmp(path)
table[, c("ints", "floats")]
attr(table[["date"]], "jmp_metadata")$storage
read_jmp(path, select = c("ints", "char utf8"), metadata = FALSE)
}
