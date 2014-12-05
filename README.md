omniauth-coinbase-discourse
===========================

Use Coinbase OAuth to log in to Discourse

##On a Discourse Docker installation
In containers/app.yml, add this repo under the hooks section:
```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/coinbase/omniauth-coinbase-discourse.git
```

Then `./launcher rebuild app`

##On a standalone Rails installation
In the discourse/plugins directory, clone this repo and restart the server
