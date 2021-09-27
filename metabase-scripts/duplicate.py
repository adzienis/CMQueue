from metabase_api import Metabase_API

mb = Metabase_API('http://localhost:3010', 'arthurdzieniszewski@gmail.com', \
        'Tadeusz1')  # if password is not given, it will prompt for password

print(mb)

