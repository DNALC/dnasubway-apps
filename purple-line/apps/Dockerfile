FROM qiime2/core:2017.7

COPY pl-import pl-import
COPY pl-denoise pl-denoise
COPY pl-corematrix pl-corematrix
COPY default_entrypoint.sh default_entrypoint.sh

# Install Agave CLI
RUN git clone https://bitbucket.org/agaveapi/cli.git /opt/bin/agave-cli && chmod -R a+r /opt/bin/agave-cli/bin && rm -rf /opt/bin/agave-cli/.git
ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/opt/bin/agave-cli/bin
# Automatically config root user for iplantc.org tenant
RUN /opt/bin/agave-cli/bin/tenants-init -t $AGAVE_TENANT

ADD run-pl-import.sh /opt/bin/
ADD run-pl-denoise.sh /opt/bin/
ADD run-pl-corematrix.sh /opt/bin/

#ENTRYPOINT ["./default_entrypoint.sh"]