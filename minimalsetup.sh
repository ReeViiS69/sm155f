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
[ ! -d ./KernelSU-Next/ ] && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s v1.1.1
find . -type f ! -perm -u=w -exec chmod u+w {} +
if [ ! -f "./scope_min_manual_hooks_v1.4.patch" ]; then
	cp ../../gitlab.com-simonpunk/kernel_patches/fs/* ./fs/
	cp ../../gitlab.com-simonpunk/kernel_patches/include/linux/* ./include/linux/
	cp ../../gitlab.com-simonpunk/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ./KernelSU-Next/
	cp ../../gitlab.com-simonpunk/kernel_patches/50_add_susfs_in_gki-android12-5.10.patch ./
	cp ../../wildplus/next/scope_min_manual_hooks_v1.4.patch ./
fi
CONFIG_FILE="./arch/arm64/configs/a15_00_defconfig"
CONFIGS=(
  "CONFIG_KSU=y"
  "CONFIG_KSU_KPROBES_HOOK=n"
  "CONFIG_KSU_SUSFS=y"
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
BBRS=(
	'CONFIG_TCP_CONG_ADVANCED=y'
	'CONFIG_TCP_CONG_BBR=y'
	'CONFIG_DEFAULT_BBR=y'
	'CONFIG_NET_SCH_FQ=y'
	'CONFIG_TCP_CONG_BIC=n'
	'CONFIG_DEFAULT_BIC=n'
	'CONFIG_DEFAULT_TCP_CONG="bbr"'
	'CONFIG_DEFAULT_RENO=n'
	'CONFIG_DEFAULT_CUBIC=n'
	'CONFIG_TCP_CONG_CUBIC=n'
)
for bbr in "${BBRS[@]}"; do
	key=$(echo "$bbr" | cut -d= -f1)
	if grep -q "^$key=" "$CONFIG_FILE"; then
		sed -i "s|^$key=.*|$bbr|" "$CONFIG_FILE"
	else
		echo "$bbr" >> "$CONFIG_FILE"
	fi
done
#echo "configs in a15_00_defconfig echoed"
#configure the Kernel metadata
sed -i '$s|echo "\$res"|echo "-android12-9-31117096"|' ./scripts/setlocalversion
perl -pi -e 's{UTS_VERSION="\$\(echo \$UTS_VERSION \$CONFIG_FLAGS \$TIMESTAMP \| cut -b -\$UTS_LEN\)"}{UTS_VERSION="#1 SMP PREEMPT Mon Sep 8 08:09:10 UTC 2025"}' ./scripts/mkcompile_h
sed -i 's/-dirty//' ./scripts/setlocalversion
#echo "kernel metadata spoofed"
#do kernelbuilding
