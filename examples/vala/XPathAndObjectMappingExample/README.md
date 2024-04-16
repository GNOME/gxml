# XML Object mapping and xpath example 

## Output
```shell
 ❯❯❯ ./build/examples/vala/XPathAndObjectMappingExample/gxml
easy_way
Name    = Гонконгских долларов
Value   = 95.125200000000007
Nominal = 10
Hong Kong dollar to Russian ruble exchange rate = 9.51252


mapping_way
Hong Kong dollar to Russian ruble exchange rate = 9.51252
```

### Dependancies
 * Meson build system [Get Meson](https://mesonbuild.com/Getting-meson.html) (`pip3 install --user meson`, or through your distribution's pkg manager)
 * Vala Compiler [Deb based](https://packages.debian.org/search?keywords=valac), [Windows](https://wiki.gnome.org/Projects/Vala/ValaOnWindows)
 * GXml 0.20 [src](https://wiki.gnome.org/GXml)