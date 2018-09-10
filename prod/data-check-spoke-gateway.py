import requests
import json
import os
import subprocess
import sys
import time

requests.packages.urllib3.disable_warnings()

### Using the new REST API and dumping the results only
### This meant to run in onprem linux

good=[]
bad=[]
max_spokes=6

def ping_return_code(hostname):
    """Use the ping utility to attempt to reach the host. We send 5 packets
    ('-c 5') and wait 3 milliseconds ('-W 3') for a response. The function
    returns the return code from the ping utility.
    """
    ret_code = subprocess.call(['ping', '-c', '2', '-W', '3', '-s', '408', '-p', '1234ffff2222',  hostname],
                               stdout=open(os.devnull, 'w'),
                               stderr=open(os.devnull, 'w'))
    print("ping_return_code: hostname: %s : ret_code %s" % (hostname,ret_code))
    if ret_code:
        bad.append(hostname)
        print("BAD ret_code %s" % (ret_code))
    else:
        good.append(hostname)
    return ret_code

def verify_hosts(host_list):
    """For each hostname in the list, attempt to reach it using ping. Returns a
    dict in which the keys are the hostnames, and the values are the return
    codes from ping. Assumes that the hostnames are valid.
    """
    return_codes = dict()
    #print("host_list: %s" % host_list)
    for hostname in host_list:
        return {hostname: ping_return_code(hostname) for hostname in host_list}

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: data-check-spoke-gateway.py <controller> <transit_gateway_name> \n')
        print('Usage: python3 data-check-spoke-gateway.py 52.53.113.44 canada-transit\n')
        print('Usage: python3 data-check-spoke-gateway.py 13.57.159.116 colby-transit-GW\n')
        exit(1)

    controller_ip = sys.argv[1]
    transit_gateway_name = sys.argv[2]

    # Script Config 
    #controller_ip = "52.53.113.44"
    url = "https://" + controller_ip + "/v1/api"
    admin_password = "Aviatrix123!"

    # Login and Get CID
    print("\nLogin and Get CID...")
    data = {
	"action": "login",
	"username": "admin",
	"password": admin_password
    }

    response = requests.post(url=url, data=data, verify=False)
    pydict = response.json()
    #print(json.dumps(pydict, indent=4))

    # Get CID if login successfully
    CID = ""
    if pydict["return"] == True:
    	CID = pydict["CID"]
    # END IF

    # Call REST API "run_gateway_ping_diagnostic" 
    print("\nList attached spoke gateways from transit gateway \"transit_gateway_name\" ")
    print("user input [" + transit_gateway_name + "]")
    print("===================>>>>")
    data = {
	"action": "list_vpcs_summary",
	"CID": CID,
	"account_name": "admin",
    }
    elapse=0
    max_retry=1
    gateway = {}
    for i in range(int(max_retry)):
        response = requests.post(url=url, data=data, verify=False)
        pydict = response.json()
        #print(json.dumps(pydict, indent=4))
        #exit(0)

        parseReason=pydict['results']
        parseReturn=pydict['return']
        if parseReturn == 'false':
           print (parseReason)
           exit(1)

        print("Checklist Total spoke gateway attached to VGW: [%d]  !!!" % len(pydict['results']))
        for private in pydict['results']:
            #print("Gateway => %s Private IP %s: " % (private['vpc_name'],private['private_ip']))
            gateway.update({private['vpc_name']:private['private_ip']})
            #print("Private IP: %s" % str(private))

        print ("=========");
        for keys,values in gateway.items():
            print("Gateway: %s, Private IP: %s" % (keys,values))
        ##exit(0)

        # Call REST API 

        print("List attached spoke gateways from transit gateway : %s " % transit_gateway_name)
        data = {
            "action": "list_attached_spoke_gateways",
            "CID": CID,
            "transit_gateway_name": transit_gateway_name,
        }
        response = requests.post(url=url, data=data, verify=False)
        pydict = response.json()
        print(json.dumps(pydict, indent=4))
        #exit(0)

        parseReturn=pydict['return']
        if parseReturn == 'false':
           print (parseReason)
           exit(1)
        parseReason=pydict['results']

        gateway_list=[]
        for p in pydict['results']['spoke_gw_lst']:
            gw1=p['gw']
            gw1ha=p['ha']
            gateway_list.append(gateway[gw1])
            #if gw1 in my_list and gw1ha == 'yes':
            if gw1ha == 'yes':
                print("Checklist  [%s] [%s vs yes]  retry count:%d ... %s phase1 passed !!!" % (gw1,gw1ha,i,gateway[gw1]))
            else:
                print("Checklist  [%s] [%s vs yes]  retry count:%d ... phase1 failed !!!" % (gw1,gw1ha,i))
                exit(1)
        if len(pydict['results']['spoke_gw_lst']) != max_spokes:
            print("Missing spoke gateway attached to VGW: [%d] vs. %s !!!" % (len(pydict['results']['spoke_gw_lst']),max_spokes))
            exit(1)

        print(verify_hosts(gateway_list))
        print("Good spoke gateways: %s" % good)
        print("Bad spoke gateways: %s" % bad)
        # since it goes all the way it means passed all the checks
        print("All expected spoke gateways correctly attached to transit gateway")
        print("Checklist Total spoke gateway attached to VGW: [%d]  !!!" % len(pydict['results']['spoke_gw_lst']))
        print("-----------------------------------------------------------------")
        #print("Checklist transit gateway [%s vs canada-transit] [%s vs HA enabled]  retry count:%d ... Passed !!!" % (my_transit,my_transithagw,i))
        #print("Elapsed Time: %s sec" % elapse)
        if bad:
            print("ERROR ..... FAILED !!!")
            exit(1)
            
        else:
            print("Forwarding is good ..... PASSED !!!")
            exit(0)

