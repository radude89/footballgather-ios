#/bin/sh
proj_path=$1
cd $proj_path

java -jar "$proj_path/wiremock-standalone-2.22.0.jar" --port 9999
