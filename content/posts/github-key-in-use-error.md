---
title: Github "Key is already in use" Error
date: 2021-08-22T21:47:52-04:00
draft: false
categories: 
  - development
  - git
---

Recently GitHub changed it so I could no longer push using https protocol. At work, I always used ssh to push. So when this happened, I thought, "No problem, I'll just add my ssh key to my GitHub profile."

So when I went to do that, I was getting an error saying "Key is already in use." 

So it took me a long time to realize that this was happening because I had already added my ssh key to my work github profile, which I rarely have occasion to use. But it left me wondering how I could use ssh to push and pull to both my work and my [personal github repository](https://github.com/cslauritsen/). 

# Create Another SSH Key
The answer for me was, make another ssh key. It's simple enough to create another ssh key:

```bash
ssh-keygen -t ed25519 -C "me@example.com"
```

This will create a keypair in a pair of files, for the private and public keys respectively:
```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```
## Update my Personal Account's SSH Key
Paste the contents of `~/.ssh/id_ed25519.pub` into my personal github profile's SSH keys section.

## Configure `git` to use non-default key

My `~/.ssh/config` file specifies a default `IdentityFile` for all hosts:
```
Host * 
 UseKeyChain yes
 AddKeysToAgent yes
 IdentityFile ~/.ssh/id_rsa
``` 
So, I cannot differentiate using the hostname for my personal and work github.com repositories.  

For now, the best solution I found is to override the default identity file for the repositories that I wish to synchronize with my personal github. 

I just have to remember to do configure each repository. From somewhere within the repository directory structure, do:

```bash
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519"
```

This will update the `.git/config` file in the repo to override the key used to idenity me with github.com.

