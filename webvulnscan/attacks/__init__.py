""" This modules provides various attacks and functions to run them. """
from .xss import xss
from .csrf import csrf
from .breach import breach
from .clickjack import clickjack


def AttackList():
    return [xss, csrf, breach, clickjack]


def drive_all(page, attacks, client):
    """ Drives every known attack against target. """

    for attack in attacks:
        attack(page, client)
