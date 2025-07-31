# jupyterlab-sckan

This service offers a convenient way to access [SCKAN](https://sparc.science/tools-and-resources/6eg3VpJbwQR4B84CjrvmyD) (SPARC Connectivity Knowledge Base) connectivity maps of the autonomous nervous system.

## Requirements
- GNU Make
- Python3
- [``Docker``](https://docs.docker.com/get-docker/) (if you wish to build and test the service locally)

## Workflow
### Create the Service
1. Add your additional libraries to the appropriate in file [`env-config`](./env-config/)
2. The [Dockerfile](jupyterlab-sckan/src/Dockerfile) shall be modified to install additional packages, software and/or Jupyter kernels (if something is need in addition to 1.)
3. Optional: the [.osparc](.osparc) is the configuration folder and source of truth for metadata: describes service info and expected inputs/outputs of the service. If you need to change the inputs/outputs of the service, description, thumbnail, etc... check the [`metadata.yml`](./.osparc/metadata.yml) file
4. Optional: if you need to change the start-up behavior of the service, modify the [`boot_notebook.bash`](./boot_scripts/boot_notebook.bash) file
5. Optional (for testing): The service docker image may be built with ``make build`` (see "Useful Commands" below)
6. Optional (for testing): The service docker image may be run locally with ``make run-local`` (see "Useful Commands" below)

### Publish the Service on o²S²PARC
Once you're happy with your code:
1. Push it to a public repository.
2. An automated pipeline (GitHub Actions) will build the Docker image for you (as in step 5)
3. Wait for the GitHub pipeline to run successfully
4. Check that the automated pipeline executes successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of the final steps!

### Change the Service (after it has been published on o²S²PARC )
If you wish to change your Service (e.g. add additional librarie), after it has been published on o²S²PARC, you have to **create a new version**:
1. Go back to your repository
2. Apply the desired changes
3. Increase ("bump") the Service version: in your console execute: ``make version-patch``, or ``make version-minor``, or  ``make version-major``
4. Commit and push the changes to your repository
5. Wait for the GitHub/GitLab pipelines to run successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of publishing the new version!


### Useful commands
```console
$ make help
$ make build # This will build an o²S²PARC-compatible image (similar to `Docker build` command)
$ make run-local # This will run the JupyterLab interface on your computer. Follow the instructions in your console to open it in your browser (useful e.g. to test that your code runs as expected)
```

