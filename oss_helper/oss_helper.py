#!/opt/homebrew/bin//python
import command
import config_loader
import sys

# Load config and check valid.
if not config_loader.is_oss_valid(config_loader.oss_configurations):
    print('OSS Config is not valid. File: config.yaml')
    sys.exit(1)

# Get handler.
if len(sys.argv) < 2:
    print('Args Error. Exec `./oss_helper.py help` for help.')
    sys.exit(1)
__handler = command.get_handler(sys.argv[1])
__args = sys.argv[2:]

# Exec.
__handler(__args)
