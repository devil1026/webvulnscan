""" This modules provides various attacks and functions to run them. """
from .xss import xss
from .csrf import csrf
from .breach import breach
from .clickjack import clickjack
from .cookiescan import cookiescan
from .exotic_characters import exotic_characters
from .broken_unicode_characters import broken_unicode_characters


<<<<<<< HEAD
def AttackList():
=======
def all_attacks():
>>>>>>> 1ecc311467deca2de2bde86be085a965270fe95e
    return [xss, csrf, breach, clickjack, cookiescan, exotic_characters,
            broken_unicode_characters]


def drive_all(page, attacks, client):
    """ Drives every known attack against target. """

    for attack in attacks:
        attack(page, client)
