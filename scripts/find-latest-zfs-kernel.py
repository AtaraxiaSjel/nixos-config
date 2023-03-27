#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3

import sys
import re

if __name__ == "__main__":
    file = sys.argv[1]
    results = []
    with open(file, "r") as lines:
        for line in lines:
            if "kernel.kernelOlder" in line:
                results.append(line)
                break
    line = results[0].strip()
    pattern = re.compile(r"\d\.\d{1,2}")
    version = pattern.search(line).group(0)
    major, minor = version.split('.')
    minor = int(minor) - 1
    version = f"{major}.{minor}"
    print(version)