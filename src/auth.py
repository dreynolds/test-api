from jose import jwt, exceptions
import requests


def get_keys(iss):
    """
    Get list of keys from IDP
    """
    url = '{}/.well-known/jwks.json'.format(iss)
    resp = requests.get(url)
    if resp.ok:
        keys = resp.json()
    else:
        keys = {}
    return keys.get('keys', [])


def find_public_key(kid, iss):
    """
    Find the actual key we want
    """
    keys = get_keys(iss)
    public_key = None
    for key in keys:
        if kid == key['kid']:
            public_key = key
            break
    return public_key


def decode_jwt(token):
    unverified_claims = jwt.get_unverified_claims(token)
    unverified_headers = jwt.get_unverified_headers(token)
    public_key = find_public_key(
        unverified_headers['kid'],
        unverified_claims['iss'],
    )

    try:
        decoded_key = jwt.decode(
            token,
            key=public_key,
            options={'verify_aud': False},
        )
    except exceptions.JWTError:
        decoded_key = {}

    return decoded_key
