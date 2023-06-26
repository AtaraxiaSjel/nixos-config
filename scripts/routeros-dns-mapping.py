#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3

import sys

def main():
    if len(sys.argv) < 2:
        sys.exit(1)
    tableFilename = sys.argv[1]
    outFilename = sys.argv[2]
    aRecordsList = []
    cnameRecordsList = []
    with open(outFilename, 'w') as outFile:

        with open(tableFilename, 'r') as file:
            while line := file.readline().rstrip():
                dns = line.split(' ')
                if 'disabled=yes' not in dns and 'name=router.lan' not in dns:
                    if 'type=CNAME' in dns:
                        name = [i for i in dns if i.startswith('name=')][0].split('=')[-1]
                        cname = [i for i in dns if i.startswith('cname=')][0].split('=')[-1]
                        cnameRecordsList.append(f'        "{name}" = "{cname}";')
                    else:
                        name = [i for i in dns if i.startswith('name=')][0].split('=')[-1]
                        address = [i for i in dns if i.startswith('address=')][0].split('=')[-1]
                        aRecordsList.append(f'        "{name}" = "{address}";')
        aRecordsList.sort()
        cnameRecordsList.sort()
        print('{', file=outFile)
        print('  dns-mapping = {', file=outFile)
        print('    customDNS = {', file=outFile)
        print('      mapping = {', file=outFile)

        for dns in aRecordsList:
            print(dns, file=outFile)

        print('      };', file=outFile)
        print('    };', file=outFile)
        print('    conditional = {', file=outFile)
        print('      mapping = { "pve" = "127.0.0.1"; };', file=outFile)
        print('      rewrite = {', file=outFile)

        for dns in cnameRecordsList:
            print(dns, file=outFile)

        print('      };', file=outFile)
        print('    };', file=outFile)
        print('  };', file=outFile)
        print('}', file=outFile)


if __name__ == '__main__':
    main()