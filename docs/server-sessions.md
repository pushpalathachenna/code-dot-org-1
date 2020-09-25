# Server sessions

Shell access to managed application servers is controlled by [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html), which uses AWS credentials to start new shell sessions through the [`StartSession`](https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_StartSession.html) API command.

## AWS Console access

You can connect to a server from your browser through the [Amazon EC2 console](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#start-ec2-console) by clicking the 'Connect' button from the EC2 Instances page.

## Command-line Access

In order to connect to a Session Manager Session using the AWS Command Line Interface, you need to first [install the plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html). (You may also need to [install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) or upgrade to v1.16.12 or later.)

To connect to an named EC2 instance using the CLI, you can use the [`ssm`](../bin/ssm) helper script, which will help start a running instance by Name (tag).

(Optional) You may also install the [`ssm-completion`](../bin/ssm-completion) bash completion script by copying it into the `bash-completion` config directory (e.g., `/etc/bash_completion.d/`). The script will enable tab-completion on `ssm` for all running EC2 instance-ids and Name (tag) values.

## Port Forwarding

### Background

[Port Forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding) is an SSH feature that allows you to use a session as a tunnel for traffic to arbitrary services (e.g., a database listening on port 3306, or an HTTP server listening on port 80), on any host the remote server can access over its network. Port forwarding is typically used to control access to services not exposed to the public Internet by routing traffic forwarded over SSH through a central [Bastion Host](https://en.wikipedia.org/wiki/Bastion_host), that authorizes incoming SSH connections and has access to services on the internal network.

### Port Forwarding in Session Manager

With Session Manager you can start a port-forwarding session to an EC2 instance directly. Session Manager supports Port Forwarding with a special `AWS-StartPortForwardingSession` document.

## SSH Connections

Session Manager also [supports SSH connections](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html) by forwarding the SSH port (22) through a Session Manager connection. (This may be needed for copying files from an EC2 instance via `scp`, for example.) AWS provides a special `AWS-StartSSHSession` document configured for this specific purpose.

The best way to configure SSH access throguh Session Manager is to add an entry in your local ssh config (`~/.ssh/config`) with a `ProxyCommand` that calls `aws ssm start-session`:

```ssh
# SSH over Session Manager
host i-* mi-*
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
  User ubuntu
  IdentityFile ~/.ssh/server_access_key

  # Any SSH Port Forwarding configuration will also work here, e.g.:
  LocalForward 3307 db-reporting.code.org:3306
  LocalForward 8080 localhost:8080
```

With this configuration, as long as the AWS CLI and Session Manager Plugin is installed, all you need to do is run `ssh [instance-id]` and it should establish a typical SSH connection to the remote instance as before. (Note however that you still need to provide a `server_access_key` for SSH access.)
