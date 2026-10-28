library(jmpread)
fixture <- function(name) system.file("extdata", "jmpreader_jl", name,
                                      paste0(name, ".jmp"), package = "jmpread")
read <- function(name, ...) read_jmp(fixture(name), metadata = FALSE, ...)
same <- function(actual, expected) stopifnot(isTRUE(all.equal(actual, expected, check.attributes = FALSE)))
fails <- function(expr, pattern) {
  err <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(err, "error"), grepl(pattern, conditionMessage(err)))
}

# Ground truth expectations ported from jumpio/JMPReader.jl, with the
# documented lossless date-display behavior (POSIXct preserves time of day).
x <- read("example1")
same(x$ints, 1:4)
same(x$floats, c(11.1,22.2,33.3,44.4))
same(x$charconstwidth, letters[1:4])
same(x$charconstwidth2, c("a","bb","ccc","dddd"))
same(x$charvariable8, c("a","bb","cc","abcdefghijkl"))
same(x$charvariable16, c("aa","bbbb","cccccccc",strrep("abcdefghij",13)))
same(x$formula, c("2","4","6","8"))
same(x[["char utf8"]], c("\ua66e\ua66e\ua66e", "\U0001f6b4\U0001f4a8", "j\u00e4\u00e4\u00e4\u00e4r", "\u8f9b\u53e3"))
same(as.numeric(x$duration), c(2322,364,229,0))
same(x$time, as.POSIXct(c("1976-04-01 21:12:00","1984-08-06 23:58:00",
                         "2003-06-02 17:00:00",NA), tz = "UTC"))
# Avoid format guessing when checking mixed midnight/non-midnight values.
same(as.numeric(x$date), c(as.numeric(as.POSIXct("2024-01-13", tz="UTC")),
  as.numeric(as.POSIXct("2024-01-14 08:49:08", tz="UTC")), NA,
  as.numeric(as.POSIXct("2032-02-12", tz="UTC"))))
same(x$pressures, c(101.325,NA,2.6,4.63309e110))

z <- read("compressed")
stopifnot(nrow(z) == 10000, all(z$numeric == 1), all(z$character1 == "a"),
          all(z$character11 == "abcdefghijk"), all(z$character130 == strrep("abcdefghij",13)))
same(as.numeric(z[["min:s"]]), rep(196,10000))
z <- read("date")
same(z$ddmmyyyy, as.POSIXct(c("2011-05-25 21:19:01","1973-05-24 10:52:00",
  "2027-05-22 20:32:00","2020-05-01 14:23:34"), tz="UTC"))
same(as.numeric(read("duration")[[":day:hr:m:s"]]), rep(88201,3))
z <- read("time")
stopifnot(ncol(z) == 20)
for (col in z) same(col, as.POSIXct(c("1914-04-27 19:54:14","1978-01-07 06:11:24"), tz="UTC"))
z <- read("byteintegers_withmissing")
same(z[["1-byte integer"]], c(0,1,0,1,0,NA))
same(z[["2-byte integer"]], c(-187,-30,-18,13,-55,NA))
same(z[["4-byte integer"]], c(-28711,-16887,-26063,13093,-44761,NA))
z <- read("byteintegers_notcompressed")
same(z$onebyte, c(1,2,-126,127))
same(z$twobyte, c(32767,NA,0,-32766))
same(z$fourbyte, c(NA,2147483647,-2147483646,NA))
same(z$numeric, c(NA,2147483648,NA,NA))
z <- read("compact")
same(z$normalsubtype, c("aa","b","ccc","dd","dd"))
same(z$compactsubtype, z$normalsubtype)
same(z$longcompact, c(strrep("x",254),strrep("y",255),"",strrep("z",256),strrep("z",256)))
for (width in c(8,16,32)) {
  n <- switch(as.character(width), "8"=130, "16"=32770, "32"=65537)
  same(read(paste0("compact_UInt",width))$A, paste0("a",seq_len(n)))
}
same(read("geographic")$Longitude_DDD, c(151.2099,24.945831,-122.449))
stopifnot(is.na(read("geographic")$Latitude_DDD[2]))
same(read("currencies")$AUD, c(1,2,2))
same(read("currencies")$COP, c(3.14,2.78,1.41))
same(names(read("longcolumnnames")), c(paste(sprintf("%010d",1:140),collapse=""),
                                      paste(sprintf("%010d",1:280),collapse="")))
