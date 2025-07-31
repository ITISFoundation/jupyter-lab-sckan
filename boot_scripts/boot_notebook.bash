#!/bin/bash
# SEE http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'
INFO="INFO: [$(basename "$0")] "

echo "$INFO" "  User    :$(id "$(whoami)")"
echo "$INFO" "  Workdir :$(pwd)"

# Trust all notebooks in the notebooks folder
echo "$INFO" "trust all notebooks in path..."
find "${NOTEBOOK_BASE_DIR}" -name '*.ipynb' -type f | xargs -I % /bin/bash -c 'jupyter trust "%" || true' || true

# Configure
# Prevents notebook to open in separate tab
mkdir --parents "$HOME/.jupyter/custom"
cat > "$HOME/.jupyter/custom/custom.js" <<EOF
define(['base/js/namespace'], function(Jupyter){
    Jupyter._target = '_self';
});
EOF

# SEE https://jupyter-server.readthedocs.io/en/latest/other/full-config.html
cat > .jupyter_config.json <<EOF
{
    "FileCheckpoints": {
        "checkpoint_dir": "/home/jovyan/._ipynb_checkpoints/"
    },
    "Session": {
        "debug": false
    },
    "VoilaConfiguration" : {
        "enable_nbextensions" : true
    },
    "ServerApp": {
        "base_url": "",
        "disable_check_xsrf": true,
        "extra_static_paths": ["/static"],
        "ip": "0.0.0.0",
        "root_dir": "${NOTEBOOK_BASE_DIR}",
        "open_browser": false,
        "port": 8888,
        "quit_button": false,
        "root_dir": "${NOTEBOOK_BASE_DIR}",
        "webbrowser_open_new": 0
    },
    "IdentityProvider": {
        "token": "${NOTEBOOK_TOKEN}"
    },
    "FileContentsManager": {
        "preferred_dir": "${NOTEBOOK_BASE_DIR}/workspace/",
        "delete_to_trash": false
    }
}
EOF

cat > "/opt/conda/share/jupyter/lab/overrides.json" <<EOF
{
     "@krassowski/jupyterlab-lsp:completion": {
        "disableCompletionsFrom": ["Kernel"],
        "kernelResponseTimeout": -1
      }
}
EOF

VOILA_NOTEBOOK="${NOTEBOOK_BASE_DIR}"/workspace/voila.ipynb




if [ "${DY_BOOT_OPTION_BOOT_MODE}" -ne 0 ]; then
    echo "$INFO" "Found DY_BOOT_OPTION_BOOT_MODE=${DY_BOOT_OPTION_BOOT_MODE}... Trying to start in voila mode"
fi

if [ "${DY_BOOT_OPTION_BOOT_MODE}" -eq 1 ] && [ -f "${VOILA_NOTEBOOK}" ]; then
    echo "$INFO" "Found ${VOILA_NOTEBOOK}... Starting in voila mode"
    voila "${VOILA_NOTEBOOK}" --enable_nbextensions=True --port 8888 --Voila.ip="0.0.0.0" --no-browser
else
    # call the notebook with the basic parameters
    start-notebook.py --config .jupyter_config.json "$@" --LabApp.default_url='/lab/tree/workspace/README.ipynb' 
fi
