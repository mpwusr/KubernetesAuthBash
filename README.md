## Kubernetes Auth Bash script
# How to Run
# Make it executable:

```
chmod +x getkubetoken.sh
```
# Then run:

```
./getkubetoken.sh my-namespace my-sa https://api.openshift.example.com:6443 $(oc whoami -t) /path/to/ca.crt
```
