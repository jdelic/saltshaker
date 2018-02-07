#!pydsl

helpers = include('mn.users.helpers_py')
helpers.create_user('jonas',
                    groups=['jonas', 'sudo', 'gpg-access'],
                    password='$6$.640.DX/hbJyi$RuYeXF.3ruXdov0qvN07.1nkndThekULqJZEK2TFutW1/eHMxIbf39iTBXyXemWZkMX/7i7fwDlYG3P/OCGn8.',
                    key_pillars=['jm_symbiont_root', 'jm_symbiont_laptop', 'jm_gpg_agent_key', 'jm_iphone'],
                    enable_byobu=__pillar__.get('enable_byobu', {}).get('jonas', True))


