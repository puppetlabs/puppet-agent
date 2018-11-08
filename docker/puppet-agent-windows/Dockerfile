FROM microsoft/windowsservercore:1803 as builder

LABEL org.label-schema.maintainer="Puppet Windows Team <team-windows@puppet.com>" \
      org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.name="Puppet Agent (Windows)" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version=$PUPPET_AGENT_VERSION \
      org.label-schema.vcs-url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.vcs-ref="vcs_ref" \
      org.label-schema.build-date="build_date" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Dockerfile"

ARG base_url="https://downloads.puppetlabs.com/windows/puppet"
ARG major_version="6"
ARG file_name="puppet-agent-x64-latest.msi"
ARG master
ARG masterport

ENV base_url=$base_url
ENV major_version=$major_version
ENV file_name=$file_name
ENV master=$master
ENV masterport=$masterport

RUN mkdir c:\\dockerfiletemp

WORKDIR c:\\dockerfiletemp

COPY ./scripts ./scripts

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]



RUN $url = '' + $env:base_url + $env:major_version + '/' + $env:file_name; \
    write-Host 'Downloading From:' + $url; \
    (New-Object System.Net.WebClient).DownloadFile($url,$env:file_name); \
    Write-Host 'Installing'; \
    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/qn', '/L*V log.txt', '/i', $env:file_name -Wait -NoNewWindow; \
    Write-Host Done

FROM microsoft/windowsservercore:1803

COPY --from=builder ["c:/Program Files/Puppet Labs/","c:/Program Files/"]

COPY --from=builder ["c:/ProgramData/PuppetLabs/","c:/ProgramData/"]

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

RUN Move-Item 'c:\Program Files\Puppet' 'c:\Program Files\Puppet Labs'; \
    New-EventLog -Source Puppet -LogName Application -MessageResourceFile 'C:\Program Files\Puppet Labs\Puppet\bin\puppetres.dll' -CategoryResourceFile 'C:\Program Files\Puppet Labs\Puppet\bin\puppetres.dll'

RUN [Environment]::SetEnvironmentVariable('Path', ('C:\Program Files\Puppet Labs\bin;' + $env:Path), [System.EnvironmentVariableTarget]::Machine)

ENTRYPOINT while($true){Start-Sleep -Seconds 5}
