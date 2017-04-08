#!/bin/bash
# Himawari-8/9
# dependensi wget 


# link websitenya
FTP="ftp://hmwr829gr.cr.chiba-u.ac.jp/gridded/FD/V20151105"
DIR="data_10m"
# Set Tanggal
for YYYY in 2015 ; do      #  tahun bila banyak {YYYY..YYYY} dari..sampai
  for MM in 09 ; do        # bulan  {MM..MM}
    for DD in 08 ; do      # tanggal  {dd..dd}
      for HH in {00..02} ; do   # jam {hh..hh}
      	for MN in 00 10 20 30 40 50  ;do    # 00 10 20 30 40 50 # menit
# Set band 
      	for CHN in TIR ;do  #VIS TIR SIR EXT pilih (sesuai keinginan)  
      		for NUM in 1;do  #2 3 4 5 6 7 8 9 10 ;do # channel band terpilih sbb dibawah
# -------------------------------------------------------
# [EXT] 01:Band03 
# [VIS] 01:Band01 02:Band02 03:Band04
# [SIR] 01:Band05 02:Band06
# [TIR] 01:Band13 02:Band14 03:Band15 04:Band16 05:Band07
#       06:Band08 07:Band09 08:Band10 09:Band11 10:Band12
# -------------------------------------------------------

       			if [ ${CHN} = "VIS" ] && [ ${NUM} -gt 3 ];then
          			break
       			elif [ ${CHN} = "SIR" ] && [ ${NUM} -gt 2 ]; then
          			break
       			elif [ ${CHN} = "EXT" ] && [ ${NUM} -gt 1 ]; then
          			break
       			fi
       			if [ ${NUM} -lt 10 ];then
          			NUM=0${NUM}
       			fi

      			echo "Download file"
       			echo "${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2"
       			cd ${DIR}
       			wget  -c ${FTP}/${YYYY}${MM}/${CHN}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2 
      		done
      	 done
      	done
      done
    done
  done
done
