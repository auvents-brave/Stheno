FROM ubuntu:questing

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl

# Little cleanup
RUN rm -rf /var/lib/apt/lists/*

# Install Swiftly
RUN curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
    tar zxf swiftly-$(uname -m).tar.gz && \
    ./swiftly init --skip-install --quiet-shell-followup && \
    . "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh" && \
    hash -r

# Install Swift 6.2.1-RELEASE
RUN swiftly install 6.2.1-RELEASE

# Verify installation
RUN swift --version
