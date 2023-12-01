# raspiserver

````
██████╗  █████╗ ███████╗██████╗ ██╗              
██╔══██╗██╔══██╗██╔════╝██╔══██╗██║              
██████╔╝███████║███████╗██████╔╝██║              
██╔══██╗██╔══██║╚════██║██╔═══╝ ██║              
██║  ██║██║  ██║███████║██║     ██║              
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝              
███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
````

## hide components

The function that registers a component does have an “admin only” flag: github link 84

By copying a component and making some minor modifications, I was able to do this. For instance, copy the component to you’re custom components folder:

cp -a /usr/src/homeassistant/homeassistant/components/history /config/custom_components/history

Open up manifest.json and add a version string:

{
  "version": "2022.07.23",
  "domain": "history",
  ... etc

Then open __init__.py and change:

frontend.async_register_built_in_panel(hass, "history", "history", "hass:chart-box")

to

frontend.async_register_built_in_panel(hass, "history", "history", "hass:chart-box", None, None, True)

And restart. This will keep the History panel in for admins, but remove it for users. If a user tries to access the /history URL, it redirects them to their main panel. I do not know if it blocks the API, however.

I have tested this with:

    History
    Map
    Media (media_source)

This will hold through upgrades, but if you want updates to the components, you may need to update them from source every now and again. I’ll probably write a script to automate this on upgrades.