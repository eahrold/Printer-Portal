##Give your clients access to printers.

In a world of lap tops the challenges of granting access to numerous printers in multiple locations is fairly challenging. Historically there have been a few ways to configure client computers to handle this.  

1. Add all of the printers to the printers to client and tell them to choose the right one in the print dialog. But this only works if the clients have the printer installed. And long lists are always a pain.

2. Manage with Active/Open Directory, but the syntax of configuring printers that way cumbersome, and prone mis-configuration. Plus again you're left with a long list in the print dialog. And this technique is of no use when your clients aren't bound

3. Put up a README with instructions on how to add the printers.

-

**Here's the Printer Portal solution.**

1. Send your client a link to download and install the Printer Portal client.  

2. Send them a message with a clickable link such as this [printerinstaller://your.server.com/printers/subset](printerinstaller://your.server.com/printers/printerlist) to the server hosting a plist with printers.

3. Have the client choose the printer to add from the status menu item.