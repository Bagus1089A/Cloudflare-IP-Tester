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
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

echo "==========================================================="
echo -e "${Font_SkyBlue}Nama: Uji IP Cloudflare $"
echo -e "${Font_SkyBlue}Versi: 1.0.0"
echo -e "${Font_SkyBlue}Pembuat: Bagus Adi Harsono"
echo -e "Github: https://github.com/x-dr/CloudflareSpeedTest${Font_Suffix}"
echo "==========================================================="
echo -e "${Font_Red}Cara Penggunaan: bash iptest.sh [opsi] [argumen]"
echo -e "Opsi:"
echo -e "  -f [namafile]  Tentukan file IP (default: ip.txt)"
echo -e "  -t [tasknum]   Tentukan jumlah proses (default: 30)"
echo -e "  -m [mode]      Tentukan mode (default: 1)"
echo -e "                 0: Tidak melakukan uji kecepatan"
echo -e "                 1: Melakukan uji kecepatan ${Font_Suffix}"
echo -e "==========================================================="
echo -e "${Font_Blue}Contoh: bash iptest.sh -f ip.txt -t 30 -m 1 ${Font_Suffix}"
echo -e "==========================================================="

# File IP untuk diuji (default ip.txt)
filename="ip.txt"
# Jumlah proses curl untuk pengujian (default 30, maksimal 100)
tasknum=30
# Apakah perlu melakukan uji kecepatan [(default 0. Tidak) 1. Ya]
mode=1

while getopts "f:t:m:" arg; do
  case $arg in
    f) filename=$OPTARG ;;
    t) tasknum=$OPTARG ;;
    m) mode=$OPTARG ;;
  esac
done

echo -e "${Font_Green}File IP untuk diuji:${Font_Red}$filename"
echo -e "${Font_Green}Jumlah proses curl untuk pengujian:${Font_Red}$tasknum"
echo -e "${Font_Green}Apakah perlu melakukan uji kecepatan:${Font_Red}$mode\n"

seconds=10
while [ $seconds -gt 0 ]; do
    echo -ne "${Font_Green}>> ${Font_Red}$seconds detik${Font_Suffix} ${Font_Green}sebelum mulai pengujian, tekan Ctrl+C untuk keluar dari pengujian...\r"
    sleep 1
    ((seconds--))
done

echo -e "${Font_Yellow}Hitung mundur selesai! Mulai pengujian...${Font_Suffix} "

function colocation(){
curl --ipv4 --retry 3 -s https://speed.cloudflare.com/locations | sed -e 's/},{/\n/g' -e 's/\[{//g' -e 's/}]//g' -e 's/"//g' -e 's/,/:/g' | awk -F: '{print $12","$10"-("$2")"}'>colo.txt
}

