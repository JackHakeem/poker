rm -r res_temp
rm -r src_temp
encrypt_res.sh -i res -o res_temp -ek woyaopoker -es poker
mkdir src_temp
rm -r res_temp/shareicon
cp -r -f res/shareicon res_temp
compile_scripts.sh -i src -o res_temp/game.zip -e xxtea_zip -ek woyaopoker -es poker
compile_scripts.sh -i src -o res_temp/game64.zip -e xxtea_zip -ek woyaopoker -es poker -b 64
rm -f res_temp/project.manifest
rm -f res_temp/version.manifest
python GenHotUpdate_ios.py
