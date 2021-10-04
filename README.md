Ansible role for installing and configuring the E2Guardian proxy

- Tested on Ubuntu 20.04
- Includes Nginx server for providing E2Guardian's SSL man-in-the-middle
  certificate (See `tasks/certs.yml`)

Example playbook:
```yaml
- hosts: all
  become: true
  gather_facts: true
  vars:
    # See defaults/main/main.yml
    e2g_install_dir: /opt/e2guardian

    # See defaults/main/filter_groups.yml
    e2g_filter_groups:
      - groupname: all
      - groupname: foo
        lists:
          banned_siteiplist:
            name: bannedsiteiplist
            content:
              - 1.2.3.4
              - 10.0.0.10
      - groupname: bar
        lists:
          banned_urllist:
            name: bannedurllist
            content:
              - site1.com/url
              - site2.com/url

    # See defaults/main/ip_groups.yml
    e2g_ipgroups:
      - 10.0.0.2 = filter2
      - 10.0.0.3 = filter3

    # See defaults/lists/
    e2g_bannedsitelist:
      - site1.com
      - site2.com
    e2g_bannedsiteiplist:
      - 10.10.10.10
    e2g_bannedurllist:
      - site.com/search
    e2g_exceptionsitelist:
      - gateway.reddit.com
    e2g_exceptionurllist:
      - reddit.com/r/ansible
    e2g_greysitelist:
      - accounts.google.com
    e2g_weightedphraseslist:
      - < NSFW ><30>
    e2g_exceptionphraselist:
      - < news ><-50>

  roles:
    - ansible-role-e2guardian

```
