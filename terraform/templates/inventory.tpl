[app_servers]
app_server ansible_host=${app_server_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path} ansible_python_interpreter=/usr/bin/python3

[app_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
backend_repo=${backend_repo}
frontend_repo=${frontend_repo}
git_branch=${git_branch}

