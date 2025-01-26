inherit  extrausers

# This function will generate the password hash for the given password
def password_hash(d, password):
    import crypt
    import re
    passwd_hash = crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA256))
    return re.sub("\$", "\\$", passwd_hash)

ROOT_PASSWORD   ?= "root"

EXTRA_USERS_PARAMS  = "usermod -p '${@password_hash(d, '${ROOT_PASSWORD}')}' root;"
