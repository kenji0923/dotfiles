#!/usr/bin/env bash

set -euo pipefail

pdf_path=''
sumatra_args=()
for original_arg in "$@"; do
  if [[ "$original_arg" == /*.pdf ]]; then
    pdf_path="$original_arg"
  fi

  if [[ "$original_arg" == /* ]]; then
    sumatra_args+=("$(wslpath -w -- "$original_arg")")
  else
    sumatra_args+=("$original_arg")
  fi
done

rewrite_plain_synctex() {
  local synctex_path="$1"
  local synctex_directory
  local synctex_name
  local rewritten_path

  if ! LC_ALL=C grep -qE '/mnt/[[:alpha:]]/' "$synctex_path"; then
    return 0
  fi

  synctex_directory="$(dirname -- "$synctex_path")"
  synctex_name="$(basename -- "$synctex_path")"
  rewritten_path="$(mktemp --tmpdir="$synctex_directory" \
    ".${synctex_name}.sumatra.XXXXXX")"

  if sed -E 's@/mnt/([[:alpha:]])/@\1:/@g' \
    "$synctex_path" >"$rewritten_path"; then
    chmod --reference="$synctex_path" "$rewritten_path" 2>/dev/null || true
    mv -f -- "$rewritten_path" "$synctex_path"
  else
    rm -f -- "$rewritten_path"
    return 1
  fi
}

rewrite_gzip_synctex() {
  local synctex_path="$1"
  local synctex_directory
  local synctex_name
  local task_temp_root
  local plain_path
  local rewritten_path

  task_temp_root="${TMPDIR:-/tmp}"
  plain_path="$(mktemp "$task_temp_root/open-sumatra-synctex.XXXXXX")"
  synctex_directory="$(dirname -- "$synctex_path")"
  synctex_name="$(basename -- "$synctex_path")"
  rewritten_path="$(mktemp --tmpdir="$synctex_directory" \
    ".${synctex_name}.sumatra.XXXXXX")"

  if ! gzip -cd -- "$synctex_path" >"$plain_path"; then
    rm -f -- "$plain_path" "$rewritten_path"
    return 1
  fi

  if ! LC_ALL=C grep -qE '/mnt/[[:alpha:]]/' "$plain_path"; then
    rm -f -- "$plain_path" "$rewritten_path"
    return 0
  fi

  if sed -E 's@/mnt/([[:alpha:]])/@\1:/@g' "$plain_path" |
      gzip -c >"$rewritten_path" &&
    gzip -t -- "$rewritten_path"; then
    chmod --reference="$synctex_path" "$rewritten_path" 2>/dev/null || true
    mv -f -- "$rewritten_path" "$synctex_path"
    rm -f -- "$plain_path"
  else
    rm -f -- "$plain_path" "$rewritten_path"
    return 1
  fi
}

rewrite_synctex_for_sumatra() {
  local pdf_file="$1"
  local synctex_gzip="${pdf_file%.pdf}.synctex.gz"
  local synctex_plain="${pdf_file%.pdf}.synctex"

  if [[ -f "$synctex_gzip" ]]; then
    rewrite_gzip_synctex "$synctex_gzip"
  elif [[ -f "$synctex_plain" ]]; then
    rewrite_plain_synctex "$synctex_plain"
  fi
}

if [[ "${SUMATRA_LAUNCHER_DRY_RUN:-0}" == "1" ]]; then
  sumatra_executable="${SUMATRA_PDF_EXE:-}"
  if [[ -z "$sumatra_executable" ]]; then
    sumatra_executable="$(command -v sumatrapdf.exe || true)"
  fi
  if [[ -z "$sumatra_executable" ]]; then
    sumatra_executable='/mnt/c/Users/kshu/scoop/apps/sumatrapdf/current/SumatraPDF.exe'
  fi

  printf '%q ' "$sumatra_executable" "${sumatra_args[@]}"
  printf '\n'
  exit 0
fi

if [[ -n "$pdf_path" ]]; then
  rewrite_synctex_for_sumatra "$pdf_path"
fi

if [[ "${SUMATRA_LAUNCHER_REWRITE_ONLY:-0}" == "1" ]]; then
  exit 0
fi

sumatra_executable="${SUMATRA_PDF_EXE:-}"
if [[ -z "$sumatra_executable" ]]; then
  sumatra_executable="$(command -v sumatrapdf.exe || true)"
fi
if [[ -z "$sumatra_executable" ]]; then
  sumatra_executable='/mnt/c/Users/kshu/scoop/apps/sumatrapdf/current/SumatraPDF.exe'
fi

if [[ ! -f "$sumatra_executable" ]]; then
  printf 'SumatraPDF was not found: %s\n' "$sumatra_executable" >&2
  printf 'Set SUMATRA_PDF_EXE to its WSL path.\n' >&2
  exit 127
fi

"$sumatra_executable" "${sumatra_args[@]}" >/dev/null 2>&1 &
