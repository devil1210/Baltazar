#!/bin/sh
export VER="0.0"
export NOMBRECORTO="Baltazar-$VER*"
export BTZRVER="Baltazar-$VER"
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export INITRAMFS_DEST=$KERNELDIR/kernel/usr/initramfs
export INITRAMFS_SOURCE=`readlink -f ..`/Build/Ramdisks
export PAQUETEDIR=$PARENT_DIR/Build/Zip/Baltazar
export SCRIPT=$PARENT_DIR/Build/Zip/META-INF/com/google/android
#Enable FIPS mode
export USE_SEC_FIPS_MODE=true
export ARCH=arm
export CROSS_COMPILE=$PARENT_DIR/toolchains/arm-eabi-4.7/bin/arm-eabi-

inicio=$(date +%s.%N)

echo "Eliminando Archivos de Paquetes Antiguos"
rm -rf $PAQUETEDIR/*

echo "Configurando Directorio del Paquete"
mkdir -p $PAQUETEDIR/system/lib/modules
mkdir -p $PAQUETEDIR/system/etc/init.d
mkdir -p $PAQUETEDIR/devil

echo "Creando Directorio Initramfs"
mkdir -p $INITRAMFS_DEST

echo "Eliminando Directorio Initramfs Antiguo"
rm -rf $INITRAMFS_DEST/*

echo "Copiando Nuevo Directorio Initramfs"
cp -R $INITRAMFS_SOURCE/* $INITRAMFS_DEST

echo "chmod Directorio Initramfs"
chmod -R g-w $INITRAMFS_DEST/*

echo "Eliminando zImage Antiguo"
if [ -e $PAQUETEDIR/zImage ]; then
rm $PAQUETEDIR/zImage
fi;
if [ -e arch/arm/boot/zImage ]; then
rm arch/arm/boot/zImage
fi;

echo "Construyendo Kernel"
make VARIANT_DEFCONFIG=ek_defconfig jf_eur_defconfig jf_defconfig SELINUX_DEFCONFIG=selinux_defconfig

echo "Configurando Archivo .config de "$BTZRVER
sed -i 's,CONFIG_LOCALVERSION="-Baltazar",CONFIG_LOCALVERSION="'-$BTZRVER'",' .config

HOST_CHECK=`uname -n`
echo "devil@"$HOST_CHECK
make -j`grep 'processor' /proc/cpuinfo | wc -l`

echo "Copiando modulos al Paquete"
cp -a $(find . -name *.ko -print |grep -v initramfs) $PAQUETEDIR/system/lib/modules/

./1_a.sh

export BD=`cat $PARENT_DIR/Build/Zip/Build.txt`
rm $PARENT_DIR/Build/Zip/Build.txt
export NOMBREBUILD="Baltazar-$VER$BD"

echo "Editando nombre de Kernel en updater-script"
sed -i 's,ui_print("Baltazar");,ui_print("Instalando Kernel '$NOMBREBUILD'");,' $SCRIPT/updater-script

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	echo "Copiando zImage al Paquete"
	cp arch/arm/boot/zImage $PAQUETEDIR/zImage

	echo "Haciendo ramdisk.gz"
	./mkbootfs $INITRAMFS_DEST | gzip > $PAQUETEDIR/ramdisk.gz
	echo "Haciendo boot.img"
	./mkbootimg --cmdline 'console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 maxcpus=4' --kernel $PAQUETEDIR/zImage --ramdisk $PAQUETEDIR/ramdisk.gz --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x02000000 --output $PAQUETEDIR/devil/boot.img 
	cd $PAQUETEDIR
	cp -R ../META-INF .
	rm ramdisk.gz
	rm zImage
	rm ../$NOMBRECORTO.zip
	zip -r ../$NOMBREBUILD.zip .

	final=$(date +%s.%N)
	echo "${BLDYLW}Total tiempo transcurrido: ${TCTCLR}${TXTGRN}$(echo "($final - $inicio) / 60"|bc ) ${TXTYLW}minutos${TXTGRN} ($(echo "$final - $inicio"|bc ) ${TXTYLW}segundos) ${TXTCLR}"

	NOMBRE=../$NOMBREBUILD.zip
	TAMANO=$(stat -c%s "$NOMBRE")
	echo "Tamaño de $NOMBRE = $TAMANO bytes."
	rm ../"version.txt"
	exec >>../"version.txt" 2>&1
	echo "$NOMBREBUILD, $TAMANO"
	cd $KERNELDIR
else
	echo "KERNEL NO CONSTRUIDO! no existe zImage"
fi;

sed -i 's,ui_print("Instalando Kernel '$NOMBREBUILD'");,ui_print("Baltazar");,' $SCRIPT/updater-script
