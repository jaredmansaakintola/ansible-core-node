# To run this docker ansible image on a specific playbook
# docker run --rm -it -v $(pwd):/ansible/playbooks name_of_image playbook.yml
# To run this docker ansible image with external containers
# docker run --rm -it -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub -v $(pwd):/ansible/playbooks name_of_image playbook.yml

FROM alpine:3.10

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    \
    \
    echo "===> Adding Python runtime..."  && \
    apk --update add python py-pip openssl ca-certificates    && \
    apk --update add --virtual build-dependencies \
                python-dev libffi-dev openssl-dev build-base  && \
    pip install --upgrade pip cffi                            && \
    \
    \
    echo "===> Installing Ansible..."  && \
    pip install ansible==2.8.1         && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    pip install --upgrade pywinrm                  && \
    apk --update add sshpass openssh-client rsync  && \
    \
    \
    echo "===> Removing package list..."  && \
    apk del build-dependencies            && \
    rm -rf /var/cache/apk/*               && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible                        && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts && \
    echo "[local:vars]" >> /etc/ansible/hosts && \
    echo "ansible_connection=local" >> /etc/ansible/hosts && \
    echo "ansible_python_interpreter=/usr/bin/python3" >> /etc/ansible/hosts

RUN apk --no-cache --update add \
        bash \
        py-dnspython \
        py-boto \
        py-netaddr \
        bind-tools \
        html2text \
        php7 \
        php7-json \
        git \
        jq \
        curl

RUN pip install --no-cache-dir --upgrade yq

RUN pip install --no-cache-dir --upgrade mitogen

RUN mkdir -p /ansible/playbooks

WORKDIR /ansible/playbooks

#VOLUME . /ansible/playbooks
COPY ./deploy.yml /ansible/playbooks/deploy.yml
#COPY ./inventory.yml /ansible/playbooks/inventory.yml

# default command: display Ansible version
ENTRYPOINT [ "ansible-playbook" ]
CMD [ "--version" ]
#CMD [ "sh", "-c", "echo $PATH" ]
