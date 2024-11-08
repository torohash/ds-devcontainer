FROM python:3.12.5-bullseye

ARG USER_ID
ARG GROUP_ID
ARG USER_NAME
ARG PROJECT_ROOT

ENV PROJECT_ROOT=${PROJECT_ROOT}
ENV PYTHONPATH=${PAYTHONPATH}:${PROJECT_ROOT}

RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -m -u ${USER_ID} -g ${USER_NAME} ${USER_NAME}

RUN apt update && apt install git bash-completion tree -y && apt clean

# Gitのタブ補完有効化と__git_ps1コマンドの利用
RUN echo "source /usr/share/bash-completion/completions/git" >> /home/${USER_NAME}/.bashrc && \
    echo "source /etc/bash_completion.d/git-prompt" >> /home/${USER_NAME}/.bashrc

# プロンプトの設定
RUN echo "PROMPT_COMMAND='PS1_CMD1=\$(__git_ps1 \" (%s)\")'; PS1='\[\e[38;5;40m\]\u@\h\[\e[0m\]:\[\e[38;5;39m\]\w\[\e[38;5;214m\]\${PS1_CMD1}\[\e[0m\]\\$ '" >> /home/${USER_NAME}/.bashrc

# デフォルトシェルをbashに設定
RUN chsh -s /bin/bash ${USER_NAME}

USER ${USER_NAME}

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR ${PROJECT_ROOT}

RUN mkdir -p /home/${USER_NAME}/.jupyter/custom

COPY custom.css /home/${USER_NAME}/.jupyter/custom/custom.css