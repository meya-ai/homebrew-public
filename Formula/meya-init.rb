$source = <<~EOS
#!/usr/bin/env bash

# Stop if there's an error
set -e

# Set up direnv
echo "Setting up Python virtual environment..." >&2
cat > .envrc << 'EOF'
# https://github.com/direnv/direnv/wiki/Python#venv-stdlib-module
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
layout_python-venv() {
    local python=${1:-python3}
    [[ $# -gt 0 ]] && shift
    unset PYTHONHOME
    if [[ -n $VIRTUAL_ENV ]]; then
        VIRTUAL_ENV=$(realpath "${VIRTUAL_ENV}")
    else
        local python_version
        python_version=$("$python" -c "import platform; print(platform.python_version())")
        if [[ -z $python_version ]]; then
            log_error "Could not detect Python version"
            return 1
        fi
        VIRTUAL_ENV=$PWD/.direnv/python-venv-$python_version
    fi
    export VIRTUAL_ENV
    if [[ ! -d $VIRTUAL_ENV ]]; then
        log_status "no venv found; creating $VIRTUAL_ENV"
        "$python" -m venv "$VIRTUAL_ENV"
    fi
    PATH_add "$VIRTUAL_ENV/bin"
}

layout python-venv python3.7
EOF
direnv allow
eval "$(direnv export bash)"

# Install meya-sdk
echo "Installing Meya SDK from Pip..." >&2
pip install --extra-index-url https://registry.meya.ai/pypi meya-sdk

# Run meya
meya $@
EOS

class MeyaInit < Formula
    desc "Initialization for Meya SDK"
    homepage "https://meya.ai/"
    version "0.2"
    url "file:///dev/null"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    depends_on "python@3"
    depends_on "direnv"
    depends_on "git"
    depends_on "node"
    depends_on "yarn"

    def install
        (bin+"meya").write $source
        (bin+"meya").chmod 0755
    end
end
