
# docker build --rm -t dnasubway-pl-201712 .
FROM qiime2/core:2017.12

RUN apt-get install -y unzip tree

# add non-root user
RUN useradd -m dnalc

# Install Agave CLI
RUN git clone https://bitbucket.org/agaveapi/cli.git /opt/bin/agave-cli \
    && chmod -R a+r /opt/bin/agave-cli/bin \
    && rm -rf /opt/bin/agave-cli/.git

ADD run-pl-*.sh default_entrypoint.sh /opt/bin/
RUN chmod a+x /opt/bin/*.sh

#USER dnalc

ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/opt/bin/agave-cli/bin

# Automatically config $USER for iplantc.org tenant
RUN /opt/bin/agave-cli/bin/tenants-init -t $AGAVE_TENANT

#ENTRYPOINT ["/opt/bin/default_entrypoint.sh"]
