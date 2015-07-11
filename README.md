##Give your clients access to printers.

In a world of laptops the challenge of granting access to numerous printers in multiple locations can be daunting. Historically there have been a few ways to configure client computers to handle this.  

* Have some sort of shell script (i.e. .pkg postinstall) that will add all of the printers to the machine and then have the client to choose the right one in the print dialog. But when there are 10-20+ printers potentially available that can easily get confusing.

* Manage with Active/Open Directory, but the syntax of configuring printers that way cumbersome, and prone mis-configuration. Additionally this technique is of no use when your clients aren't bound. Another issue is that it only shows the printers in the "Add Printers" dialog, and does nothing to help install the printers, and the list can be confusing when mixed with bonjour printers, or printers re-shared from local clients.

* You could do it with puppet, munki on, casper, or configuration profiles, but again only if the clients are tied to the deployment, which may not always be the case. 
 
* Put up a help page with instructions on how to add the printers. LPD? IPP? Sockets? Ports? 

-

###Enter Printer Portal.

1. Send your client a link to download and install the Printer Portal client.  

1. Send them a message with a clickable link such as this [printerportal://your.server.com/printers/printerlist](printerportal://your.server.com/printers/printerlist) to the web host.
	
1. Have the client choose the printer to add from the status menu item.

-

### Configuration:
- There are a few ways a host can provide the printer lists
	1. By serving a static Apple Property List formatted XML file
	2. Generating JSON Data by any means 
		- The server must set an acceptable MIME type for the "Content-Type" header of the response. Either `application/json`, `text/json` or `text/javascript`
	3. Using the companion [__P__rinter __P__ortal __S__erver](https://github.com/eahrold/printer_portal_server)
	
- *note: The Printer Portal client app will convert the "printerportal" string to "http" so to have requests directed to a secure server the scheme would be `printerportals`*  

__Serialized Printer Keys:__  
- Required
	* __printer__ : The name for the printer. 
	* __host__ : IP address or FQDN for the CUPS server.
	* __model__ :	 model name, use lpinfo -m to get an appropriate model string
	* __protocol__ : currently acceptable options are ipp, ipps, lpd, http, https, socket

- Optional

	* __ppd__	: A url where a PPD can be download from a web server.
	* __location__:	Location of the printer
	* __description__ :	Alternative discription for the user
	* __options__ :	Array strings of options conforming to lpoptions syntax, `PrinterOpt=Value`


__Example XML File:__
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>printerList</key>
	<array>
		<dict>
			<key>printer</key>
				<string>main_printer</string>
			<key>protocol</key>
				<string>ipp</string>
			<key>host</key>
				<string>your.printserver.com</string>
			<key>description</key>
				<string>Main Printer</string>
			<key>location</key>
				<string>First Floor</string>
			<key>model</key>
			<string>Brother DCP-8250DN CUPS</string>
				<key>ppd</key>
			<string>http://your.server.com/ppd/bdcp-8250dn.gz</string>
		</dict>
		<dict>
			<key>description</key>
			<string>Another Printer</string>
			<key>location</key>
			<string>CMMN 332</string>
			<key>model</key>
			<string>HP LaserJet 4250</string>
			<key>ppd</key>
			<string>http://your.server.com/ppd/hplj.4250.gz</string>
			<key>printer</key>
			<string>comm_office</string>
			<key>protocol</key>
			<string>socket</string>
			<key>host</key>
			<string>192.168.2.1</string>
		</dict>
		<dict>
			<key>description</key>
			<string>Honcho's Printer</string>
			<key>location</key>
			<string>Boss's Office</string>
			<key>model</key>
			<string>HP LaserJet 4250</string>
			<key>printer</key>
			<string>boss_printer</string>
			<key>protocol</key>
			<string>lpd</string>
			<key>host</key>
			<string>192.168.2.101</string>
		</dict>
	</array>
</dict>
</plist>
```

__Example JSON:__

```json
{
    "printerList": [
        {
            "name": "main_printer", 
            "description": "Main Printer", 
            "host": "pretendo.com", 
            "protocol": "ipp", 
            "location": "Living Room", 
            "model": "HP Color Laser Jet CP3525", 
            "ppd_file": null, 
            "options": [
                "TRAY_3=YES"
            ]
        }, 
        {
            "name": "bosss_printer", 
            "description": "Boss's Printer", 
            "host": "pretendo.com", 
            "protocol": "lpd", 
            "location": "Boss's Office", 
            "model": "HP 4250", 
            "ppd_file": null, 
            "options": []
        }
    ], 
}
```
