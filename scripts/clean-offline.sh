echo "run $0 ..."
pwd

scripts_dir=$(pwd)

cd ../src/offline
./clean_up.sh

cd ${scripts_dir}
cd ../sample-data/
./clean_up.sh


