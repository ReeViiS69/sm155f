export ARCH=arm64
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
export OUT_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export DIST_DIR="../out/target/product/a15/obj/KERNEL_OBJ"
export BUILD_CONFIG="../out/target/product/a15/obj/KERNEL_OBJ/build.config"
#echo "generated buildconfig and exported build vars"
cd ./Kernel/kernel
LTO=thin ./build/build.sh
cd ../../maggi
cp ../Kernel/out/target/product/a15/obj/KERNEL_OBJ/kernel-5.10/arch/arm64/boot/Image ./
mv Image kernel
#echo "copied Image for magiskboot"
../github.com-topjohnwu/x86_64/magiskboot repack ../samsungbootimg/boot.img boot.img
../github.com-topjohnwu/x86_64/magiskboot sign boot.img ../private_key.pk8
#echo "magiskboot packed and signed boot.img"
