# utils on shell (for OSX)

## bin

### localip

To show `en0` local IP address and store the IP address to your clipboard by pbcopy.
This requires `gawk` (`brew install gawk`)

### globalip

This script requests `GET https://ip.ecp.plus` which returns request IP address.
And show the IP address and store it to your clipboard.

The endpoint is described here: https://memo.ecp.plus/ifconfig_by_api_gateway/

### tm

Open TMUX with pwd based socketname. Whenever you use `tm` command in the same directory, you will open the same session.
This requires `gawk` (`brew install gawk`)

## ec2-ip-addresses

This lists your AWS EC2 instance Tags and Global IP addresses by calling `aws ec2` command. So your environment needs AWS credential to call it.
This is implemented with Crystal. You also need crystal compiler.

### Compile

```
crystal build --release ec2-ip-addresses.cr
```

Then you can use `ec2-ip-addresses` binary.
