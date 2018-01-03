FROM qiime2/core:2017.8

RUN apt-get install -y unzip tree

# Install Agave CLI
RUN git clone https://bitbucket.org/agaveapi/cli.git /opt/bin/agave-cli && chmod -R a+r /opt/bin/agave-cli/bin && rm -rf /opt/bin/agave-cli/.git

ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/opt/bin/agave-cli/bin

# Automatically config root user for iplantc.org tenant
RUN /opt/bin/agave-cli/bin/tenants-init -t $AGAVE_TENANT

ADD run-pl-*.sh default_entrypoint.sh /opt/bin/

#ENTRYPOINT ["/opt/bin/default_entrypoint.sh"]

