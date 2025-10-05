#!/bin/sh

set -e

echo "## Scripts regression tests"

if [ -n "$1" ]; then
	xmllint=$1
else
	xmllint=./xmllint
fi

exitcode=0

for i in test/data/scripts/*.script; do
	name=$(basename "$i" .script)
	xml="./test/data/scripts/$name.xml"

	if [ -f "$xml" ]; then
		if [ ! -f "test/result/scripts/$name" ]; then
			echo "New test file $name"

			$xmllint --shell "$xml" < "$i" \
				> "test/result/scripts/$name" \
				2> "test/result/scripts/$name.err"
		else
			$xmllint --shell "$xml" < "$i" > shell.out 2> shell.err || true

			if [ -f "test/result/scripts/$name.err" ]; then
				resulterr="test/result/scripts/$name.err"
			else
				resulterr='/dev/null'
			fi

			log=$(
				diff -u "test/result/scripts/$name" 'shell.out' || true
				diff -u "$resulterr" 'shell.err' || true
			)

			if [ -n "$log" ]; then
				echo "$name" result
				echo "$log"
				exitcode=1
			fi

			rm 'shell.out' 'shell.err'
		fi
	fi
done

exit $exitcode
