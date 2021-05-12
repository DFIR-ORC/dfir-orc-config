# DFIR ORC Configuration

To configure DFIR ORC, you need:
* configuration files in XML format, located in the "config" directory
* items to embed (especially DFIR-Orc binaries in 32 and 64 bits), stored in the "tools" directory

The configurations given as example here use several Sysinternals tools, DumpIt and WinPmem. You have to download and copy them in the "tools" directory.

The "tools" directory must therefore contain the following files:
* DFIR-Orc_x64.exe
* DFIR-Orc_x86.exe
* autorunsc.exe
* handle.exe
* Tcpvcon.exe
* PsService.exe
* Listdlls.exe
* DumpIt.exe
* winpmem.exe

Finally, to generate a configured DFIR-Orc executable, you have to run the ".\Configure.cmd" script (on a Windows system, **from an elevated command prompt**).
The generated binary is created in the "output" directory.


## Authors and contributors

Authors and contributors are the same as listed in the [AUTHORS file of GitHub repository of the source code](https://github.com/dfir-orc/dfir-orc/blob/master/AUTHORS.txt).

## About configurations and personal data

Using DFIR ORC with the configurations provided here can entail the presence of personal data (e.g. email addresses, IP, etc.) in the resulting archives. These have to be dealt with in compliance with any legal requirements which may apply, in particular the General Data Protection Regulation (GDPR) (regulation UE 2016/679) and the resulting national regulations.

These configurations are provided as examples, and must be adapted to each concrete use case. This can be done by modifying the configurations themselves (see tutorial : https://dfir-orc.github.io/tuto.html), or by activation and deactivation of parts of the archive computation, or even computation of whole archives (see option /key in https://dfir-orc.github.io/cli-options.html).


## License 


The contents of this repository is available under [open licence 2.0](open-licence.md).

The name DFIR ORC and the associate logo belongs to ANSSI, no use is permitted without its express approval.

## A propos des configurations et des données personnelles

En utilisant DFIR ORC avec les configurations fournies ici, vous êtes susceptibles de collecter des données à caractère personnel (notamment des adresses IP, adresses de messagerie électronique, etc...). Ces données devront par conséquent être traitées conformément à la réglementation en vigueur sur la protection des données à caractère personnel, et notamment le règlement général sur la protection des données (RGPD) (réglement UE 2016/679) et, en France, la loi n° 78-17 du 6 janvier 1978 relative à l'informatique, aux fichiers et aux libertés.

Ces configurations sont données à titre d'exemple et doivent être adaptées à chaque cas de collecte, soit en modifiant les configurations elles-mêmes (voir tutoriel https://dfir-orc.github.io/tuto.html), soit en activant ou désactivant le calcul de parties d'archives ou d'archives complètes (voir documentation des options /key : https://dfir-orc.github.io/cli-options.html).

## Licence

Le contenu de ce dépôt est disponible sous la licence "LICENSE OUVERTE 2.0", disponible [ici](LICENSE-OUVERTE.md).

Le nom DFIR ORC et le logo associé appartiennent à l'ANSSI, aucun usage n'est permis sans autorisation expresse.


