- name: GF_AUTH_GENERIC_OAUTH_ENABLED
  value: true
- name: GF_AUTH_GENERIC_OAUTH_NAME
  value: Keycloak-OAuth
- name: GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP
  value: true
- name: GF_AUTH_GENERIC_OAUTH_CLIENT_ID
  value: grafana-oauth
- name: GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET
  value: qIv6DrJlCS1Xwo32bxK7vylyckNdH71u
- name: GF_AUTH_GENERIC_OAUTH_SCOPES
  value: openid email profile offline_access roles
- name: GF_AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_PATH
  value: email
- name: GF_AUTH_GENERIC_OAUTH_LOGIN_ATTRIBUTE_PATH
  value: username
- name: GF_AUTH_GENERIC_OAUTH_NAME_ATTRIBUTE_PATH
  value: full_name
- name: GF_AUTH_GENERIC_OAUTH_AUTH_URL
  value: https://keycloak.full-coral.cc/realms/test/protocol/openid-connect/auth
- name: GF_AUTH_GENERIC_OAUTH_TOKEN_URL
  value: https://keycloak.full-coral.cc/realms/test/protocol/openid-connect/token
- name: GF_AUTH_GENERIC_OAUTH_API_URL
  value: https://keycloak.full-coral.cc/realms/test/protocol/openid-connect/userinfo
- name: GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH
  value: contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'


# - name: server_http_addr
#   value: ""
# - name: server_http_port
#   value: 3000
# - name: server_enforce_domain
#   value: False
- name: server_domain
  value: grafana.full-coral.cc
- name: server_root_url
  value: https://grafana.full-coral.cc
- name: server_cert_key
  value: /etc/grafana/grafana_key.pem
- name: server_cert_file
  value: /etc/grafana/grafana_cert.pem
- name: server_protocol
  value: https