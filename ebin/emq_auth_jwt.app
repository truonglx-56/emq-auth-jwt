{application, emq_auth_jwt, [
	{description, "Authentication with JWT,ACL with MySQL"},
	{vsn, "1.0.0"},
	{id, "dccbeb3-dirty"},
	{modules, ['em_plugin_mnesia','emq_acl_jwt','emq_auth_jwt','emq_auth_jwt_app','emq_auth_jwt_cli','emq_auth_jwt_sup','emq_plugin_chat','verify_token']},
	{registered, [emq_auth_jwt_sup]},
	{applications, [kernel,stdlib,mysql,ecpool,jose,jsx]},
	{mod, {emq_auth_jwt_app, []}}
]}.