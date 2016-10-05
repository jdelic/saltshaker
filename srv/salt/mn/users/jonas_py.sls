#!pydsl

helpers = include('mn.users.helpers_py')
helpers.create_user('jonas',
                    groups=['jonas', 'sudo', 'gpg-access'],
                    password='$6$gJxWZeEGRWbq$78IiQarKX5cA9o/y.mwnLc8MzI3xxGP2gQ5cpcN5z25yGUEKTmFZapR5Lpg.zme0bAkPxFOmSfVY8b0G.eH4m1',
                    key_pillars=['jm_symbiont_root', 'jm_symbiont_laptop', 'jm_gpg_agent_key'])


