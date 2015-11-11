
xcodebuild -project Logful.xcodeproj -target Logful -configuration Release -sdk iphonesimulator build

xcodebuild -project Logful.xcodeproj -target Logful -configuration Release -sdk iphoneos build

lipo -create build/Release-iphonesimulator/libLogful.a build/Release-iphoneos/libLogful.a -output build/Release-iphonesimulator/Logful.framework/Versions/A/Logful
