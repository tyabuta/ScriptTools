#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Bitbucket API wrapper.  Written to be somewhat like py-github:

https://github.com/dustin/py-github

"""
import datetime
import hashlib
import re
import time
from functools import wraps
from urllib2 import Request, urlopen, URLError
from urllib import urlencode

try:
    import json
    assert json  # silence pyflakes
except ImportError:
    import simplejson as json


__all__ = ['AuthenticationRequired', 'to_datetime', 'BitBucket']

api_base = 'https://api.bitbucket.org/1.0/'
api_toplevel = 'https://api.bitbucket.org/'


class AuthenticationRequired(Exception):
    pass


def requires_authentication(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        username = self.bb.username if hasattr(self, 'bb') else self.username
        password = self.bb.password if hasattr(self, 'bb') else self.password
        if not all((username, password)):
            msg = "{0} requires authentication".format(method.__name__)
            raise AuthenticationRequired(msg)
        return method(self, *args, **kwargs)
    return wrapper


def smart_encode(**kwargs):
    """Urlencode's provided keyword arguments.  If any kwargs are None, it does
    not include those."""
    args = dict(kwargs)
    for k, v in args.items():
        if v is None:
            del args[k]
    if not args:
        return ''
    return urlencode(args)


def to_datetime(timestring):
    """Convert one of the bitbucket API's timestamps to a datetime object."""
    format = '%Y-%m-%d %H:%M:%S'
    timestring = timestring.split('+')[0].strip()
    return datetime.datetime(*time.strptime(timestring, format)[:7])


class BitBucket(object):
    """Main bitbucket class.  Use an instantiated version of this class
    to make calls against the REST API."""
    def __init__(self, username='', password=''):
        self.username = username
        self.password = password
        # extended API support

    def _loads(self, url):
        """ fetch the url and parse the json result """
        try:
            return json.loads(self.load_url(url))
        except ValueError:
            msg = "Could not parse JSON result from {0}".format(url)
            raise URLError(msg)

    def build_request(self, url, data=None):
        if not all((self.username, self.password)):
            return Request(url, data)
        auth = '{0}:{1}'.format(self.username, self.password)
        auth = auth.encode("base64").strip()
        auth = {'Authorization': 'Basic {0}'.format(auth)}
        if data:
            data = urlencode(data)
        return Request(url, data, auth)

    def load_url(self, url, quiet=False, method=None, data=None):
        """NOTE: Raises urllib2.HTTPError if something goes wrong (eg 404)"""
        request = self.build_request(url, data)
        if method:
            request.get_method = lambda: method
        result = urlopen(request).read()
        return result

    def user(self, username):
        return User(self, username)

    def repository(self, username, slug):
        return Repository(self, username, slug)

    @requires_authentication
    def new_repository(self, name, **data):
        """Create a new repository with the given name for the authenticated
        user. Returns a Repository object
        """
        url = api_base + 'repositories/'
        data['name'] = name
        response = json.loads(self.load_url(url, data=data))
        if 'slug' in response:
            return self.repository(self.username, response['slug'])

    @requires_authentication
    def remove_repository(self, slug):
        """Given a slug, remove a repository from the authenticated user"""
        url = api_base + 'repositories/{0}/{1}'.format(self.username, slug)
        method = 'DELETE'
        self.load_url(url, method=method)
        return True

    @requires_authentication
    def emails(self):
        """Returns a list of configured email addresses for the authenticated
        user."""
        url = api_base + 'emails/'
        try:
            return json.loads(self.load_url(url))
        except ValueError:
            raise URLError

    def __repr__(self):
        extra = ''
        if all((self.username, self.password)):
            extra = ' (auth: {0})'.format(self.username)
        return '<BitBucket API{0}>'.format(extra)


class User(object):
    """API encapsulation for user related bitbucket queries."""
    def __init__(self, bb, username):
        self.bb = bb
        self.username = username

    def followers(self):
        url = api_base + 'users/{0}/followers/'.format(self.username)
        return self.bb._loads(url)

    def repository(self, slug):
        return Repository(self.bb, self.username, slug)

    def repositories(self):
        user_data = self.get()
        return user_data['repositories']

    def events(self, start=None, limit=None):
        query = smart_encode(start=start, limit=limit)
        url = api_base + 'users/{0}/events/'.format(self.username)
        if query:
            url += '?{0}'.format(query)
        return self.bb._loads(url)

    def get(self):
        url = api_base + 'users/{0}/'.format(self.username)
        return self.bb._loads(url)

    def __repr__(self):
        return '<User: {0}>'.format(self.username)


