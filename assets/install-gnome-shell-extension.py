"""
Install the specified gnome shell extension.

Run this program as root or using sudo.

Example:
$ sudo ./install-gnome-shell-extension 307

Args:
    extension_id (int): The extension number.

Returns:
    None

Code Source: https://answers.launchpad.net/cubic/+question/697087
"""

import json
import shutil
import sys
import tempfile
import traceback
import urllib
import urllib.request
import xml.etree.ElementTree as ElementTree
import zipfile

########################################################################
# References
########################################################################

# https://docs.python.org/3/howto/urllib2.html

########################################################################
# Globals & Constants
########################################################################

EXTENSION_INFORMATION_URL_TEMPLATE = 'https://extensions.gnome.org/extension-info/?pk=%i&shell_version=%s'
EXTENSION_DOWNLOAD_URL_TEMPLATE = 'https://extensions.gnome.org%s'
EXTENSION_DIRECTORY_TEMPLATE = '/usr/share/gnome-shell/extensions/%s'
# EXTENSION_DIRECTORY_TEMPLATE = '/home/psingh/Temp/test/%s'

########################################################################
# Functions
########################################################################

# -----------------------------------------------------------------------
# Extension Id
# -----------------------------------------------------------------------

try:
    extension_id = int(sys.argv[1])
    print('Install extension %i...' % extension_id)
except IndexError:
    print('• Error. An extension id number is required.')
    exit()
except ValueError:
    print('• Error. An extension id number is required.')
    exit()

# -----------------------------------------------------------------------
# Gnome Shell Version
# -----------------------------------------------------------------------

version = ''
try:
    filepath = '/usr/share/gnome/gnome-version.xml'
    tree = ElementTree.parse(filepath)
    root = tree.getroot()
    platform = root.find('platform').text
    version = platform
    minor = root.find('minor').text
    version = version + '.' + minor
    try:
        micro = root.find('micro').text
        version = version + '.' + micro
    except AttributeError:
        print('• Ignoring. Unable to get Gnome micro version. The Gnome version is %s.' % version)
except Exception as exception:
    print('• Error. Unable to get the Gnome version. The Gnome version is %s.' % version)
    print('• The exception is %s' % exception)
    # print('• The tracekback is %s' % traceback.format_exc())
    exit()
print('• The Gnome version is %s.' % version)

# -----------------------------------------------------------------------
# Download the Extension
# -----------------------------------------------------------------------

url = EXTENSION_INFORMATION_URL_TEMPLATE % (extension_id, version)
print('• The extension information url is %s' % url)
try:
    with urllib.request.urlopen(url) as response:
        try:
            # Get extension information.
            data = response.read()
            info = json.loads(data)
            name = info.get('name')
            print('• The extension name is %s' % name)
            uuid = info.get('uuid')
            print('• The extension uuid is %s' % uuid)
            # Ex: url = 'https://<email address hidden>?version_tag=15925'
            url = EXTENSION_DOWNLOAD_URL_TEMPLATE % info.get('download_url')
            print('• The extension download url is %s' % url)
            # Download extension.
            try:
                with urllib.request.urlopen(url) as response:
                    try:
                        # Extract the extension
                        # extension_directory = EXTENSION_DIRECTORY_TEMPLATE % uuid
                        # extension_filepath = '%s/test.zip' % extension_directory
                        # with open(extension_filepath, 'wb') as target:
                        # shutil.copyfileobj(response, target)
                        # print('• Saved the extension as %s' % extension_filepath)
                        with tempfile.NamedTemporaryFile(delete=False) as temp_file:
                            shutil.copyfileobj(response, temp_file)
                            extension_directory = EXTENSION_DIRECTORY_TEMPLATE % uuid
                            print('• The extension directory is %s' %
                                  extension_directory)
                            try:
                                # Unzip the temporary file to the target directory.
                                with zipfile.ZipFile(temp_file, 'r') as zip_file:
                                    # The extension directory path will be created.
                                    zip_file.extractall(extension_directory)
                                print('• Successfully extracted %s extension %i for Gnome %s to %s' % (
                                    uuid, extension_id, version, extension_directory))
                            except Exception as exception:
                                print(
                                    '• Error. Unable to extract extension to %s' % extension_directory)
                                print('• The exception is %s' % exception)
                                # print('• The tracekback is %s' % traceback.format_exc())
                    except Exception as exception:
                        print(
                            '• Error. Unable to save extension as a temporary file from %s' % url)
                        print('• The exception is %s' % exception)
                        # print('• The tracekback is %s' % traceback.format_exc())
            except urllib.error.URLError as exception:
                print('• Error. Unable to access %s' % url)
                print('• The exception is %s' % exception)
                # print('• The tracekback is %s' % traceback.format_exc())
        except Exception as exception:
            print('• Error. Unable to get extension information from %s' % url)
            print('• The exception is %s' % exception)
            # print('• The tracekback is %s' % traceback.format_exc())
except urllib.error.URLError as exception:
    print('• Error. Unable to access %s' % url)
    print('• The exception is %s' % exception)
    # print('• The tracekback is %s' % traceback.format_exc())
