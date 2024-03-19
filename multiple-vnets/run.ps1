ssh azureuser@$env:VM_IP

# Now you can execute commands from our jumpbox
spoke1="http://10.1.0.4"
spoke2="http://10.2.0.4"
spoke3="http://10.4.0.4"
spoke4="http://10.5.0.4"

curl $spoke1
curl $spoke2
curl $spoke3
curl $spoke4

curl -X POST --data  "HTTP GET \"https://bing.com\"" "$spoke1/api/commands"
curl -X POST --data  "TCP 10.1.0.4 80" "$spoke1/api/commands"
curl -X POST --data  "TCP 10.2.0.4 80" "$spoke1/api/commands"

exit
