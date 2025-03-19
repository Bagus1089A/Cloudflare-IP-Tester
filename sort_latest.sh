#!/bin/bash

Font_Black="\033[30m";
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_Purple="\033[35m";
Font_SkyBlue="\033[36m";
Font_White="\033[37m";
Font_Suffix="\033[0m";

echo "==========================================================="
echo -e "${Font_SkyBlue}Nama: Sortir File latest.csv $"
echo -e "${Font_SkyBlue}Versi: 1.0.0"
echo -e "${Font_SkyBlue}Pembuat: Bagus Adi Harsono"
echo "==========================================================="
echo -e "${Font_Red}Cara Penggunaan: bash sort_latest.sh [opsi]"
echo -e "Opsi:"
echo -e "  -c [kolom]   Tentukan kolom untuk disortir (default: 7)"
echo -e "               Kolom yang tersedia:"
echo -e "               1: IP Transit"
echo -e "               2: Port Transit"
echo -e "               3: IP Sumber"
echo -e "               4: Negara"
echo -e "               5: Pusat Data"
echo -e "               6: Tipe IP"
echo -e "               7: Latensi Jaringan (default)"
echo -e "               8: Bandwidth Ekuivalen"
echo -e "               9: Kecepatan Puncak"
echo -e "  -o [urutan]  Tentukan urutan sortir (default: ascending)"
echo -e "               ascending: Urutkan dari terkecil ke terbesar"
echo -e "               descending: Urutkan dari terbesar ke terkecil"
echo -e "==========================================================="
echo -e "${Font_Blue}Contoh: bash sort_latest.sh -c 7 -o ascending ${Font_Suffix}"
echo -e "==========================================================="

# Default nilai
column=7 # Default: Latensi Jaringan
order="ascending"

while getopts "c:o:" arg; do
  case $arg in
    c) column=$OPTARG ;;
    o) order=$OPTARG ;;
  esac
done

# Validasi input kolom
if ! [[ "$column" =~ ^[1-9]$ ]]; then
  echo -e "${Font_Red}Error: Kolom harus berupa angka antara 1 dan 9.${Font_Suffix}"
  exit 1
fi

# Validasi input urutan
if [[ "$order" != "ascending" && "$order" != "descending" ]]; then
  echo -e "${Font_Red}Error: Urutan harus 'ascending' atau 'descending'.${Font_Suffix}"
  exit 1
fi

# File input dan output
input_file="latest.csv"
output_file="sorted-latest.csv"

# Cek apakah file latest.csv ada
if [ ! -f "$input_file" ]; then
  echo -e "${Font_Red}Error: File '$input_file' tidak ditemukan.${Font_Suffix}"
  exit 1
fi

# Sorting berdasarkan kolom dan urutan
if [ "$order" == "ascending" ]; then
  sort -t, -k"$column","$column" "$input_file" > "$output_file"
else
  sort -t, -k"$column","$column" -r "$input_file" > "$output_file"
fi

echo -e "${Font_Green}File '$input_file' berhasil disortir berdasarkan kolom $column ($order).${Font_Suffix}"
echo -e "${Font_Green}Hasil disimpan di '$output_file'.${Font_Suffix}"
