#!/usr/bin/env bash

# Copyright 2021-2023 S. Ali Tokmen | https://github.com/alitokmen/maven-repository-cleaner/
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

	# List all directories and sort by version (ascending order)
	# Read more on: https://www.gnu.org/software/coreutils/manual/html_node/Version-sort-overview.html
	for directory in `ls -d * | sort -V`; do
		if [ "$directory" = "0" ] || [ "$directory" = "0]" ]; then
			echo "    > deleting awkward version: $PWD/$directory"
			rm -Rf "$d"
		elif [[ -d "$directory" ]]; then
			if [[ $directory =~ ^[0-9]+\.[0-9]+((\.|-).*)?$ ]]; then
				local old="$previousVersion"
				local new="$directory"
				echo "  > checking version: $PWD/$directory"
				if ((${#previousVersion} > 0)); then
					# Since the output is sorted by (ascending) versions,
					# the fact that there is a previous folder indicates that there are two versions in that folder
					# and that the previous folder is an older version
					if [[ ${directory,,} =~ ^[0-9]+\.[0-9]+.*([\.\-_]alpha|[\.\-_]beta|-m\d|-rc|-snapshot).*$ ]] && [[ $previousVersion =~ ^[0-9\.]+$ ]]; then
						# Only caveat: sorting happens "the wrong way round" for alpha, beta, etc. versions
						# The current directory has such a name (and the previous directory didn't),
						# so consider current (alpha, beta, etc.) is actually older
						old="$directory"
						new="$previousVersion"
						echo "    > version $directory has a non-numeric, assuming it is older than $previousVersion"
					fi
					if test `find "$PWD/$old" -mmin +360 -print -quit`; then
						echo "    > deleting previous version: $PWD/$old"
						rm -Rf "$old"
					else
						echo "    > skipping previous version aged 6 hours or less: $PWD/$old"
					fi
				fi
				previousVersion="$new"
			else
				echo "checking artifact: $PWD/$directory"
				cd "$directory"
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
