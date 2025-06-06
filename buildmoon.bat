mkdir build
if exist assets\ (
	cp -R assets build
)

pushd src
moonc -t ..\build *.moon
popd