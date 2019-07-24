# Git on Kubeflow

Instructions for using Git and GitHub in particular with Kubeflow.

1. Create an ssh key to be used as a deploy key with GitHub
   see [instructions](
   https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

1. In GitHub add the key as a deploy key on the repo you want
   to read and write

   * Enable write access if you want to be able to push
   * Alternatively you can add it as an ssh key for your account
     to give it access to all repositories

1. Correct permissions

    ```
    chmod 700 ~/.ssh
    chmod 644 ~/.ssh/authorized_keys
    chmod 644 ~/.ssh/known_hosts   
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    ```
1. In your Jupyter notebook upload the private and public key

1. In jupyter start a notebook and copy the public and private key to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
   
   * Make sure the ssh keys have the correct permissions

## Mounting the SSH key from a secret

1. Create the secret containing the public/private
 
    ```
    kubectl create secret generic ssh-key --from-file=id_rsa=<path to private key> --from-file=id_rsa.pub=<path to public key>
    ```

1. Use an init container and a pod volume to setup the ssh keys

   * Here's a sample pod spec

     ```
     apiVersion: v1
     kind: Pod
     metadata:
       name: jlewi-pod
       labels:
         app: jlewi
     spec:
       initContainers:
       - command:
         - /usr/local/bin/setup_ssh.sh
         - --ssh_dir=/root/.ssh
         - --private_key=/secret/ssh-key/id_rsa
         - --public_key=/secret/ssh-key/id_rsa.pub
         image: gcr.io/kubeflow-releasing/test-worker:v20190421-c9a1370-dirty-228f45
         name: setup-ssh
         volumeMounts:
         - mountPath: /root/.ssh
           name: ssh-config
         - mountPath: /secret/ssh-key
           name: ssh
           readOnly: true
       containers:
       - command:
         - tail
         - -f 
         - /dev/null
         image: gcr.io/kubeflow-releasing/test-worker:v20190421-c9a1370-dirty-228f45
         name: update
         env:
         - name: GOOGLE_APPLICATION_CREDENTIALS
           value: /secret/gcp-credentials/key.json
         - name: PYTHONPATH
           value: /src/kubeflow/kubeflow/py:/src/kubeflow/testing/py:/src/kubeflow/fairing        
         volumeMounts:
         - mountPath: /src
           name: src
         - mountPath: /secret/gcp-credentials
           name: gcp-credentials
           readOnly: true
         - mountPath: /root/.ssh
           name: ssh-config
       restartPolicy: Never
       volumes:
       - name: ssh-config
         emptyDir: {}
       - name: src
         emptyDir: {}
       - name: gcp-credentials
         secret:
           secretName: user-gcp-sa
       - name: ssh
         secret:
           secretName: kubeflow-bot-ssh
     ```

   * The init container runs the script setup_ssh.sh from https://github.com/kubeflow/testing this script

     * Copies the ssh key from a secret to a pod volume
     * Sets the permissions on the ssh files as needed

   * The main container mounts `${HOME}/.ssh` from a pod volume 

## Next Steps

* See [see troubleshooting section](https://help.github.com/en/articles/error-permission-denied-publickey) on GitHub