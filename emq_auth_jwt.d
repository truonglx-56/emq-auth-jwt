src/em_plugin_mnesia.erl:: include/emq_acl_topic.hrl; @touch $@
src/emq_acl_jwt.erl:: include/emq_acl_topic.hrl; @touch $@
src/emq_auth_jwt.erl:: include/emq_auth_jwt.hrl src/emq_auth_jwt_cli.erl; @touch $@
src/emq_auth_jwt_app.erl:: include/emq_auth_jwt.hrl src/emq_auth_jwt_cli.erl; @touch $@
src/emq_auth_jwt_cli.erl:: include/emq_auth_jwt.hrl; @touch $@
src/emq_auth_jwt_sup.erl:: include/emq_auth_jwt.hrl; @touch $@

COMPILE_FIRST += emq_auth_jwt_cli
