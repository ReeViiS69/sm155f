cd ./Kernel/kernel-5.10/
python2 scripts/gen_build_config.py --kernel-defconfig a15_00_defconfig --kernel-defconfig-overlays "entry_level.config" -m user -o ../out/target/product/a15/obj/KERNEL_OBJ/build.config
cd ..
export ARCH=arm64
export PLATFORM_VERSION=12
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
export OUT_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export DIST_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export BUILD_CONFIG="../out/target/product/a15/obj/KERNEL_OBJ/build.config"
#echo "generated buildconfig and exported build vars"
cd ./kernel
LTO=thin ./build/build.sh
cd ../../maggi
cp ../Kernel/out/target/product/a15/obj/KERNEL_OBJ/kernel-5.10/arch/arm64/boot/Image ./
mv Image kernel
#echo "copied Image for magiskboot"
if [ -f ./kernel ];then
../github.com-topjohnwu/x86_64/magiskboot repack ../samsungbootimg/boot.img boot.img
../github.com-topjohnwu/x86_64/magiskboot sign boot.img ../certificate.pem
fi
