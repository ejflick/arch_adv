mkdir build
if exist assets\ (
	cp -R assets build
)

if exist lib\ (
	cp -R lib build
)

pushd src
moonc -t ..\build *.moon
popd