#!/bin/bash
pushd `dirname ${BASH_SOURCE[0]}` > /dev/null; HERE=`pwd`; popd > /dev/null
cd $HERE

coffee=$HERE/node_modules/coffee-script/bin/coffee
compdir=$HERE/src/javascript/pacman/components
genscript=$compdir/_regen.coffee
outfile=$compdir/generated_component_classes.coffee

# echo "$coffee $genscript > $outfile"
$coffee $genscript > $outfile
echo Wrote $outfile


