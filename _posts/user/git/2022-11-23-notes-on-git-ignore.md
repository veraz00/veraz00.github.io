---
layout: post
title: "Notes on Gitignore"
subtitle: "Notes on Gitignore"
category: user
tags: git
---

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}


When adding code into `.git`, which is used to push code scripts into github (website), we would set `.gitignore`. In it, filenames which are set as ignored file for `.git` would be listed

## Example 

The following is part of `.gitignore` file from [official yolov7 repo](https://github.com/WongKinYiu/yolov7/blob/main/.gitignore)

<details>
<summary>.gitignore</summary>
<div markdown="1">

```shell 
# Repo-specific GitIgnore ----------------------------------------------------------------------------------------------

*.jpg  # ignore any file ending with jpg

*.MOV

!setup.cfg  # not ignore setup.cfg

!cfg/yolov3*.cfg

storage.googleapis.com

runs/*  # ignore run folder

data/*  # ignore data folder
a or b
data/images/*

!data/*.yaml  # not ignore yaml file for subfiles in data folder

!data/hypsconte

!data/images/zidane.jpg

# MATLAB GitIgnore -----------------------------------------------------------------------------------------------------

*.m~  # ignore any file ending with m~

*.mat

!targets*.mat

# Sensitive or high-churn files:

.idea/**/dataSources/  # ignore dataSources folder under any level of .idea folder

.idea/**/dataSources.ids # ignore dataSources.ids under any level of .idea folder
```
</div>
</details>

## Regex Use

You may be confused about what exact file path it pointed to, or how to use `*` or `**`. Take easy, you gonna figure out all when reading the following.

## Asterisk *

It can be used to represent any character, either [a-zA-Z0-9] or special character. It can represent 0 or a number of characters

In office git document, it mentioned * cannot be used to represent slash. It is wrong! Actually * can be used to represent either `/` or `\`

### TEST 
1. Create a directory with subdirectory and keep the current path under aws folder

  ```shell
  - aws
    - utils
      - 1.py
      - 2.py
        - data
            - label1.txt
    - download.py
    - upload.py
    - .gitignore
  ```

2. Edit .gitignore

  ```shell
  nano .gitignore
  # content of .gitignore
  ```

3. Create git on `.gitignore` level

  ```shell
  git init
  git add .
  ```
4. Check the file added into `.git`, by `git ls-files`
  > The result would be nothing, which means all the files are ignored by `.git`
  > But here are some files `utils/1.py`, which involved `/` but still be represented by `*` and ignored by `.git`

### Play
1. Modify `.gitignore` by adding `aws/utils/*` to a new line 
2. Re-do git 

  ```shell
  git rm --cached . # remove the previous cached git
  git add .
  git ls -files 
  ```
3. You can see, the files from utils folder would be filter out 
aws/utils can be replaced as `aws/utils/` , or `aws/utils/*`

## Double Asterisk **

Two asterisks `**` specify any number of subdirectories

### Examples

`/**`: matches everything inside root (.gitignore directory) = `/*`

 `a/**/b` = `a/*/b`: ` "a/b", "a/x/b", "a/x/y/b" `

## Question Mark ? 

`?`: any one character

## Others 

`*.[ab]`: filter out any file end with a or b

`*.(png|jpg|gif)`: filter out any file end with png, jpg, git

## Special Use 

### Exclamation Mark !

`!` is used to keep files. In other words, the file start with ! in .gitignore would be kept by git 

For example, `!data` would keep the data folder 

Let's look at the last example, if we want to ignore the whole aws folder but keep the aws one. There are 2 methods 

**method1**

```shell
aws/*.*  # ignore files in aws folder
aws/data/*   # ignore data subfolder in aws folder`
```

**method2**

```shell
aws/*
!aws/utils/  # here we need to add utils (folder name) first, becase last line it ignored every thing
!aws/utils/*`
```

## Subfolder

On git, we cannot keep folder structure but ignore all the files inside. There is a solution to achieve this

**Solution**

Creating a `.gitignore` within this directory

```shell
# content of this .gitignore 
* # ignore everything within this folder 
!.gitignore # keep gitignore
```

**Explanation**

`.gitignore` is based on current directory. It means, `*` represent  the directory where`.gitignore` located

So when add `.gitignore` on this directory, it would works on this directory only 

## Self-Train 

- Choose one `.gitignore` repo, and try to understand it 

- Write `.gitignore` by yourself, to see whether it can keep the files which you expects to have into git

## Refer
1. https://stackoverflow.com/questions/25554504/what-does-mean-in-gitignore
2. https://git-scm.com/docs/gitignore
3. https://github.com/WongKinYiu/yolov7/blob/main/.gitignore