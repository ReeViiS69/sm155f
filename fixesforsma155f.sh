#!/bin/bash
#get kerneldir ready
STARTPATH=$(pwd)
[ ! -f ./certificate.pem ] && openssl req -new -x509 -newkey rsa:4096 -keyout private_key.pk8 -out certificate.pem -days 824 -nodes -sha256 -config samsung_cert.conf
[ -d ./maggi ] && rm -rf ./maggi/
mkdir ./maggi
cd maggi
../github.com-topjohnwu/x86_64/magiskboot unpack ../samsungbootimg/boot.img
rm kernel
#do stupid fix for error in build sh at line 909 missing a space infront of the last "]"
sed -i 's/!= "1"\]; then/!= "1" \]; then/' ../Kernel/kernel/build/build.sh
#do ksun
cd ../Kernel/kernel-5.10/
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s v1.0.7
#do susfs stuff
if [ ! -f "./syscall_hooks.patch" ]; then
    cp ../../gitlab.com-simonpunk/kernel_patches/fs/* ./fs/
	cp ../../gitlab.com-simonpunk/kernel_patches/include/linux/* ./include/linux/
	cp ../../gitlab.com-simonpunk/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ./KernelSU-Next/
	cp ../../gitlab.com-simonpunk/kernel_patches/50_add_susfs_in_gki-android12-5.10.patch ./
	cp ../../wildplus/next/syscall_hooks.patch ./
	cp ../../wildplus/next/157susfs4ksun107.patch ./KernelSU-Next/kernel/
	#copy stupid fix for namespace c hunk 1 for different define infront insert and hunk 13 for different code after insert
	cp ../../wildplus/next/hotfixsamsungnamespace.patch ./
	cd ./KernelSU-Next/
	#echo "patch susfs to ksun"
	patch -p1 --forward < 10_enable_susfs_for_ksu.patch
	#echo "patch samsung adjusted susfs to ksun as a fix"
 	cd ./kernel/
	patch -p1 --forward < 157susfs4ksun107.patch
	cd ../..
	#echo "patch susfs in kernel"
	patch -p1 < 50_add_susfs_in_gki-android12-5.10.patch
	#do stupid fix for namespace c
	#echo "patch namespace fix"
	patch -p1 < hotfixsamsungnamespace.patch
	#echo "patch syscall_hooks"
	patch -p1 -F 3 < syscall_hooks.patch
fi
CONFIG_FILE="./arch/arm64/configs/a15_00_defconfig"
CONFIGS=(
  "CONFIG_KSU=y"
  "CONFIG_KSU_WITH_KPROBES=n"
  "CONFIG_KSU_SUSFS=y"
  "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_PATH=y"
  "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
  "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n"
  "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
  "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
  "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
  "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
  "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
  "CONFIG_KSU_SUSFS_SUS_SU=n"
  "CONFIG_TMPFS_XATTR=y"
  "CONFIG_TMPFS_POSIX_ACL=y"
  "CONFIG_IP_NF_TARGET_TTL=y"
  "CONFIG_IP6_NF_TARGET_HL=y"
  "CONFIG_IP6_NF_MATCH_HL=y"
)
for config in "${CONFIGS[@]}"; do
  key=$(echo "$config" | cut -d= -f1)
  if grep -q "^$key=" "$CONFIG_FILE"; then
    sed -i "s|^$key=.*|$config|" "$CONFIG_FILE"
  else
    echo "$config" >> "$CONFIG_FILE"
  fi
done
sed -i -E '/^CONFIG_(SECURITY_DEFEX|PROCA|FIVE|UH|RKP|KDP|KDP_CRED|KDP_NS|KDP_TEST|RKP_TEST)=y$/s/=y/=n/' ./arch/arm64/configs/a15_00_defconfig
#BBRS=(
#	'CONFIG_TCP_CONG_ADVANCED=y'
#	'CONFIG_TCP_CONG_BBR=y'
#	'CONFIG_DEFAULT_BBR=y'
#	'CONFIG_NET_SCH_FQ=y'
#	'CONFIG_TCP_CONG_BIC=n'
#	'CONFIG_DEFAULT_BIC=n'
#	'CONFIG_DEFAULT_TCP_CONG="bbr"'
#	'CONFIG_DEFAULT_RENO=n'
#	'CONFIG_DEFAULT_CUBIC=n'
#	'CONFIG_TCP_CONG_CUBIC=n'
#)
#for bbr in "${BBRS[@]}"; do
#	key=$(echo "$bbr" | cut -d= -f1)
#	if grep -q "^$key=" "$CONFIG_FILE"; then
#		sed -i "s|^$key=.*|$bbr|" "$CONFIG_FILE"
#	else
#		echo "$bbr" >> "$CONFIG_FILE"
#	fi
#done
#echo "configs in a15_00_defconfig echoed"
#configure the Kernel metadata
sed -i '$s|echo "\$res"|echo "-android12-9-28575149"|' ./scripts/setlocalversion
perl -pi -e 's{UTS_VERSION="\$\(echo \$UTS_VERSION \$CONFIG_FLAGS \$TIMESTAMP \| cut -b -\$UTS_LEN\)"}{UTS_VERSION="#1 SMP PREEMPT Thu Mar 06 09:35:51 UTC 2025"}' ./scripts/mkcompile_h
#echo "kernel metadata spoofed"
#do kernelbuilding
python2 scripts/gen_build_config.py --kernel-defconfig a15_00_defconfig --kernel-defconfig-overlays "entry_level.config" -m user -o ../out/target/product/a15/obj/KERNEL_OBJ/build.config
export ARCH=arm64
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
export OUT_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export DIST_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export BUILD_CONFIG="../out/target/product/a15/obj/KERNEL_OBJ/build.config"
#echo "generated buildconfig and exported build vars"
cd ../kernel
LTO=thin ./build/build.sh
cd ../../maggi
cp ../Kernel/out/target/product/a15/obj/KERNEL_OBJ/kernel-5.10/arch/arm64/boot/Image ./
mv Image kernel
#echo "copied Image for magiskboot"
../github.com-topjohnwu/x86_64/magiskboot repack ../samsungbootimg/boot.img boot.img
../github.com-topjohnwu/x86_64/magiskboot sign boot.img ../certificate.pem
#echo "magiskboot packed and signed boot.img"
