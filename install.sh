#!/bin/bash
export VER="0.0"
export NOMBRECORTO="Baltazar-$VER*"
export BTZRVER="Baltazar-$VER"
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export PAQUETEDIR=$PARENT_DIR/Build/Zip/Baltazar
./1_a.sh
export BD=`cat $PARENT_DIR/Build/Zip/Build.txt`
rm $PARENT_DIR/Build/Zip/Build.txt
export NOMBREBUILD="Baltazar-$VER$BD"

if [ -e $PAQUETEDIR/devil/boot.img ]; then
	echo "Zip para instalar por recovery disponible, desea copiarlo en el movil? ( s / n )"
	read copiar
else
	echo "Kernel no compilado, revise la compilacion"
	export copiar=`n`
fi;

if [ ${copiar} == "s" ];
then
	echo
	echo "Preparando..."
	echo
	echo "Esperando por dispositivo..."
	adb 'wait-for-devices'
	echo
	echo "Dispositivo Encontrado... Continuando"
	echo
	echo "Copiando $NOMBREBUILD.zip en sdcard"
	echo
	adb push $PARENT_DIR/Build/Zip/$NOMBREBUILD.zip /sdcard/$NOMBREBUILD.zip
	echo "$NOMBREBUILD.zip copiado"

fi;

if [ -e $PAQUETEDIR/devil/boot.img ]; then
	echo
	echo "Kernel compilado, desea instalarlo en el movil? ( s / n )"
	read instalar
else
	echo "Kernel no compilado, revise la compilacion"
	export instalar=`n`
fi;

if [ ${instalar} == "s" ];
then
	echo
	echo "Preparando..."
	echo
	echo "Esperando por dispositivo..."
	adb 'wait-for-devices'
	echo "Dispositivo Encontrado... Continuando"
	echo
	echo "Flasheando $NOMBREBUILD en el Movil"
	echo
	echo "Colocando boot.img en sdcard..."
	adb push $PAQUETEDIR/devil/boot.img /sdcard/boot.img
	echo
	echo "Instalando boot.img en mmcblk0p20..."
	adb shell su -c 'dd if=/sdcard/boot.img of=/dev/block/mmcblk0p20'
	echo
	echo "Quiere instalar los modulos? ( s / n )"
	read modules
	if [ ${modules} == "s" ];
	then

	echo "Montando Sistema como RW"
	adb -d shell su -c 'mount -o remount rw /system'
	echo
	echo "Colocando modulos en Movil"
	adb -d shell rm -Rf /sdcard/modules
	adb -d shell mkdir /sdcard/modules
	adb push $PAQUETEDIR/system/lib/modules /sdcard/modules
	echo 
	echo "Moviendo modulos de /sdcard/modules a /system/lib/modules"
	adb -d shell su -c 'busybox mv -f /sdcard/modules/*.ko /system/lib/modules/'
	echo
	echo "Estableciendo permisos de modulos a RW-R-R (644)"
	adb -d shell su -c 'chmod 644 /system/lib/modules/*.ko'
	rm -f modules/*.ko

	fi;

	echo
	echo "Quieres hacer wipe cache  ? ( s / n )"
	read wipecache
	if [ ${wipecache} == "s" ];
	then
	 echo
	 echo "Eliminando dalvik-cache.."
	 adb shell su -c 'rm -Rf /data/dalvik-cache'
	 echo
	fi;
	echo "Reiniciando el movil..."
	adb reboot
fi;
