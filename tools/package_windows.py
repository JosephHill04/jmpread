"""Zip an R-installed pure-R package, preserving its required top-level folder.

Usage: python package_windows.py INSTALLED_PACKAGE_DIRECTORY OUTPUT.zip
R must first install the built source archive on Windows (including Built and
MD5 metadata). This helper replaces an unavailable system zip executable.
"""
from pathlib import Path
import sys
from zipfile import ZipFile, ZIP_DEFLATED

package = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
if not (package / "Meta" / "package.rds").is_file():
    raise SystemExit("Expected an installed R package, not a source directory")
with ZipFile(output, "w", ZIP_DEFLATED) as archive:
    for path in sorted(package.rglob("*")):
        if path.is_file():
            archive.write(path, path.relative_to(package.parent))
print(output)
