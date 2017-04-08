#!/bin/bash

# dependensi fortran dan grads


# data Himawari 8/9  
DIR="data_10m"
OUT="OUTPUT"

# 2km: main20 1km: main10 0.5km: main05
src="main20.f90"
exefile="tir.x"
gfortran ${src} -o ${exefile}

src="main10.f90"
exefile="vis.x"

gfortran ${src} -o ${exefile}

src="main05.f90"
exefile="ext.x"
gfortran ${src} -o ${exefile}

# 
if [ ! -f tir.x ] || [ ! -f vis.x ] || [ ! -f ext.x ];then
   echo "compilernya coba cek"
   exit
fi


# seting waktu
for YYYY in 2015 ; do      # Tahun
  for MM in 09 ; do        # Bulan
    for DD in 08 ; do      # tanggal
      for HH in 00  ; do   # jam
      for MN in 00 10 20 30 40 ;do    # 00 10 20 30 40 50 # Menit
#  tipe band
      for CHN in TIR ;do  #VIS TIR SIR EXT
      for NUM in 1;do  #2 3 4 5 6 7 8 9 10 ;do # channel
# -------------------------------------------------------
# referensi band
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

      
      echo "${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2"
      if [ ! \( -e ${DIR}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2 \) ] ; then
         echo "${DIR}/${YYYY}${MM}${DD}${HH}" >> nofiles.txt
      else
         echo "Ekstrak file"
         bzip2 -d -k ${DIR}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2  # klo mo dihapus bz2 nya -k nya di hapus
         cp ${DIR}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss .
         dd if=${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss of=little.geoss conv=swab
         para=`echo ${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss | cut -c 14-19`
	 
         echo "konversi ke tbb"
         if [ ${CHN} = "TIR" -o ${CHN} = "SIR" ];then
            ./tir.x little.geoss ${para}
            resolution="0.02"
	    	
         elif [ ${CHN} = "VIS" ];then
            ./vis.x little.geoss ${para}
            resolution="0.01"
         elif [ ${CHN} = "EXT" ];then
            dd if=little.geoss of=01.geoss bs=576000000 count=1
            ./ext.x 01.geoss ${para} && mv grid05.dat grid05_1.dat
            dd if=little.geoss of=02.geoss bs=576000000 skip=1
            ./ext.x 02.geoss ${para} && mv grid05.dat grid05_2.dat
            cat grid05_1.dat grid05_2.dat > grid05.dat 
            resolution="0.005"
         fi
         rm *.geoss

#cp grid20.dat  ${OUT}/
		 mv ${OUT}/grid??.dat  ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.dat

		 echo dset ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.dat > ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo title HIMAWARI-8 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo options yrev little_endian >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo undef -999.0 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo xdef 6000 linear 85.01  0.02 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo ydef 6000 linear -59.99 0.02 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo zdef 1 linear 1 1 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo tdef 1 linear 01JUN05  1hr >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo vars 1 >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo "tbb 0 99 brightness temperature [K]" >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl
		 echo endvars >> ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl

		 echo "#!/usr/bin/grads" > ke_nc.gs
		 echo "'open ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.ctl'" > ke_nc.gs
		 echo "'set lat -15 15'" >> ke_nc.gs  # indonesia
		 echo "'set lon 90 150'" >> ke_nc.gs
	 	 echo "'define suhu=tbb'" >> ke_nc.gs
		 echo "'set sdfwrite ${OUT}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.nc'" >> ke_nc.gs
		 echo "'sdfwrite suhu'" >> ke_nc.gs

		 grads -lbxc ke_nc.gs

         fi 
      done
      done
      done
      done
    done
  done
done
