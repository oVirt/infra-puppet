#!/usr/bin/env python
# encoding: utf-8
"""
This small server is a simple proxy to broker yum mirrorlists, it uses a
hardcoded configuration (repos.yaml) to map urls to mirrorlists alowing you to
use a fixed url in the client and get the high availability of a mirrorlist,
making it a lot easier to cache the results.

For example, an entry in the repos.yaml file like this:

myrepo:
    mirrorlist: http://myrep.com/mirrorlist?arch={arch}&versios={releasever}

will let you do a request to this service as:

    curl -O myfile http://localhost:5000/myrepo/19/x86_64/myfile

And the service will proxy that request, retrieveing the mirrorlist from the
specified mirrorlist url, fetching the first responsove mirror and returning
you the result (streamed).

You can specify a baseurl instead of a mirrorlist to get a plain proxy to that
url instead.

To get the releasever and arch key, it will interpret the requested url in the
following way:

    If the url has just one slash:
        http://host/path

    If it has two:
        http://host/releasever/path

    And f it has three or more:
       http://host/releasever/arch/path


To see the full list of available repos go to the root page '/'.
"""

import os
import sys
import yaml
from pprint import pformat
from collections import defaultdict
import argparse
import signal
import time
import logging.handlers

import flask
import requests
from gevent.wsgi import WSGIServer


app = flask.Flask(__name__)
app.secret_key = 'This is whatever random string you want it to be'
CACHED_URLS = defaultdict(dict)
REPOS = {}


def daemonize(pidfile):
    try:
        pid = os.fork()
        if pid > 0:
            app.logger.debug('First parent exiting')
            sys.exit(0)
    except OSError as exc:
        app.logger.error(
            "fork #1 failed: %d (%s)\n" % (exc.errno, exc.strerror))
        sys.exit(1)
    # decouple from parent environment
    os.setsid()
    os.umask(0)
    try:
        pid = os.fork()
        if pid > 0:
            app.logger.debug('Second parent exiting')
            sys.exit(0)
    except OSError, e:
        app.logger.error("fork #2 failed: %d (%s)\n" % (e.errno, e.strerror))
        sys.exit(1)
    # update the pid in the pidfile
    pid2file(pidfile)
    app.logger.info('Starting as process %s' % os.getpid())
    sys.stdout.flush()
    sys.stderr.flush()
    for fd_t in ((sys.stdin, 'r'), (sys.stdout, 'a+'), (sys.stderr, 'a+')):
        with open('/dev/null', fd_t[-1]) as fd:
            os.dup2(fd.fileno(), fd_t[0].fileno())


def is_good_mirror(mirror_url, path=''):
    try:
        res = requests.get(mirror_url + '/' + path, stream=True)
    except Exception:
        return False
    res.close()
    return res.ok


def get_first_mirror(mirrorlist_url, path='', fastcheck=False):
    """
    :param mirrorlist_url: Url to the mirrorlist
    :param path: specific path for that mirror
    :param fastcheck: If True, wi l ignore the path and use the base url
    returned in the mirrorlist (that will be more likely to be already cached).
    If False, it will use the full path to check the liveliness of the mirror
    (more unlikely to be cached but more accurate).
    """
    if mirrorlist_url in CACHED_URLS:
        if path in CACHED_URLS[mirrorlist_url]:
            return CACHED_URLS[mirrorlist_url][path]
        elif fastcheck and '' in CACHED_URLS[mirrorlist_url]:
            return CACHED_URLS[mirrorlist_url]['']
    res = requests.get(mirrorlist_url).iter_lines()
    mirror_url = next(res, '').strip()
    if not mirror_url:
        raise Exception('Got no mirrors from %s' % mirrorlist_url)
    app.logger.info("Testing mirror %s for path %s", mirror_url, path)
    while mirror_url and not is_good_mirror(mirror_url, path):
        mirror_url = next(res, '').strip()
    if not mirror_url:
        raise Exception('Unable to get a good mirror from %s' % mirrorlist_url)
    CACHED_URLS[mirrorlist_url].update({
        path: mirror_url,
        '': mirror_url,
    })
    return mirror_url


def load_repos(repos_file):
    with open(repos_file) as rf_fd:
        data_map = yaml.safe_load(rf_fd)
    return data_map


@app.route("/<reponame>/<releasever>/<arch>/<path:path>")
@app.route("/<reponame>/<releasever>/<arch>/")
@app.route("/<reponame>/<releasever>/<arch>")
def get_url(reponame, releasever, arch, path='/'):
    if reponame not in REPOS:
        return "Repo %s not found" % reponame, 404
    repo = REPOS[reponame]
    if 'url' not in repo:
        if 'mirrorlist' not in repo:
            return "<pre>Malformed repo definition\n%s</pre>" % pformat(repo)
        # on first try, we get teh first mirror that answers anything
        url = get_first_mirror(
            repo['mirrorlist'].format(releasever=releasever, arch=arch),
            path,
            fastcheck=True,
        )
    else:
        url = repo['baseurl'].format(releasever=releasever, arch=arch)
    url = url + '/' + path
    app.logger.info("Proxying to %s" % url)
    stream = requests.get(url, stream=True)
    if not stream.ok:
        url = get_first_mirror(
            repo['mirrorlist'].format(releasever=releasever, arch=arch),
            path,
            fastcheck=False,
        )
        url = url + '/' + path
        app.logger.info("Previous proxy failed, trying checking full path %s" % url)
        stream = requests.get(url, stream=True)
    headers = {}
    for header in (
        'content-type', 'content-length', 'etag', 'age', 'last-modified'
    ):
        if header in stream.headers:
            headers[header] = stream.headers[header]
    return flask.Response(
        flask.stream_with_context(
            stream.iter_content(chunk_size=1024 * 1024 * 256)
        ),
        headers=headers,
    )


