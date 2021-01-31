# Fixing dns4me hosts file for later version of Mikrotik RouterOS

***Archived because the issue is resovled on dns4me side***

This is a really quick and dirty fix, so not much hand-holding, although it's relatively straight-forwards if you know what you are looking at.

This is the original Mikrotik script:

```text
:global lastHostVersion
{
  :local versionUrl "https://dns4me.net/api/v2/get_hosts_file_version/GUID
  :local mikrotikUrl "https://dns4me.net/api/v2/get_hosts/mikrotik/GUID
  /tool fetch url=$versionUrl dst-path=host_version 
  :local hostVersion [/file get [/file find where name=host_version] contents]
  :log info "Curremt: $hostVersion"
  :log info "Previous: $lastHostVersion"
  :if ($hostVersion != $lastHostVersion) do={
    :log info "Removing old entries"
    :local staticDNSarray [/ip dns static find where ttl=1d1m]
    :if ([:len $staticDNSarray] != 0) do={
      :foreach i in=($staticDNSarray) do={
        /ip dns static remove $i
      }
    }
    /tool fetch url=$mikrotikUrl dst-path=host.rsc
    :log info "Adding new entries"
    /import host.rsc
    :log info "Done adding new entries"
    :global lastHostVersion $hostVersion
  } else={:log info "Host files does not need updating"}
}
```

It has stopped working in later RouterOS versions, because dns4me api generate "host" property for the script, where modern usage mandate "regexp" property.
Additionally, some of the generated sctrings are too long for Mikrotik to digest.

This repository provides a website that you can call instead of dns4me. The website will call dns4me for you, fix the returned script and return you the result.

~~I'm temporarely hosting a public version at `https://dns4me.bat.nz/hooks/dns4me`~~. To use it change the string in the script above from:

```text
  :local mikrotikUrl "https://dns4me.net/api/v2/get_hosts/mikrotik/GUID
```

to:

```text
  :local mikrotikUrl "https://dns4me.bat.nz/hooks/dns4me?guid=GUID
```

Make sure to use your own guid. (Use "Show Raw Hostfile API URL" button at <https://dns4me.net/user/hosts_file> to get it)

[traefik  subfloder](traefik) is for [traefik](https://traefik.io/traefik/) setup which is a reverse proxy that generates Let's Encrypt certificates for piblic hosting.
You will not need it for privately hosted version.

[dns4me-webhook subfolder](dns4me-webhook) is where the code for the service located. It's based on [WebHook](https://github.com/adnanh/webhook) open source project.
