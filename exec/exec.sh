#!/bin/bash

#--- 現在の日付を取得
current_date=$(date +'%Y-%m-%d')

#--- 実行環境における文字のエンコーディング: utf-8, shift-jis
encd="shift-jis"

#--- 観測項目を指定: Precipitation, WindSpeed, Temperature, Sunshine, Snow
obs_type="Precipitation"

#--- 入出力ファイルを指定
ifile="../meta_data/amdmaster.index4.txt"
ofile="../csv/${obs_type}_connected_list.csv"
log_file="../log/log_${obs_type}_connected_list_${current_date}.txt"

#--- fortranのソースコードを指定
src_file="../src/connected_list.f90"

#--- コンパイラを指定: gfortran, ifort
cmp="ifort"

if [ "$cmp" = "ifort" ]; then
	ifort -o connected_list.exe $src_file
elif [ "$cmp" = "gfortran" ]; then
	gfortran -o connected_list.exe $src_file
else
	echo "Wrong compiler: $cmp"
	echo "Use ifort of gfortran"
	exit
fi

#--- fortranプログラムの実行
./connected_list.exe <<EOF
&nam
    obs_type="$obs_type", ifile="$ifile", ofile="$ofile", log_file="$log_file"
&end
EOF


if [ -f "$ofile" ] && [ -f "$log_file" ]; then
	if [ "$encd" = "utf-8" ]; then
		iconv -f shift-jis -t $encd $ofile -o ofile.csv
		iconv -f shift-jis -t $encd $log_file -o log.txt
		mv ofile.csv $ofile
		mv log.txt $log_file
	fi
else
	echo "NOT Found output file"
	exit
fi


rm connected_list.exe
