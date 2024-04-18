<!-- ---
layout: post
title: "Notes on Git Secrets"
subtitle: "Notes on Git Secrets"
category: user
tags: git
--- -->

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}



## Overview 

I once **mistakenly pushed AWS access keys to GitHub**. To prevent this, I explored two methods to automatically exclude secret files from Git:

1. Store secrets on PC as **masked files**. These are read, decoded, and imported into each project.
2. Save secrets in the project. They get excluded by **Git** even if `.gitignore` is deleted.

## Method1: Store Secrets on PC

This method prevents local secret leakage. It involves encoding or decoding secrets using `RSA` or similar.
![](/assets/img/2023-11-11/method1.png)

**Advantages**: Secrets are saved once locally and used across projects.

**Disadvantages**: 
- Public and private keys must be maintained for encoding and decoding.
- Keys cannot be directly accessed until the file is decoded.

Due to these disadvantages, **I abandoned this method**.

## Method2: Save Secrets in the Project

It would exclude a project's `env` secret file from Git, apart from using `.gitignore`.

### Git-Secret from Github 

- [Github](https://github.com/sobolevn/git-secret)
- [Blog](https://blog.csdn.net/JENREY/article/details/105162201)

`git-secret` provides **file access permission** to certain users using an encoder-decoder method. However, it doesn't automatically exclude files from `.github`.


### Git Secrets from Another Github

- [Github](https://github.com/benammann/git-secrets)

This solution targets individual secrets, not the whole file. It involves storing plain secrets **in a config file** that is automatically ignored after initializing `git secrets init`.

![](/assets/img/2023-11-11/method2_2.png)

1. In scripts, when import values from config file, calling them with the following format in scripts:  

  ```js
  DATABASE_HOST={{.Configs.databaseHost}}
  DATABASE_PORT={{.Configs.databasePort}}
  DATABASE_NAME={{.Configs.databaseName}}
  DATABASE_PASSWORD={{.Secrets.databasePassword}}
  ```

2. Get scripts with plain secret values by **rendering the config into it**

  ```shell
  git secrets add file <script1> -t <script1_plain_value>
  git secrets render env
  ```

  The rendered script (with plain value) would be the following: 

  ```shell
  DATABASE_HOST=database_value
  DATABASE_PORT=database_port_value
  DATABASE_NAME=dataname_value
  DATABASE_PASSWORD=database_password_value

  ```
  Generally, if we want to import value from config, have to run the `git secrets add` and `git secrets render`. Rendered scripts **can be deleted any time and do rendering again if needs to run scripts**. 

3. In addition, it provides **a single command to scan**, checking whether in any file file, it stores the secret value as the config keeps.

After trying this, it's still troublesome every time I had to generate an rendered scripts. It may avoid the risk that the rendered scripts would be pushed into the github, since that single command can do the scanning. 

### Git Secrets from AWS Labs 

- [Github](https://github.com/awslabs/git-secrets)

`git secrets` from AWS Labs was the final solution I explored. It involves installing and running `git secrets` in `.git`, registering default AWS Accesskey format, **adding custom prohibited patterns**, and scanning the repo for these patterns.

![](/assets/img/2023-11-11/method2_3.png)


#### Steps to Install in Linux 
Requires Sudo Permission 
```shell
git clone https://github.com/awslabs/git-secrets#nix-linux-macos 
make install
```

#### Steps to Run

1. Initialize `git secrets` in `.git`
  ```shell
  cd /path/to/my/repo 
  git secrets --install
  ```

2. Add default `regex` AWS Accesskey format, prohibiting to upload matched formats to cloud
  ```shell
  git secrets --register-aws 
  git secrets --register-aws --global
  ```

3. Customize the prohibited pattern. For example `git secrets --add '[A-Z0-9]{20}`

4. Scan the whole repo/folder/file to check whether it includes the prohibited pattern: `git secrets --scan {location}`
> When committing, it automatically scans the whole repo.

### Feedback 

This solution is straightforward but could be improved with **an auto-encoder to store plain values in a config file and an auto-decoder to import them into scripts**.