function realip(){
# Pisahkan IP dan Port dari input
IFS=':' read -r ip port <<< "$1"
sparrow=$(curl -A "trace" --resolve cf-ns.com:$port:$ip https://cf-ns.com:$port/cdn-cgi/trace -s --connect-timeout 2 --max-time 10 | grep "uag")
if [ "$sparrow" == "uag=trace" ]
then
    echo "$ip:$port" >> realip.txt
fi
}

function rtt(){
IFS=':' read -r ip port <<< "$1"
declare -i ms
curl -A "trace" --retry 2 --resolve cf-ns.com:$port:$ip https://cf-ns.com:$port/cdn-cgi/trace -s --connect-timeout 2 --max-time 3 -w "timems="%{time_connect}"\n" >> log/$ip:$port
status=$(grep uag=trace log/$ip:$port | wc -l)
if [ $status == 1 ]
then
    clientip=$(grep ip= log/$ip:$port | cut -f 2- -d'=')
    colo=$(grep colo= log/$ip:$port | cut -f 2- -d'=')
    location=$(grep $colo colo.txt | awk -F"-" '{print $1}' | awk -F"," '{print $1}')
    country=$(grep loc= log/$ip:$port | cut -f 2- -d'=')
    ms=$(grep timems= log/$ip:$port | awk -F"=" '{printf ("%d\n",$2*1000)}')
    if [[ "$clientip" == "$publicip" ]]
    then
        clientip=0.0.0.0
        ipstatus=Resmi
    elif [[ "$clientip" == "$ip" ]]
    then
        ipstatus=Transit
    else
        ipstatus=Terowongan
    fi
    rm -rf log/$ip:$port
    echo "$ip,$port,$clientip,$country,$location,$ipstatus,$ms ms" >> rtt.txt
else
    rm -rf log/$ip:$port
fi
}

function speedtest(){
IFS=':' read -r ip port <<< "$1"
rm -rf log.txt speed.txt
curl --resolve speed.cloudflare.com:$port:$ip https://speed.cloudflare.com:$port/__down?bytes=300000000 -o /dev/null --connect-timeout 2 --max-time 5 -w "HTTPCODE"_%{http_code}"\n"> log.txt 2>&1
status=$(cat log.txt | grep HTTPCODE | awk -F_ '{print $2}')
if [ $status == 200 ]
then
    cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M\|received' >> speed.txt
    for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
    do
        declare -i k
        k=$i
        k=k*1024
        echo $k >> speed.txt
    done
    for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
    do
        i=$(echo | awk '{print '$i'*10 }')
        declare -i M
        M=$i
        M=M*1024*1024/10
        echo $M >> speed.txt
    done
    declare -i max
    max=0
    for i in `cat speed.txt`
    do
        if [ $i -ge $max ]
        then
            max=$i
        fi
    done
else
    max=0
fi
rm -rf log.txt speed.txt
echo $max
}

function cloudflarerealip(){
rm -rf realip.txt
declare -i ipnum
declare -i seqnum
declare -i n=1
ipnum=$(cat $filename | wc -l)
seqnum=$tasknum
if [ $ipnum == 0 ]
then
    echo "Tidak ada IP saat ini"
fi
if [ $tasknum == 0 ]
then
    tasknum=1
fi
if [ $ipnum -lt $tasknum ]
then
    seqnum=$ipnum
fi
trap "exec 6>&-; exec 6<&-;exit 0" 2
tmp_fifofile="./$$.fifo"
mkfifo $tmp_fifofile &> /dev/null
if [ ! $? -eq 0 ]
then
    mknod $tmp_fifofile p
fi
exec 6<>$tmp_fifofile
rm -f $tmp_fifofile
for i in `seq $seqnum`;
do
    echo >&6
done
for i in `cat $filename | tr -d '\r'`
do
        read -u6;
        {
        realip $i;
        echo >&6
        }&
        echo "Total IP RTT $ipnum Sudah Selesai $n"
        n=n+1
done
wait
exec 6>&-
exec 6<&-
echo "Semua IP RTT sudah diuji"
}

function cloudflarertt(){
if [ ! -f "realip.txt" ]
then
    echo "Tidak ada REAL IP saat ini"
else
    rm -rf rtt.txt log
    mkdir log
    declare -i ipnum
    declare -i seqnum
    declare -i n=1
    ipnum=$(cat realip.txt | wc -l)
    seqnum=$tasknum
    if [ $ipnum == 0 ]
    then
        echo "Tidak ada REAL IP saat ini"
    fi
    if [ $tasknum == 0 ]
    then
        tasknum=1
    fi
    if [ $ipnum -lt $tasknum ]
    then
        seqnum=$ipnum
    fi
    trap "exec 6>&-; exec 6<&-;exit 0" 2
    tmp_fifofile="./$$.fifo"
    mkfifo $tmp_fifofile &> /dev/null
    if [ ! $? -eq 0 ]
    then
        mknod $tmp_fifofile p
    fi
    exec 6<>$tmp_fifofile
    rm -f $tmp_fifofile
    for i in `seq $seqnum`;
    do
        echo >&6
    done
    n=1
    for i in `cat realip.txt | tr -d '\r'`
    do
            read -u6;
            {
            rtt $i;
            echo >&6
            }&
            echo "Total REAL IP $ipnum Sudah Selesai $n"
            n=n+1
    done
    wait
    exec 6>&-
    exec 6<&-
    echo "Semua REAL IP sudah diuji"
fi
}

publicip=$(curl --ipv4 -s https://cf-ns.com/cdn-cgi/trace | grep ip= | cut -f 2- -d'=')

if [ ! -f "colo.txt" ]
then
    echo "Membuat colo.txt"
    colocation
else
    echo "colo.txt sudah ada, melewati langkah ini!"
fi

start=`date +%s`
echo "Mulai memeriksa validitas REAL IP dari $filename"
cloudflarerealip
echo "Mulai memeriksa informasi RTT dari $filename"
cloudflarertt
if [ ! -f "rtt.txt" ]
then
    rm -rf log realip.txt rtt.txt
    echo "Tidak ada IP yang valid saat ini"
elif [ $mode == 1 ]
then
    timestamp=$(date +%s)
    speedfile="$timestamp-$filename.csv"
    cp realip.txt realip-$timestamp.txt
    echo "IP Transit,Port Transit,IP Sumber,Negara,Pusat Data,Tipe IP,Latensi Jaringan,Bandwidth Ekuivalen,Kecepatan Puncak">"$speedfile"
    for i in `cat rtt.txt | sed -e 's/ /_/g'`
    do
        ip=$(echo $i | awk -F, '{print $1}')
        port=$(echo $i | awk -F, '{print $2}')
        clientip=$(echo $i | awk -F, '{print $3}')
        if [ $clientip != 0.0.0.0 ]
        then
            echo "Sedang menguji $ip pada port $port"
            maxspeed=$(speedtest "$ip:$port")
            maxspeed=$[$maxspeed/1024]
            maxbandwidth=$[$maxspeed/128]
            echo "$ip Bandwidth Ekuivalen $maxbandwidth Mbps Kecepatan Puncak $maxspeed kB/s"
            if [ $maxspeed == 0 ]
            then
                echo "Menguji ulang $ip pada port $port"
                maxspeed=$(speedtest "$ip:$port")
                maxspeed=$[$maxspeed/1024]
                maxbandwidth=$[$maxspeed/128]
                echo "$ip Bandwidth Ekuivalen $maxbandwidth Mbps Kecepatan Puncak $maxspeed kB/s"
            fi
        else
            echo "Melewati pengujian $ip pada port $port"
            maxspeed=null
            maxbandwidth=null
        fi
        if [ $maxspeed != 0 ]
        then
            echo "$i,$maxbandwidth Mbps,$maxspeed kB/s" | sed -e 's/_/ /g'>>"$speedfile"
        fi
    done
    rm -rf log realip.txt rtt.txt
    iconv -f UTF-8 -t GBK "$speedfile" > "$speedfile-gbk.csv"
    rm -f ./latest.csv
    cp "$speedfile" latest.csv
    echo -e "${Font_Green}File hasil uji kecepatan:${Font_Red}$speedfile"
else
    echo "IP Transit,Port Transit,IP Sumber,Negara,Pusat Data,Tipe IP,Latensi Jaringan">$(echo $filename | awk -F. '{print $1}').csv
    cat rtt.txt>>$(echo $filename | awk -F. '{print $1}').csv
    rm -rf log realip.txt rtt.txt
    echo "$(echo $filename | awk -F. '{print $1}').csv sudah dibuat"
fi
end=`date +%s`
echo -e "${Font_Green}Waktu yang dibutuhkan:$[$end-$start] detik${Font_Suffix}"