same(read("singlecolumnsinglerow")[[1]], 1)
rs <- read("rowstate")$rowstate3
stopifnot(is.list(rs), all(lengths(rs) == 8))
same(as.integer(rs[[2]][6:7]), c(20,0)) # triangle marker
same(as.integer(rs[[3]][6:7]), c(110,166)) # U+A66E

# Column filtering and metadata contracts, including zero-column results.
p <- fixture("example1")
same(names(read_jmp(p, select=c("floats","ints"))), c("ints","floats"))
stopifnot(nrow(read_jmp(p, select=character())) == 4,
          ncol(read_jmp(p, select=character())) == 0)
same(names(read_jmp(p, exclude="ints")), setdiff(names(x), "ints"))
fails(read_jmp(p, select="typo"), "Unknown column")
fails(read_jmp(p, select=c("ints","ints")), "unique")
fails(read_jmp(p, select="ints", exclude="floats"), "not both")
fails(read_jmp(p, max_bytes=1), "max_bytes")
fails(read_jmp(p, metadata=NA), "metadata")
fails(read_jmp(p, encoding="UTF-8", max_bytes=Inf), "max_bytes")
stopifnot(attr(read_jmp(p)$date,"jmp_metadata")$storage == "date",
          is.null(attr(x,"jmp_metadata")))
same(read_jmp(p, temporal="raw", metadata=FALSE)$date,
     as.numeric(x$date) + 2082844800)

# Malformed data must fail deterministically instead of guessing values.
temp <- tempfile(fileext=".jmp")
writeBin(raw(), temp); fails(read_jmp(temp), "empty")
writeBin(as.raw(1:20), temp); fails(read_jmp(temp), "magic mismatch")
bytes <- readBin(p, "raw", n=file.info(p)$size)
writeBin(bytes[1:400], temp); fails(read_jmp(temp), "truncated|not found")
m <- attr(read_jmp(p),"jmp_metadata")
bad <- bytes; off <- m$offsets[1]; name_len <- sum(as.integer(bad[off+1:2])*c(1,256))
bad[off+2+name_len+1] <- as.raw(100)
writeBin(bad,temp); fails(read_jmp(temp), "Unsupported JMP column type")
unlink(temp)

# Explicit pooled missing sentinels differ from valid empty strings.
decode_strings <- getFromNamespace(".jmp_character", "jmpread")
u <- function(n, width) as.raw(floor(n / 256^(seq_len(width)-1)) %% 256)
body <- c(raw(4), u(1,2), u(0,8), u(4,2), u(6,8), u(2,2),
          charToRaw("a"), as.raw(0), charToRaw("b"), as.raw(0),
          as.raw(c(0,1,255)))
same(decode_strings(body,body,c(2,2,0,0,1,0),3,FALSE,"UTF-8"), c("a","b",NA))
bad_pool <- body; bad_pool[length(bad_pool)] <- as.raw(2)
fails(decode_strings(bad_pool,bad_pool,c(2,2,0,0,1,0),3,FALSE,"UTF-8"), "out of range")

# Numeric all-missing and zero-row tables must retain their dimensions.
single <- fixture("singlecolumnsinglerow")
bytes <- readBin(single,"raw",n=file.info(single)$size)
find <- getFromNamespace(".jmp_find","jmpread")
header <- find(bytes,as.raw(c(7,0,8,0,0,0))) + 6 - 38
bytes[header + seq_len(8)] <- as.raw(0)
temp <- tempfile(fileext=".jmp"); writeBin(bytes,temp)
stopifnot(identical(dim(read_jmp(temp)),c(0L,1L)))
unlink(temp)

# Reject broken gzip framing and mismatched inflation sizes.
cp <- fixture("compressed")
bytes <- readBin(cp,"raw",n=file.info(cp)$size)
k <- find(bytes,as.raw(c(239,190,254,202)))
temp <- tempfile(fileext=".jmp")
bad <- bytes; bad[k + 12 + seq_len(8)] <- u(1,8)
writeBin(bad,temp); fails(read_jmp(temp),"length mismatch")
bad <- bytes; bad[k + 4 + seq_len(8)] <- u(length(bytes),8)
writeBin(bad,temp); fails(read_jmp(temp),"truncated")
unlink(temp)
cat("All fixture and regression tests passed.\n")
