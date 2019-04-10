# Git on Kubeflow

Instructions for using Git and GitHub in particular with Kubeflow.

1. Create an ssh key to be used as a deploy key with GitHub
   see [instructions](
   https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

1. In GitHub add the key as a deploy key on the repo you want
   to read and write

   * Enable write access if you want to be able to push

1. In your Jupyter notebook upload the private and public key

1. In jupyter start a notebook and copy the public and private key to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
   
   * Make sure the ssh keys have the correct permissions

## Next Steps

* See [see troubleshooting section](https://help.github.com/en/articles/error-permission-denied-publickey) on GitHub