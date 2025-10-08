the project link https://roadmap.sh/projects/server-stats
the project link https://roadmap.sh/projects/log-archive-tool
the project link https://roadmap.sh/projects/nginx-log-analyser
the project link https://roadmap.sh/projects/ssh-remote-server-setup
the project link https://roadmap.sh/projects/basic-dockerfile
# SSH Server Setup on AWS EC2

This project demonstrates setting up a remote Linux server on AWS EC2 and configuring it to allow SSH connections using multiple key pairs.

## Project Overview

- **Platform**: AWS EC2
- **Operating System**: Ubuntu Server 22.04 LTS
- **Instance Type**: t2.micro (Free tier eligible)
- **Authentication**: SSH key pairs (2 keys configured)
- **Security**: fail2ban for brute force protection

## Prerequisites

- AWS account with appropriate permissions
- Terminal access (Linux/Mac) or Git Bash/WSL (Windows)
- Basic understanding of command line operations

## Step 1: Launch EC2 Instance

1. Log into AWS Console and navigate to EC2
2. Click **"Launch Instance"**
3. Configure instance settings:
   - **Name**: `my-ssh-server`
   - **AMI**: Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance Type**: t2.micro
   - **Key pair**: Create new key pair
     - Name: `aws-key1`
     - Type: ED25519
     - Format: `.pem`
     - **Download and save the key file**
4. **Network Settings**:
   - Create/use security group
   - Allow SSH traffic (port 22) from your IP
5. **Storage**: 8GB (default)
6. Click **"Launch Instance"**

## Step 2: Secure the First Key

Move the downloaded key to the `.ssh` directory and set proper permissions:

```bash
# Move key to .ssh directory
mv ~/Downloads/aws-key1.pem ~/.ssh/

# Set restrictive permissions (required by SSH)
chmod 400 ~/.ssh/aws-key1.pem
```

## Step 3: Initial Connection

Retrieve your EC2 instance's public IP from the AWS Console, then connect:

```bash
ssh -i ~/.ssh/aws-key1.pem ubuntu@YOUR-EC2-PUBLIC-IP
```

**Note**: Default username for Ubuntu AMI is `ubuntu`, not `root`.

## Step 4: Generate Second SSH Key

On your **local machine**, generate a second key pair:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/aws-key2
```

This creates two files:
- `~/.ssh/aws-key2` (private key - keep secret)
- `~/.ssh/aws-key2.pub` (public key - safe to share)

## Step 5: Add Second Key to EC2 Instance

1. Copy the public key content from your local machine:
```bash
cat ~/.ssh/aws-key2.pub
```

2. SSH into your EC2 instance with the first key:
```bash
ssh -i ~/.ssh/aws-key1.pem ubuntu@YOUR-EC2-PUBLIC-IP
```

3. Add the second public key to authorized keys:
```bash
echo "PASTE-YOUR-aws-key2.pub-CONTENT-HERE" >> ~/.ssh/authorized_keys
```

4. Verify permissions are correct:
```bash
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

## Step 6: Test Both Keys

Test connection with first key:
```bash
ssh -i ~/.ssh/aws-key1.pem ubuntu@YOUR-EC2-PUBLIC-IP
```

Test connection with second key:
```bash
ssh -i ~/.ssh/aws-key2 ubuntu@YOUR-EC2-PUBLIC-IP
```

Both should connect successfully.

## Step 7: Configure SSH Config File

Create/edit `~/.ssh/config` on your **local machine**:

```bash
nano ~/.ssh/config
```

Add the following configuration:

```
# AWS Server - Key 1
Host aws-server1
    HostName YOUR-EC2-PUBLIC-IP
    User ubuntu
    IdentityFile ~/.ssh/aws-key1.pem
    IdentitiesOnly yes

# AWS Server - Key 2
Host aws-server2
    HostName YOUR-EC2-PUBLIC-IP
    User ubuntu
    IdentityFile ~/.ssh/aws-key2
    IdentitiesOnly yes
```

Set proper permissions:
```bash
chmod 600 ~/.ssh/config
```

