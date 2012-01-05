#! /usr/bin/env bash

projects=('balsamine' 'disappearance')
url="http://git.constantvzw.org/?p=%s.git;a=blob_plain;f=README"


mkdir -p tmp
cd tmp


for project in "${projects[@]}"
do 
    wget -O"${project}.mkd" $(printf ${url} ${project})
    pandoc -f markdown -t context -o "${project}.tex" "${project}.mkd"
    echo -e "\n\n% END OF ${project}\n\n" >> "${project}.tex"
done

cat *.tex > ../input.tex

cd ..

rm -fr tmp

context template.tex
