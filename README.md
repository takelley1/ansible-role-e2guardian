Ansible role for provisioning an E2Guardian filtering proxy.

- for Ubuntu Server.
- Includes Nginx server for distributing SSL man-in-the-middle certificate.

Example playbook:
```yaml
- hosts: all
  become: true
  gather_facts: true
  vars:
    e2g_build_package: true
    e2g_remove_build_dependencies: false
    e2g_filter_groups:
      - groupname: all_group
      - groupname: group1
        lists:
          banned_siteiplist:
            name: bannedsiteiplist_group1
            content:
              - 1.2.3.4
              - 5.6.7.8
      - groupname: group2
        lists:
          banned_sitelist:
            name: bannedsitelist_group2
            content: "{{ e2g_bannedsitelist }}"
      - groupname: group3
        lists:
          banned_urllist:
            name: bannedurllist_group3
            content:
              - site1.com/url
              - site2.com/url
    e2g_ipgroups:
      - 10.0.0.1 = filter1
      - 10.0.0.2 = filter2
      - 10.0.0.3 = filter3
    e2g_bannedsitelist:
      - site1.com
      - site2.com
    e2g_bannedregexurllist:
      - regex1
      - regex2
    e2g_bannedsiteiplist:
      - 1.2.3.4
      - 4.5.6.7
    e2g_bannedurllist:
      - site.com/search
    e2g_exceptionregexpurllist:
      - site4
      - site5
    e2g_exceptionsitelist:
      - gateway.reddit.com
    e2g_exceptionurllist:
      - reddit.com/login
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
