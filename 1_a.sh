#!/bin/sh

export NM=`cat .version`

if [ "$NM" -eq "1" ]; then
	export build="a"
fi;

if [ "$NM" -eq "2" ]; then
	export build="b"
fi;

if [ "$NM" -eq "3" ]; then
	export build="c"
fi;

if [ "$NM" -eq "4" ]; then
	export build="d"
fi;

if [ "$NM" -eq "5" ]; then
	export build="e"
fi;

if [ "$NM" -eq "6" ]; then
	export build="f"
fi;

if [ "$NM" -eq "7" ]; then
	export build="g"
fi;

if [ "$NM" -eq "8" ]; then
	export build="h"
fi;

if [ "$NM" -eq "9" ]; then
	export build="i"
fi;

if [ "$NM" -eq "10" ]; then
	export build="j"
fi;

if [ "$NM" -eq "11" ]; then
	export build="k"
fi;

if [ "$NM" -eq "12" ]; then
	export build="l"
fi;

if [ "$NM" -eq "13" ]; then
	export build="m"
fi;

if [ "$NM" -eq "14" ]; then
	export build="n"
fi;

if [ "$NM" -eq "15" ]; then
	export build="o"
fi;

if [ "$NM" -eq "16" ]; then
	export build="p"
fi;

if [ "$NM" -eq "17" ]; then
	export build="q"
fi;

if [ "$NM" -eq "18" ]; then
	export build="r"
fi;

if [ "$NM" -eq "19" ]; then
	export build="s"
fi;

exec >>$PARENT_DIR/Build/Zip/"Build.txt" 2>&1
echo "$build";