Now you can connect using simple aliases:
```bash
ssh aws-server1
# or
ssh aws-server2
```

## Step 8: Configure Security Group

Ensure your EC2 Security Group has the following inbound rule:

- **Type**: SSH
- **Protocol**: TCP
- **Port**: 22
- **Source**: Your IP address (recommended) or `0.0.0.0/0` (less secure)

To update:
1. Go to EC2 → Security Groups
2. Select your instance's security group
3. Edit inbound rules as needed

## Step 9: Harden SSH Configuration

SSH into your EC2 instance and edit the SSH daemon configuration:

```bash
sudo nano /etc/ssh/sshd_config
```

Ensure these settings are configured:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
X11Forwarding no
```

Restart SSH service to apply changes:
```bash
sudo systemctl restart sshd
```

## Step 10: Install fail2ban (Stretch Goal)

fail2ban protects your server from brute force attacks by monitoring logs and automatically blocking malicious IPs.

1. Update system and install fail2ban:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install fail2ban -y
```

2. Create local configuration file:
```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

3. Edit the configuration:
```bash
sudo nano /etc/fail2ban/jail.local
```

4. Add/modify these settings:
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
```

5. Start and enable fail2ban:
```bash
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

6. Check status:
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

## Verification Checklist

- [x] EC2 instance running Ubuntu 22.04 LTS
- [x] Can SSH with first key: `ssh -i ~/.ssh/aws-key1.pem ubuntu@EC2-IP`
- [x] Can SSH with second key: `ssh -i ~/.ssh/aws-key2 ubuntu@EC2-IP`
- [x] Can connect using alias: `ssh aws-server1`
- [x] Can connect using alias: `ssh aws-server2`
- [x] Security group restricts SSH access appropriately
- [x] Password authentication disabled
- [x] fail2ban installed and monitoring SSH attempts

## Security Best Practices

1. **Never share private keys** - Only `.pub` files should be on the server
2. **Use strong passphrases** - Add encryption layer to private keys
3. **Restrict Security Group** - Limit SSH access to your IP only
4. **Regular updates** - Keep your server patched: `sudo apt update && sudo apt upgrade`
5. **Monitor logs** - Check `/var/log/auth.log` for suspicious activity
6. **Backup regularly** - Create EC2 snapshots periodically
7. **Stop when not in use** - Stop (not terminate) instance to save costs

## Useful Commands

### Check fail2ban status
```bash
sudo fail2ban-client status sshd
```

### View banned IPs
```bash
sudo fail2ban-client status sshd
```

### Unban an IP
```bash
sudo fail2ban-client set sshd unbanip IP-ADDRESS
```

### View SSH authentication logs
```bash
sudo tail -f /var/log/auth.log
```

### Check SSH service status
```bash
sudo systemctl status sshd
```

## AWS Cost Considerations

- **t2.micro** is free tier eligible (750 hours/month for 12 months)
- **Stop** your instance when not in use to avoid charges
- Elastic IPs are free when associated with a running instance
- Data transfer has limits on free tier

## Troubleshooting

### Permission denied (publickey)
- Check key file permissions: `chmod 400 ~/.ssh/your-key.pem`
- Verify you're using the correct username (`ubuntu` for Ubuntu AMI)
- Ensure the public key is in `~/.ssh/authorized_keys` on the server

### Connection timeout
- Check Security Group allows SSH from your IP
- Verify instance is running
- Check if your IP has changed (restart router, VPN, etc.)

### fail2ban not blocking
- Check fail2ban is running: `sudo systemctl status fail2ban`
- Review logs: `sudo tail -f /var/log/fail2ban.log`
- Verify jail is enabled: `sudo fail2ban-client status`

## Next Steps

- Create a non-root user for daily operations
- Configure automatic security updates
- Set up monitoring with CloudWatch
- Implement additional hardening measures
- Practice server administration tasks

## Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [SSH Key Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- [fail2ban Documentation](https://www.fail2ban.org/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

---

**Important**: Never commit private keys to version control. This README should be the only file in your repository.
