#!/usr/bin/env bash
set -Eeuo pipefail

readonly base_url="https://iauarchive.eso.org/static/public/constellations/txt"
readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly output_dir="${script_dir}/resources"

constellations=(
  And Ant Aps Aqr Aql Ara Ari Aur Boo Cae Cam Cnc CVn CMa CMi Cap Car Cas
  Cen Cep Cet Cha Cir Col Com CrA CrB Crv Crt Cru Cyg Del Dor Dra Equ Eri
  For Gem Gru Her Hor Hya Hyi Ind Lac Leo LMi Lep Lib Lup Lyn Lyr Men Mic
  Mon Mus Nor Oct Oph Ori Pav Peg Per Phe Pic Psc PsA Pup Pyx Ret Sge Sgr
  Sco Scl Sct Ser Sex Tau Tel Tri TrA Tuc UMa UMi Vel Vir Vol Vul
)

mkdir -p -- "${output_dir}"

download_file() {
  local filename="$1"
  destination="${output_dir}/${filename}"
  temporary_file="${destination}.tmp"

  printf 'Downloading %s...\n' "${filename}"
  trap 'rm -f -- "${temporary_file}"' RETURN
  curl --fail --silent --show-error --location --retry 3 \
    --output "${temporary_file}" \
    "${base_url}/${filename}"
  mv -- "${temporary_file}" "${destination}"
  trap - RETURN
}

downloaded_count=0
for constellation in "${constellations[@]}"; do
  filename="$(printf '%s' "${constellation}" | tr '[:upper:]' '[:lower:]').txt"
  if [[ "${constellation}" == "Ser" ]]; then
    download_file "ser1.txt"
    download_file "ser2.txt"
    ((downloaded_count += 2))
  else
    download_file "${filename}"
    ((downloaded_count += 1))
  fi
done

printf 'Downloaded %d constellation files to %s\n' "${downloaded_count}" "${output_dir}"
