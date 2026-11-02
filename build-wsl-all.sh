#!/usr/bin/env bash
# Build every wsl-* build preset whose compiler is installed.
# Usage: ./build-wsl-all.sh [name-filter-regex]   e.g. ./build-wsl-all.sh 'gcc-1[12]'
set -uo pipefail
cd "$(dirname "$0")"
filter="${1:-.}"

ok=(); fail=(); skip=()
for p in $(cmake --list-presets=build | grep -oE '"wsl-[^"]+"' | tr -d '"' | grep -E "$filter"); do
  # wsl-gcc-12-release -> g++-12 ; wsl-clang-release -> clang++
  if [[ $p =~ ^wsl-(gcc|clang)(-([0-9]+))?- ]]; then
    cxx=$([[ ${BASH_REMATCH[1]} == gcc ]] && echo g++ || echo clang++)
    cxx="$cxx${BASH_REMATCH[2]}"
  fi
  if ! command -v "$cxx" >/dev/null; then skip+=("$p ($cxx missing)"); continue; fi

  # Multi-config build presets (wsl-gcc-12-release) share the configure preset wsl-gcc-12
  cfg="${p%-*}"
  cmake --list-presets=configure | grep -q "\"$cfg\"" || cfg="$p"
  cmake --preset "$cfg" >/dev/null || { fail+=("$p"); continue; }
  echo "=== $p"
  if cmake --build --preset "$p"; then ok+=("$p"); else fail+=("$p"); fi
done

echo; echo "OK:   ${ok[*]:-}"
echo "SKIP: ${skip[*]:-}"
echo "FAIL: ${fail[*]:-}"
[[ ${#fail[@]} -eq 0 ]]
