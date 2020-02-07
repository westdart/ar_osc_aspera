#
# Filter functions defining naming standard for AMQ and Interconnect instances
#

def registry_entry(credentials, key):
    return credentials[key]

def get_pull_entry(credentials, registry):
    for entry in credentials[registry]:
        if 'operation' not in entry or entry['operation'] == 'pull':
            return entry
    return None

def get_push_entry(credentials, registry):
    for entry in credentials[registry]:
        if 'operation' in entry and entry['operation'] == 'push':
            return entry
    return None

def get_entry(credentials, registry, operation):
    if operation == 'pull':
        return get_pull_entry(credentials, registry)

    if operation == 'push':
        return get_push_entry(credentials, registry)


def registry_username(credentials, registry, operation = 'pull'):
    entry = get_entry(credentials, registry, operation)
    if 'username' in entry:
        return entry['username']
    return None

def registry_password(credentials, registry, operation = 'pull'):
    entry = get_entry(credentials, registry, operation)
    if 'password' in entry:
        return entry['password']
    if 'token' in entry:
        return entry['token']

def secret_name(credentials, registry, operation = 'pull'):
    entry = get_entry(credentials, registry, operation)
    if 'secret_name' in entry:
        return entry['secret_name']

class FilterModule(object):
    '''
    custom jinja2 filters for working with collections
    '''

    def filters(self):
        return {
            'registry_username': registry_username,
            'registry_password': registry_password,
            'secret_name': secret_name
        }

'''
Testing
'''
import unittest


class TestAppInstanceFilters(unittest.TestCase):
    credentials = {
        "docker-registry-default.t1.training.local": [
            {
                "secret_name": "t1-registry-credential",
                "token": "Grot",
                "username": "reggieperrin"
            },
            {
                "operation": "push",
                "secret_name": "t1-registry-push-credential",
                "token": "Great!",
                "username": "tonywebster"
            }
        ],
        "docker-registry-default.t2.training.local": [
            {
                "secret_name": "t2-registry-credential",
                "token": "Super!",
                "username": "davidharrisjones"
            },
            {
                "operation": "push",
                "secret_name": "t2-registry-push-credential",
                "password": "sunshinedeserts",
                "token": "I didn't get where I am today by ...",
                "username": "charlesjefferson"
            }
        ]
    }

    def test_registry_username1(self):
        self.assertEqual('reggieperrin', registry_username(self.credentials, 'docker-registry-default.t1.training.local'))

    def test_registry_username2(self):
        self.assertEqual('davidharrisjones', registry_username(self.credentials, 'docker-registry-default.t2.training.local'))

    def test_registry_username3(self):
        self.assertEqual('tonywebster', registry_username(self.credentials, 'docker-registry-default.t1.training.local', 'push'))

    def test_registry_username4(self):
        self.assertEqual('charlesjefferson', registry_username(self.credentials, 'docker-registry-default.t2.training.local', 'push'))

    def test_registry_password1(self):
        self.assertEqual('Grot', registry_password(self.credentials, 'docker-registry-default.t1.training.local', 'pull'))

    def test_registry_password1(self):
        self.assertEqual('Great!', registry_password(self.credentials, 'docker-registry-default.t1.training.local', 'push'))

    def test_registry_password3(self):
        self.assertEqual('Super!', registry_password(self.credentials, 'docker-registry-default.t2.training.local'))

    def test_registry_password4(self):
        self.assertEqual('sunshinedeserts', registry_password(self.credentials, 'docker-registry-default.t2.training.local', 'push'))


if __name__ == '__main__':
    unittest.main()
