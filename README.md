**Reconnection Timer for OHP and SSHPLUS Proxy**

    Usage:
    Reconnection Timer by @pigscanfly | Version: 0.0.1
      -service string
            Service to be restarted
      -timer int
            Reconnection Timer
### **Reconn**  
    ./reconn -service=ohpserver -timer=55      

### **Setup reconnection-timer as a service**   
    wget https://raw.githubusercontent.com/stein-dev/reconnection-timer/main/setup-timer.sh
    chmod 755 setup-timer.sh
    ./setup-timer.sh
    
### **Setup ohp for ssh** 
    wget https://raw.githubusercontent.com/stein-dev/reconnection-timer/main/setup-ohp-ssh.sh
    chmod 755 setup-ohp-ssh.sh
    ./setup-ohp-ssh.sh   
