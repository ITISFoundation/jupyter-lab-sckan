#!/bin/bash
# SEE http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'
INFO="INFO: [$(basename "$0")] "
WARNING="WARNING: [$(basename "$0")] "
ERROR="ERROR: [$(basename "$0")] "

echo "$INFO" "  User    :$(id "$(whoami)")"
echo "$INFO" "  Workdir :$(pwd)"

# Trust all notebooks in the notebooks folder
echo "$INFO" "trust all notebooks in path..."
# Try to trust all notebooks, warn if any fail, info if all succeeded
if find "${NOTEBOOK_BASE_DIR}" -name '*.ipynb' -type f -exec jupyter trust {} +; then
    echo "$INFO" "All notebooks trusted successfully."
else
    echo "$WARNING" "Some notebooks could not be trusted. TIP: please review the notebooks in ${NOTEBOOK_BASE_DIR}."
fi

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
    "FileContentsManager": {
        "preferred_dir": "${NOTEBOOK_BASE_DIR}/workspace/"
    },
    "IdentityProvider": {
        "token": "${NOTEBOOK_TOKEN}"
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
        "webbrowser_open_new": 0
    }
}
EOF

# SEE https://jupyter-server.readthedocs.io/en/latest/other/full-config.html
cat > "$HOME/.jupyter/jupyter_notebook_config.py" <<EOF
c.JupyterHub.tornado_settings = {
    'cookie_options': {'SameSite': 'None', 'Secure': True}
}

c.NotebookApp.tornado_settings = {
    'cookie_options': {'SameSite': 'None', 'Secure': True}
}
c.NotebookApp.disable_check_xsrf = True
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

if [ "${DY_BOOT_OPTION_BOOT_MODE}" -eq 1 ]; then
    if [ -f "${VOILA_NOTEBOOK}" ]; then
        echo "$INFO" "Found ${VOILA_NOTEBOOK}... Starting in voila mode"
        voila "${VOILA_NOTEBOOK}" --port 8888 --Voila.ip="0.0.0.0" --no-browser
    else
        echo "$ERROR" "VOILA_NOTEBOOK (${VOILA_NOTEBOOK}) not found! Cannot start in voila mode."
        exit 1
    fi
else
    # call the notebook with the basic parameters
    start-notebook.sh --config .jupyter_config.json "$@" --LabApp.default_url='/lab/tree/workspace/README-SCKAN.ipynb' --LabApp.collaborative=True
    start-notebook.sh --config .jupyter_config.json "$@" --LabApp.default_url='/lab/tree/workspace/README-OSPARC.ipynb' --LabApp.collaborative=True
fi

