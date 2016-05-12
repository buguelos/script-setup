#!/bin/bash
echo "Instalando o firewall"
echo "#!/bin/bash
      #chkconfig: 2345 95 20
      #description: iptables rules to prevent communication on unused ports.


      #Reset all rules (F) and chains (X), necessary if have already defined iptables$
      iptables -t filter -F
      iptables -t filter -X

      #Start by blocking all traffic, this will allow secured, fine grained filtering
      iptables -t filter -P INPUT DROP
      iptables -t filter -P FORWARD DROP
      iptables -t filter -P OUTPUT DROP

      #Keep established connexions
      iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

      #Allow loopback
      iptables -t filter -A INPUT -i lo -j ACCEPT
      iptables -t filter -A OUTPUT -o lo -j ACCEPT
      #HTTP
      iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
      
      iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

      iptables -t filter -A OUTPUT -p tcp --dport 99 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 99 -j ACCEPT

      iptables -t filter -A OUTPUT -p tcp --dport 587 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 587 -j ACCEPT


      #FTP
      iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
      #SMTP
      iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
      iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
      #POP3
      iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
      iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
      #IMAP
      iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
      iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
      #ICMP
      iptables -t filter -A INPUT -p icmp -j ACCEPT
      iptables -t filter -A OUTPUT -p icmp -j ACCEPT
      #SSH
      iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
      iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT
      #DNS
      iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
      iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
      iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
      iptables -t filter -A INPUT -p tcp --dport 3306 -j ACCEPT
      iptables -t filter -A INPUT -p udp --dport 3306 -j ACCEPT
      iptables -t filter -A OUTPUT -p tcp --dport 3306 -j ACCEPT
      iptables -t filter -A OUTPUT -p udp --dport 3306 -j ACCEPT


 
      #NTP
      iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT
" > /etc/init.d/firewall

chmod 777 /etc/init.d/firewall
bash /etc/init.d/firewall
chkconfig firewall on
