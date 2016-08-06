#!/bin/bash
pushd `dirname ${BASH_SOURCE[0]}` > /dev/null; HERE=`pwd`; popd > /dev/null
cd $HERE

coffee=$HERE/node_modules/coffee-script/bin/coffee

sysdir=$HERE/src/javascript/modules/block_maze/systems
genscript=$sysdir/_regen_index.coffee
outfile=$sysdir/index.coffee

# echo "$coffee $genscript > $outfile"
echo "Regenerating systems index in $sysdir"
cd $sysdir
$coffee $genscript > $outfile
cd -
echo Wrote $outfile


