"""Generate comparison CSVs using a pinned, separate jumpio checkout.

Usage: python reference_exports.py REFERENCE_REPO OUTPUT_DIR FILE_OR_DIR...
These are differential reference results, NOT trusted JMP application exports.
Temporal values are normalized to raw JMP seconds; row states are omitted.
"""
import csv
import datetime as dt
from pathlib import Path
import sys

repo, output, *inputs = map(Path, sys.argv[1:])
sys.path.insert(0, str(repo / "src"))
from jumpio import read_jmp

output.mkdir(parents=True, exist_ok=True)
paths = []
for item in inputs:
    paths.extend(sorted(item.rglob("*.jmp")) if item.is_dir() else [item])
for path in paths:
    table = read_jmp(path)
    names = [name for name in table.columns if table.column(name).dtype != "rowstate"]
    def normalize(value):
        if value is None:
            return "__JMPREAD_MISSING__"
        if isinstance(value, dt.datetime):
            return (value - dt.datetime(1904, 1, 1)).total_seconds()
        if isinstance(value, dt.timedelta):
            return value.total_seconds()
        return value
    with (output / (path.stem + ".csv")).open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(names)
        for i in range(len(table)):
            writer.writerow([normalize(table[name][i]) for name in names])
    print(f"{path.name}: {len(table)} rows, {len(names)} comparable columns")
