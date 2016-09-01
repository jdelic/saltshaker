#!pydsl

helpers = include('mn.users.helpers_py')
helpers.create_user('vagrant',
                    groups=['vagrant', 'sudo', 'gpg-access'],
                    optional_groups=['docker'],
                    password='$6$plNx100g4$1hUWVUCI67V926UrcOrCDYz4.LK4IE.nTois.P42J7wAn1IYn65KpTR1E7zQl.WYj1w/7Qli07AWb0IueHMJU1',
                    keys=['vagrant'])
