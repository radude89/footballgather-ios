dir_path="../stubs"
cd $dir_path
java -jar wiremock-standalone-2.22.0.jar --port 9999 2>&1 &
echo "wiremock started"
