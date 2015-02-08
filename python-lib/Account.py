import os


def read_file(fname):
    f = None
    usr = ''
    pw  = ''
    try:
        f = open(fname,'r')
        usr,pw = f.readlines()
    except:
        pass
    if f: f.close()
    return (usr.rstrip(),pw.rstrip())


def input_account():
    from getpass import getpass
    usr = raw_input('usr: ')
    pwd = getpass('pwd: ')
    return (usr, pwd)


def write_file(fname, usr, pwd):
    ret = False
    f   = None
    try:
        f = open(fname, 'w')
        f.write(usr + '\n')
        f.write(pwd + '\n')
        ret = True
    except:
        pass
    if f: f.close()
    return ret




class Account():
    def __init__(self, fname):
        self._fname = os.path.expanduser(fname)
        self._usr   = ''
        self._pwd   = ''

    def get(self):
        if '' != self._usr:
            return (self._usr, self._pwd)
        if not self.read():
            self.input()
            self.save()
        return (self._usr, self._pwd)

    def read(self):
        usr,pwd = read_file(self._fname)
        if '' == usr: return False
        self._usr = usr
        self._pwd = pwd
        return True

    def save(self):
        if '' == self._usr: return False
        return write_file(
          self._fname,
          self._usr,
          self._pwd)

    def input(self):
        self._usr, self._pwd = input_account()