@app.route("/")
def show():
    page = '<!DOCTYPE html><html><body><h1>Available repositories:</h1><table>'
    for repo, repodata in REPOS.items():
        dest_url = repodata.get(
           'mirrorlist',
            repodata.get('baseurl', 'None')
        )
        orig_url = flask.request.scheme \
            + '://' + flask.request.host \
            + '/%s/{releasever}/{arch}/path' % repo
        page += '<tr><td>%s</td><td>%s</td><td>%s</td></tr>' % (
            repo,
            orig_url,
            dest_url,
        )
    page += '</table></body></html>'
    return page


@app.route('/reload')
def reload():
    global REPOS
    global REPOSFILE
    REPOS = load_repos(REPOSFILE)
    return flask.redirect('/')


def kill_attempt(pid, timeout_secs=5):
    if not os.path.exists('/proc/%s' % pid):
        app.logger.info('Process %s is not running' % pid)
        return True
    app.logger.info('Gracefully stopping process %s' % pid)
    for attempt in range(timeout_secs * 10):
        os.kill(pid, signal.SIGTERM)
        time.sleep(0.1)
        if not os.path.exists('/proc/%s' % pid):
            return True
    app.logger.warn('Forcing stop of process %s' % pid)
    os.kill(pid, signal.SIGKILL)
    time.sleep(0.1)
    if os.path.exists('/proc/%s' % pid):
        return False
    return True


def handle_pidfile(pidfile, restart=False):
    if os.path.exists(pidfile):
        pid = file2pid(pidfile)
        if pid and os.path.exists('/proc/%s' % pid):
            if restart:
                if not kill_attempt(int(pid)):
                    raise Exception('Failed to stop running process %s' % pid)
            else:
                app.logger.error('Already running on pid %s' % pid)
                raise Exception('Already running on pid %s' % pid)
        else:
            app.logger.warn('Pidfile exists but process is dead')
    pid2file(pidfile)


def cleanup(pidfile):
    app.logger.info('Cleaning up')
    if os.path.exists(pidfile):
        os.remove(pidfile)


def reload_config(ip, port):
    url = 'http://%s:%s/reload' % (ip, port)
    res = requests.get(url)
    if not res.ok:
        raise Exception(
            'Failed to reload %s:\nReturn Code:%s\n%s'  % (
                res.url,
                res.code,
                res.text
            )
        )
    return 0


def status(pidfile):
    if os.path.exists(pidfile):
        pid = file2pid(pidfile)
        if pid and os.path.exists('/proc/%s' % pid):
            return 'running', 0
        else:
            return 'pidfile_exists', 1
    return 'stopped', 1


def file2pid(pidfile):
    with open(pidfile) as pf_fd:
        pid = pf_fd.readline().strip()
    return int(pid)


def pid2file(pidfile):
    with open(pidfile, 'w') as pf_fs:
        pf_fs.write(str(os.getpid()))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--repos', default='repos.yaml')
    parser.add_argument(
        '-i', '--ip', default='0.0.0.0', help='Ip to listen to')
    parser.add_argument(
        '-p', '--port', default='5000', help='Port to listen to')
    parser.add_argument(
        '--pidfile', default='repoproxy.pid',
        help='Pidfile to avoid mparallel runs'
    )
    parser.add_argument(
        '--reload', action='store_true', default=False,
        help='Reload a running process configuration'
    )
    parser.add_argument(
        '--restart', action='store_true', default=False,
        help='Restart the running process'
    )
    parser.add_argument(
        '--stop', action='store_true', default=False,
        help='Stop the running process'
    )
    parser.add_argument(
        '--status', action='store_true', default=False,
        help='Show the current status'
    )
    parser.add_argument(
        '-d', '--daemonize', action='store_true', default=False,
        help='Daemonize in the background'
    )
    parser.add_argument(
        '-t', '--development', action='store_true', default=False,
        help='Start as a development instance'
    )
    parser.add_argument(
        '--log', default='-',
        help='Logfile to use, if \'-\' it will use stdout'
    )
    parser.add_argument(
        '-v', '--verbose', action='store_true',
        help='Be verbose'
    )
    args = parser.parse_args()

    if args.verbose:
        level = logging.DEBUG
    else:
        level = logging.INFO
    if args.log == '-':
        handler = logging.StreamHandler(sys.stdout)
    else:
        handler = logging.handlers.TimedRotatingFileHandler(
            args.log,
            when='midnight',
            backupCount=7,
        )
    app.logger.level = level
    app.logger.addHandler(handler)

    if args.reload:
        sys.exit(reload_config(args.ip, args.port))
    elif args.stop:
        if kill_attempt(file2pid(args.pidfile)):
            sys.exit(0)
        sys.exit(1)
    elif args.status:
        res, rc = status(args.pidfile)
        app.logger.info('Process ' + res)
        sys.exit(rc)
    if not args.development:
        handle_pidfile(args.pidfile, args.restart)
    REPOSFILE = args.repos
    REPOS = load_repos(args.repos)
    if args.development:
        app.run(debug=True, host=args.ip, port=int(args.port))
    else:
        if args.daemonize:
            daemonize(args.pidfile)
        else:
            app.logger.info('Starting as process %s' % os.getpid())
        http_server = WSGIServer((args.ip, int(args.port)), app)
        try:
            http_server.serve_forever()
        finally:
            cleanup(args.pidfile)
