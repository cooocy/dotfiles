import config_loader
import kits
import logger
import os
import oss
import sys


def get_handler(command: str):
    if 'help' == command:
        return help_
    if 'list' == command:
        return list_
    if 'download' == command:
        return download
    if 'put' == command:
        return put
    if 'delete' == command:
        return delete
    if 'gc' == command:
        return gc
    print('Args Error. Exec `./oss_helper.py help` for help.')
    sys.exit(1)


def help_(args: list):
    print('')
    print('This is oss helper.')
    print('')
    print('Command: help/list/download/put/delete')
    print('')

    print('* help')
    print('Show this help.')
    print('')

    print('* list')
    print('Usage: ./oss_helper.py list [--marker <key>] [—-limit <limit>]')
    print('       key    Only key name in oss, not the full https url.')
    print('       limit  The objects count to list, must be int.')
    print('e.g.')
    print('./oss_helper.py list')
    print('./oss_helper.py list --marker x.png')
    print('./oss_helper.py list --marker x.png --limit 20')
    print('')

    print('* download')
    print('Usage: ./oss_helper.py download <key> [—-path <path>]')
    print('       key   Only key name in oss, not the full https url.')
    print('       path  The local path to storage downloaded file, must be a dir.')
    print('e.g.')
    print('./oss_helper.py download x.png')
    print('./oss_helper.py download x.png --path ~/tmp')
    print('')

    print('* put')
    print('Usage: ./oss_helper.py put <file>')
    print('       path  The local file path to uploaded, must be a file.')
    print('e.g.')
    print('./oss_helper.py put x.png')
    print('./oss_helper.py put /root/x.png')
    print('')

    print('* delete')
    print('Usage: ./oss_helper.py delete <key>')
    print('       key   Only key name in oss, not the full https url.')
    print('e.g.')
    print('./oss_helper.py delete x.png')
    print('')

    print('* gc')
    print('Usage: ./oss_helper.py gc')
    print('Delete log file defined in `config.yaml`.')
    print('')


def list_(args: list):
    marker = ''
    limit = 20
    args_len = len(args)
    if args_len != 0 and args_len != 2 and args_len != 4:
        print('Args Error. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    if args_len == 2:
        if args[0] == '--marker':
            marker = args[1]
        elif args[0] == '--limit':
            limit = args[1]
        else:
            print('Args Error. Exec `./oss_helper.py help` for help.')
            sys.exit(1)
    if args_len == 4:
        if args[0] == '--marker':
            marker = args[1]
        elif args[0] == '--limit':
            limit = args[1]
        else:
            print('Args Error. Exec `./oss_helper.py help` for help.')
            sys.exit(1)
        if args[2] == '--marker':
            marker = args[3]
        elif args[2] == '--limit':
            limit = args[3]
        else:
            print('Args Error. Exec `./oss_helper.py help` for help.')
            sys.exit(1)
    if not str(limit).isdigit():
        print('Args Error. <limit> must be int. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    limit = int(limit)
    bucket = oss.get_bucket()
    r = bucket.list_objects(marker=marker, max_keys=limit)
    for obj in r.object_list:
        print(obj.key)


def download(args: list):
    args_len = len(args)
    if args_len != 1 and args_len != 3:
        print('Args Error. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    key = ''
    path = kits.current_path()
    if args_len == 1:
        key = args[0]
    if args_len == 3:
        key = args[0]
        if args[1] != '--path':
            print('Args Error. Exec `./oss_helper.py help` for help.')
            sys.exit(1)
        path = args[2]
    if path != '':
        if not os.path.exists(path) or not os.path.isdir(path):
            print('Args Error. <path> must exist and must be dir. Exec `./oss_helper.py help` for help.')
            sys.exit(1)
    oss.get_bucket().get_object_to_file(key, path + '/' + key)


def put(args: list):
    if len(args) != 1:
        print('Args Error. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    file = args[0]
    if not os.path.isfile(file):
        print('Args Error. <file> must exist and must be file. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    bucket = oss.get_bucket()
    res = bucket.put_object_from_file(kits.gen_oss_file_name(file), file)
    url = res.resp.response.url.replace('http://', 'https://')
    key = url[url.rindex('/') + 1:]
    print(url)
    logger.log('put', file, key)


def delete(args: list):
    if len(args) != 1:
        print('Args Error. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    key = args[0]
    res = oss.get_bucket().delete_object(key)
    print(res.resp.response.ok)
    logger.log('delete', key)


def gc(args: list):
    if len(args) > 0:
        print('Args Error. Exec `./oss_helper.py help` for help.')
        sys.exit(1)
    log_file = kits.current_path() + '/' + config_loader.log_file
    if os.path.exists(log_file):
        os.remove(log_file)
