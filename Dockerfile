# Start from the code-server Debian base image
FROM codercom/code-server:3.10.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# Set the Begin ENV
RUN sudo apt-get install -y --no-install-recommends \
	vim \
	curl \ 
	git   \ 
	wget   \ 
	make	\ 
	man 	\
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	openssh-client \
	gnupg2 \
	build-essential \
	rsync

ENV GOLANG_VERSION 1.16.2
ENV GOLANG_DOWNLOAD_URL https://mirrors.ustc.edu.cn/golang/go$GOLANG_VERSION.linux-amd64.tar.gz
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& rm -rf /usr/local/go \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz
ENV GOPATH /home/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