class Repository(object):
    def __init__(self, bb, username, slug):
        self.bb = bb
        self.username = username
        self.slug = slug
        self.base_url = api_base + 'repositories/{0}/{1}/'.format(
            self.username,
            self.slug
        )
        self._data = None  # cache of repo data from the api

    def get(self):
        if self._data is None:
            self._data = self.bb._loads(self.base_url)
        return self._data

    def changeset(self, revision):
        """Get one changeset from a repos."""
        url = self.base_url + 'changesets/{0}/'.format(revision)
        return self.bb._loads(url)

    def changesets(self, limit=None, start=None):
        """Get information about changesets on a repository."""
        url = self.base_url + 'changesets/'
        query = smart_encode(limit=limit, start=start)
        if query:
            url += '?{0}'.format(query)
        return self.bb._loads(url)

    def parse_changeset_for_author(self, cset):
        """Try to pull username, full name, email from changeset info.
        Returns a dictionary.

        """
        author = cset.get('author', '')
        raw_author = cset.get('raw_author', '')
        full_name = email = ''
        try:  # parse email from the raw_author field
            # leaves email as <name@example.com>
            full_name, email = re.search("([^<]*)(<.+>)?", raw_author).groups()
            if email:
                email = re.sub('[<|>]', '', email)
            elif email is None:
                email = ''
        except AttributeError:
            pass

        return {
            'name': full_name or '',
            'author': author,
            'email': email,
            'gravatar_id': hashlib.md5(email.lower()).hexdigest()
        }

    def tags(self):
        """Get a list of tags for a repository."""
        url = self.base_url + 'tags/'
        return self.bb._loads(url)

    def branches(self):
        """Get a list of branches for a repository."""
        url = self.base_url + 'branches/'
        return self.bb._loads(url)

    def issue(self, number):
        return Issue(self.bb, self.username, self.slug, number)

    def issues(self, start=None, limit=None):
        url = self.base_url + 'issues/'
        query = smart_encode(start=start, limit=limit)
        if query:
            url += '?{0}'.format(query)
        return self.bb._loads(url)

    def events(self, start=None, limit=None):
        url = self.base_url + 'events/'
        query = smart_encode(start=start, limit=limit)
        if query:
            url += '?{0}'.format(query)
        return self.bb._loads(url)

    def followers(self):
        url = self.base_url + 'followers/'
        return self.bb._loads(url)

    def forks(self):
        """Number of times this Repo has been forked."""
        data = self.get()
        return data.get("forks_count", 0)

    def fork(self):
        """Is this a fork of another Repo? Returns True or False."""
        data = self.get()
        return data.get("is_fork", False)

    def contributors(self, limit=50, sleep_after=None, sleep_for=None):
        """
        NOTE: This method is not very nice to the bitbucket API.

        Use Sparingly.

        Get contributors for a repo, and attempt to provide info similar to
        Github's ``contributors``. To do this, we look for data in all of a
        project's changesets, and ``limit`` controls how many of those we
        query at once.

        The ``sleep_after`` parameter instructs this method to sleep for
        ``sleep_for`` seconds after ``sleep_after``-many calls to the api.
        Both of these parameters must be provided for this to work  :-(

        >>> repo.contributors(sleep_after=5, sleep_for=3)

        The above example will sleep for 3 seconds after every 5th call to the
        changesets API.

        This method returns a dictionary of the form:

            {
                "contributors": [
                    {
                        "name": "Brad Montgomery",
                        "gravatar_id": "d57aec10399cbb252bd890c2bb3fe1c9",
                        "contributions": 123,
                        "login": "bkmontgomery",
                        "email": "brad@example.com"
                    },
                ]
            }

        """
        contributors = {}  # user data, keyed by author/username

        def _update_contributors(cset, contributors):
            author_data = self.parse_changeset_for_author(cset)
            author = author_data.get('author', '')

            if author and author in contributors.keys():
                contributors[author]['contributions'] += 1
            elif author:
                contributors[author] = {
                    'name': author_data.get('name', ''),
                    'login': author,
                    'email': author_data.get('email', ''),
                    'gravatar_id': author_data.get('gravatar_id', ''),
                    'contributions': 1,
                }

        api_hit_count = 0
        # Do this for every "page" of the changsets...
        start = None
        remaining_changesets = 1
        retrieved_changesets = 0
        while remaining_changesets > 0:
            # initial group of changesets
            changesets = self.changesets(limit=limit, start=start)
            if start:
                start = start + limit + 1
            else:
                start = limit + 1
            api_hit_count += 1  # see how many times we've hit the api
            for cset in changesets.get('changesets', []):
                _update_contributors(cset, contributors)
            retrieved_changesets += len(changesets.get('changesets', []))
            remaining_changesets = changesets['count'] - retrieved_changesets
            if remaining_changesets < start:
                start = changesets['count'] - remaining_changesets

            sleep_enabled = sleep_after and sleep_for
            hit_count_reached = (sleep_enabled and api_hit_count > 0 and
                                 api_hit_count % sleep_after == 0)
            if hit_count_reached:
                time.sleep(sleep_for)

        #TODO sort based on contributions, like github does?
        for k, v in contributors.items():
            v.update({'name': k})
        return {'contributors': contributors.values()}

    def __repr__(self):
        return '<Repository: {0}\'s {1}>'.format(self.username, self.slug)


class Issue(object):
    def __init__(self, bb, username, slug, number):
        self.bb = bb
        self.username = username
        self.slug = slug
        self.number = number
        path = 'repositories/{0}/{1}/issues/{2}'.format(username, slug, number)
        self.base_url = api_base + path
        self._data = None

    def get(self):
        if self._data is None:
            self._data = self.bb._loads(self.base_url)
        return self._data

    def followers(self):
        """Number of people following this Issue."""
        d = self.get()
        return d.get("follower_count", 0)

    def __repr__(self):
        return '<Issue #{0} on {1}\'s {2}>'.format(
            self.number,
            self.username,
            self.slug
        )
