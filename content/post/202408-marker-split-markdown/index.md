+++
title = "Marker学习笔记（3）: 拆分 markdown 文件"
date =  2024-08-26
lastmod = 2024-08-26
draft = false

tags = ["PDF", "markdown", "AI", "marker"]
summary = "Marker 是一个快速、高精度地将 PDF 转换为 Markdown 的工具。本文介绍如何拆分 Marker 生成的单个 markdown 大文件。"
abstract = "Marker 是一个快速、高精度地将 PDF 转换为 Markdown 的工具。本文介绍如何拆分 Marker 生成的单个 markdown 大文件。"

[header]
image = ""
caption = ""

+++

## 背景

Marker 生成的 markdown 文件是一个包含 pdf 所有内容的单个文件，当 pdf 文件内容比较多时，这个 markdown 文件的尺寸会比较大，影响阅读和后续处理（比如翻译）。

如下图，原 pdf 文件有 680 多页，转换得到的 markdown 文件足足有 619K ：


```bash
ls -lh
-rwxr-xr-x 1 sky sky 619K  8月 24 21:03 adobe-photoshop-book-photographers-2nd.md
-rwxr-xr-x 1 sky sky  46K  8月 23 10:25 adobe-photoshop-book-photographers-2nd_meta.json
```

因此考虑将这个大 markdown 文件拆分为若一组小一点的 markdown 文件。很显然，按照章节进行拆分是比较合理的。

## bash脚本

用 bash 脚本实现这个功能会很简单：

```bash
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
```

这个脚本在使用前，需要为要拆分的 markdown 文件提供每个章节开始部位的关键字，比如之前生成的 adobe-photoshop-book-photographers-2nd.md 文件，每个章节都会以类似 "# The Essentials Of Camera Raw" 的方式开始，

为了从 markdown 文件中找到每个章节开始的关键字， 可以用下面的命令先做一次筛选：

```bash
cat ./adobe-photoshop-book-photographers-2nd.md | grep "# " | grep -v "## "
```

然后结合 pdf 的章节标题，就能很快找出来各个章节开始的关键字：

```bash
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
......
```

附件： [split.sh文件](./images/split.sh)

## 手工调整

拆分过程并不会完美，比如在章节关键字之前，可能会有几张图片。这些图片的内容目前会被拆分到上一个章节中，需要手工进行调整。另外书籍末尾的 index 章节往往没有意义，通常会考虑删除。

谨慎起见，手工调整的过程中，也可以对照 pdf 原文核对一下拆分是否准确。

## 结论

虽然有 AI 的介入，但是有些还是需要人工介入，这也就意味着工作量，希望 AI 以后可以做的更加的智能。

