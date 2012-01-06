#!/usr/bin/env bash

# projects=('balsamine' 'disappearance')
projects=('balsamine')
url="http://git.constantvzw.org/?p=%s.git;a=blob_plain;f=README"
index="http://git.constantvzw.org/?p=%s.git;a=blob_plain;f=iceberg/index.mkd"
iceberg="http://git.constantvzw.org/?p=%s.git;a=tree;f=iceberg;"

mkdir -p tmp
cd tmp


for project in "${projects[@]}"
do
    # Get the README
    wget -O "${project}.mkd" $(printf ${url} ${project})
    # Just the introductory explanation:
    python -c "f = open('${project}.mkd', 'r'); b = f.read().split('- - -')[0]; f.close(); f = open('${project}.mkd', 'w'); f.write(b) "
    # Add image list:
    wget -O - $(printf ${index} ${project}) >> "${project}.mkd"
    # Download image files:
    wget -O - $(printf ${iceberg} ${project}) \
    | sed -n -e 's/.*<a href="\([^"]*\)\(png\|jpg\|jpeg\)\;hb=HEAD">raw<\/a><\/td>/http:\/\/git.constantvzw.org\1\2/pI' \
    | wget -i - -P ..
    # To tex:
    pandoc -f markdown -t context -o "${project}.tex" "${project}.mkd"
    echo -e "\n\n% END OF ${project}\n\n" >> "${project}.tex"
done

cat *.tex > ../input.tex

cd ..

# rename image files downloaded by wget
rename 's/index.html(.*)%2F//' *.*

# rm -fr tmp

context template.tex
