dir_path="FootballGather/_stubs"
cd $dir_path
java -jar wiremock-standalone-2.22.0.jar --port 9999 --root-dir $dir_path
