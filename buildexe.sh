rm train-track/public/TrainTrackStandaloneInstaller.exe
mv train-track/db/*.sqlite3 .
ruby ocra/bin/ocra train-track/script/server train-track --gemfile train-track/Gemfile --add-all-core --no-dep-run --no-lzma --chdir-first --output train-track.exe --dll sqlite3.dll --dll libiconv2.dll --dll ssleay32-0.9.8-msvcrt.dll --dll zlib1.dll --innosetup train-track/train-track.iss -- -e offline
mv *.sqlite3 train-track/db/
