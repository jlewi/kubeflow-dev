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
    chmod 600 ~/.ssh/github_kf
    chmod 644 ~/.ssh/github_kf.pub
    ```
1. In your Jupyter notebook upload the private and public key

1. In jupyter start a notebook and copy the public and private key to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
   
   * Make sure the ssh keys have the correct permissions

1. Add keys to ssh agent

   ```
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/github_kf
   ```

## ssh-agent

To avoid needing to restart ssh-agent in every terminal add the following to
your .bashrc

```
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
```

## Mounting the SSH key from a secret

1. Create the secret containing the public/private
 
    ```
    kubectl create secret generic ssh-key --from-file=id_rsa=<path to private key> --from-file=id_rsa.pub=<path to public key>
    ```

1. Mount the git credentials into a volume

   * Here's a sample pod spec

     ```
      apiVersion: kubeflow.org/v1
      kind: Notebook
      metadata:
        labels:
          app: jlewi-grpc # {"$ref":"#/definitions/io.k8s.cli.substitutions.name"}
        name: jlewi-grpc # {"$ref":"#/definitions/io.k8s.cli.substitutions.name"}
      spec:
        template:
          spec:
            containers:
            - env:
              # TODO(jlewi): I got an error: 
              #- name: JUPYTERLAB_DIR # Set the JUPYTERLAB_DIR so we can install extensions        
              #  value: /home/jovyan/.jupyterlab_dir
              image: gcr.io/kubeflow-images-public/tensorflow-1.15.2-notebook-cpu:1.0.0
              name: jlewi-grpc # {"$ref":"#/definitions/io.k8s.cli.substitutions.name"}
              # Bump the resources to include a GPU
              resources:
                limits:
                  nvidia.com/gpu: 0 # {"$kpt-set":"numGpus"}
                  cpu: "16"
                  memory: 32Gi
                requests:
                  cpu: "4"
                  memory: 4Gi
              volumeMounts:
              - mountPath: /home/jovyan
                name: workspace
              - mountPath: /dev/shm
                name: dshm    
              - mountPath: /secret/ssh-key
                name: ssh
                readOnly: true
            # Start a container running theia which is an IDE
            - image: theiaide/theia:next # TODO(jlewi): Should we use an image which actually includes an appropriate toolchain like python?
              name: theia
              resources:
                requests:
                  cpu: "4"
                  memory: 1.0Gi
                limits:
                  cpu: "16"
                  memory: 8.0Gi
              volumeMounts:
              - mountPath: /mount/jovyan
                name: workspace
            serviceAccountName: default-editor
            ttlSecondsAfterFinished: 300
            volumes:
            - name: workspace
              persistentVolumeClaim:
                claimName: workspace-jlewi-grpc # {"$kpt-set":"pvc-name"}
            - name: ssh
              secret:
                secretName: git-creds
            - emptyDir:
                medium: Memory
              name: dshm
     ```

1. Use ssh-agent to add the ssh key

   ```
   eval "$(ssh-agent -s)"
   ssh-add  /secret/ssh-key/ssh
   ```

## Next Steps

* See [see troubleshooting section](https://help.github.com/en/articles/error-permission-denied-publickey) on GitHub