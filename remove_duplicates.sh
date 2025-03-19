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
echo -e "${Font_SkyBlue}Nama: Hapus Duplikat IP:Port $"
echo -e "${Font_SkyBlue}Versi: 1.0.0"
echo -e "${Font_SkyBlue}Pembuat: Bagus Adi Harsono"
echo "==========================================================="
echo -e "${Font_Red}Cara Penggunaan: bash remove_duplicates.sh [opsi]"
echo -e "Opsi:"
echo -e "  -f [namafile]   Tentukan file input (default: ip.txt)"
echo -e "==========================================================="
echo -e "${Font_Blue}Contoh: bash remove_duplicates.sh -f ip.txt ${Font_Suffix}"
echo -e "==========================================================="

# Default nilai
input_file="ip.txt"

while getopts "f:" arg; do
  case $arg in
    f) input_file=$OPTARG ;;
  esac
done

# Cek apakah file input ada
if [ ! -f "$input_file" ]; then
  echo -e "${Font_Red}Error: File '$input_file' tidak ditemukan.${Font_Suffix}"
  exit 1
fi

# File output
output_file="unique-$input_file"

# Menghapus duplikat menggunakan awk
awk '!seen[$0]++' "$input_file" > "$output_file"

echo -e "${Font_Green}Duplikat berhasil dihapus dari file '$input_file'.${Font_Suffix}"
echo -e "${Font_Green}Hasil disimpan di '$output_file'.${Font_Suffix}"
