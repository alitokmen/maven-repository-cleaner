#!/usr/bin/env bash

# Copyright 2021 S. Ali Tokmen | https://github.com/alitokmen/maven-repository-cleaner/
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

cleanDirectory() {
	local previousVersion=""
	for d in `ls -d * | sort -V`; do
		if [ "$d" = "0" ] || [ "$d" = "0]" ]; then
			echo "    > deleting awkward version: $PWD/$d"
			rm -Rf "$d"
		elif [[ -d "$d" ]]; then
			if [[ $d =~ ^[0-9]+\.[0-9]+((\.|-).*)?$ ]]; then
				echo "  > checking version: $PWD/$d"
				if ((${#previousVersion} > 0)); then
					echo "    > deleting previous version: $PWD/$previousVersion"
					rm -Rf "$previousVersion"
				fi
				previousVersion="$d"
			else
				echo "checking artifact: $PWD/$d"
				cd "$d"
				previousVersion=""
				cleanDirectory
				cd ..
			fi
		fi
	done
}

cd ~/.m2/repository/
du -sh .
cleanDirectory
du -sh .
