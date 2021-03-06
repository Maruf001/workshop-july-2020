#Compute DFT energy and forces for all atomic configuration in coord.raw

### Load user INPUT ###
source ../../path_to_codes

if ! [ -e coord.raw ]; then
  echo "Could not find coord.raw"
  echo "I am in `pwd`"
  echo "STOP"
  exit
fi

cp ../codes/convert_raw_to_pw_input.py .
cp ../codes/type.raw .
python convert_raw_to_pw_input.py

#Run jobs in parallel
n=`wc -l coord.raw | awk '{print $1}'`
for i in `seq -f "%05g" $n`
do
  while [ $(ps S | grep "pw.x" | wc -l) -ge 6  ]; do sleep 10; done;
  
  cd $i
    $PW < 01.in &> 01.out &
  cd ..

done

wait

#Obtain raw files from PW outputs
mkdir analysis
cp ../codes/get_raw_data.sh ./analysis
cd analysis
./get_raw_data.sh
cd ..

rm convert_raw_to_pw_input.py type.raw 
