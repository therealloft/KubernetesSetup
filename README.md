# KubernetesSetup

Hopefully an Easy Setup

The install assumes you already have docker installed on your server

```
wget https://raw.githubusercontent.com/therealloft/KubernetesSetup/main/Setup.sh
```
```
chmod +x Setup.sh
```
```
./Setup.sh
```

It will first ask if you want the current server to be a control node

if you select yes it will complete the full install and bootup

if you select no it will then ask for you join string
!IMPORTANT the string must be in a single line

```
EXAMPLE
join 0.0.0.0:6443 --token xxxxxx.xxxxxxxxxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Now you should have a cluster all setup
