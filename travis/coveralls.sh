echo "*********************"
echo "*     COVERALLS     *"
echo "*********************"
xctool -workspace pubnative-ios-library.xcworkspace \
	   -scheme PubnativeDemo \
	   -sdk iphonesimulator \
	   -configuration Debug \
	   ONLY_ACTIVE_ARCH=NO \
	   GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
	   GCC_GENERATE_TEST_COVERAGE_FILES=YES \
	   clean test

./travis/coveralls.rb --extension m --exclude-folder PubNativeDemo --exclude-folder 'PubNative/External'