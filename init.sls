{%- set hostname = salt['grains.get']('host') -%}
{%- set hostname_apps_dict = hostname, "_apps" -%}
{%- set hostname_apps = (hostname_apps_dict|join) -%}

{%- set gitlab_version = pillar[hostname_apps]['gitlab']['version'] -%}
gitlab-ppa:
  pkgrepo.managed:
    - humanname: GitLab
    - name: deb https://packages.gitlab.com/gitlab/gitlab-ce/debian/ {{ gitlab_version }} main
    - dist: jessie
    - file: /etc/apt/sources.list.d/gitlab-ce.list
    - gpgcheck: 1
    - key_url: https://packages.gitlab.com/gpg.key 

gitlab-ce:
  pkg:
    - installed
    - requiere: gitlab-ppa

/etc/gitlab/gitlab.rb:
  file:
  - managed
  - source: salt://gitlab/gitlab.rb
  - user: root
  - group: root
  - mode: 600
  - template: jinja

gitlab-ctl reconfigure ; touch /etc/gitlab/configured_flag:
  cmd.run:
    - creates: /etc/gitlab/configured_flag
    - requiere: gitlab-ce
