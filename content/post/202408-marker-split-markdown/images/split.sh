#!/bin/bash

# TODO: update keywords for different markdown files
chapter_begin_keywords[0]="introduction"  # will be ignored for splitting and just used for naming
chapter_begin_keywords[1]="# The Essentials Of Camera Raw" 
chapter_begin_keywords[2]="# Camera Raw–Beyond The Basics" 
chapter_begin_keywords[3]="# Masking Miracles"
chapter_begin_keywords[4]="# Correcting Lens Problems"
chapter_begin_keywords[5]="# Working With Layers"
chapter_begin_keywords[6]="# Making Selections"
chapter_begin_keywords[7]="# Black & White, Duotones & More"
chapter_begin_keywords[8]="# Cropping & Resizing"
chapter_begin_keywords[9]="# Retouching Portraits"
chapter_begin_keywords[10]="# Removing Distracting Stuff"
chapter_begin_keywords[11]="# Photoshop Effects"
chapter_begin_keywords[12]="# Sharpening Techniques"

echo "Preparing, reading keywords for chapters......"
echo ""

chapter_names=()
index=0
while(( $index<${#chapter_begin_keywords[*]} ))
do
    # build chapter name by keywords and index
    # remove "# "
    chapter_name=${chapter_begin_keywords[$index]//# /}
    # remove "& "
    chapter_name=${chapter_name//& /}
    # remove ","
    chapter_name=${chapter_name//,/}
    # replace " " with "-"
    chapter_name=${chapter_name// /-}
    # lowcase all
    chapter_name=${chapter_name,,}
    # add "chapterxx" prefix
    if [[ $index -lt 10 ]];
    then
        chapter_name="chapter0${index}_${chapter_name}"
    else
        chapter_name="chapter${index}_${chapter_name}"
    fi
    # add ".md" suffix
    chapter_name="${chapter_name}.md"
    chapter_names[${index}]=${chapter_name}

    echo "chapter ${index} begin keyword=${chapter_begin_keywords[$index]}"
    echo "chapter name=${chapter_names[$index]}"
    echo ""
    let "index++"
done

# clean files before execution
echo "clean chapter files if exists"
rm -f chapter*.md
rm -f todo.md todo-temp.md


echo ""
echo "Begin to split file $1 by keywords......"
echo ""
cp $1 todo.md

index=0
while(( $index < (${#chapter_begin_keywords[*]} - 1 )))
do
    cat todo.md | grep -B 1000000000 "${chapter_begin_keywords[$index+1]}" > "${chapter_names[$index]}"
    cat todo.md | grep -A 1000000000 "${chapter_begin_keywords[$index+1]}" > todo-temp.md
    rm -f todo.md
    mv todo-temp.md todo.md
    echo "Succeed to split out ${chapter_names[$index]}"
    let "index++"
done

# last chapter will be saved in todo.md, just rename it!
mv todo.md ${chapter_names[$index]}
echo "Succeed to split out ${chapter_names[$index]}"

echo ""
echo "Done!"
echo ""

echo "Please check the output files:"
echo ""

ls -lh chapter*.md

echo ""
