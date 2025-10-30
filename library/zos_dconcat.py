#!/usr/bin/python

DOCUMENTATION = r'''
---
module: zos_dconcat

short_description: Concatenate dataset differences.
version_added: "1.0.0"

description: This module diffs two datasets and will concatenate the result. 

options:
    src:
        description: Source dataset
        required: true
        type: str
    change:
        description: Dataset with the changes.
        required: true
        type: str
    merge:
        description: Dataset to merge results into.
        required: false
        type: str
    state:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: str
        choices:
            - default
            - reverse
author:
    - Demetrios Dimatos (@ddimatos)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
src:
    description: The source dataset
    type: str
    returned: always
    sample: 'some.data.set'
change:
    description: The dataset with changes.
    type: str
    returned: always
    sample: 'some.data.set'
merge:
    description: The merge dataset.
    type: str
    returned: always
    sample: 'some.data.set'
state:
    description: State, can be either 'default' or 'reverse'
    type: str
    returned: always
    sample: 'reverse'
'''

from ansible.module_utils.basic import AnsibleModule                                                                                                                                                                                                     # type: ignore
from zoautil_py import datasets

# To use the python module without embedding it in the ansible module:
# cp /Users/ddimatos/git/gh/automation-on-z-with-custom-ansible-modules/ansible-module/library/dconcat_module.py /Users/ddimatos/git/ghe/ibm_zos_core/venv/venv-2.18/lib/python3.12/site-packages/ansible/module_util
# Then import it like so: from ansible.module_utils.dconcat_module import dconcat, ddiff_source, ddiff_change, data_set_print

# Difference concatenation utility
def dconcat(source: str = None, change:str = None, merge: str = None, reverse: bool = False) -> int:
   # Always compare DS1 and DS2 and process further accordingly.
   if source is not None and change is not None:
      result=datasets.compare(source, change)
      lines = result.split('\n')

      source_lines = []
      for line in lines:
         if line.startswith("I -"):
            source_lines.append(line[4:84])

      change_lines = []
      for line in lines:
         if line.startswith("D -"):
            change_lines.append(line[4:84])

      if merge is not None:
         # Case: DS1 and DS2 are diffed and inserted into DS3
         for source_line in source_lines:
            datasets.write(merge, source_line, True)

         for change_line in change_lines:
            datasets.write(merge, change_line, True)
      elif reverse:
         # Case: DS1 and DS2 are diffed and inserted into DS2 (reverse order)
         for change_line in change_lines:
            datasets.write(change, change_line, True)
      else:
         # Case: DS1 and DS2 are diffed and inserted into DS1
         for source_line in source_lines:
            datasets.write(source, source_line, True)
   return 0

# Print the source dataset differences
def ddiff_source(source: str = None, change:str = None) -> str:
    # Always compare DS1 and DS2 and process further accordingly.
    if source is not None and change is not None:
        result=datasets.compare(source, change)
        lines = result.split('\n')

        source_lines = []
        for line in lines:
            if line.startswith("I -"):
                source_lines.append(line[4:84])

    return '\n'.join(source_lines)

# Print the changed dataset differences
def ddiff_change(source: str = None, change:str = None) -> str:
    # Always compare DS1 and DS2 and process further accordingly.
    if source is not None and change is not None:
        result=datasets.compare(source, change)
        lines = result.split('\n')

        source_lines = []
        for line in lines:
            if line.startswith("D -"):
                source_lines.append(line[4:84])

    return '\n'.join(source_lines)

# Print any datasets content
def data_set_print(source: str = None):
   return datasets.read(source)

def run_module():
    output = None
    reverse = None
    # Define available arguments/parameters a user can pass to the module
    module_args = dict(
        src = dict(required=True, type='str'),
        change = dict(required=True, type='str'),
        merge = dict(required=False, type='str', default=None),
        state = dict(required=False, choices=['default', 'reverse'], default='default')
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    src = module.params['src']
    change = module.params['change']
    merge = module.params['merge']
    state = module.params['state']

    result = dict(
        changed = False,
        stdout ='',
        stdout_lines = [],
        src = src,
        change = change,
        merge = merge,
        state = state,
        rc='',
        failed = False
    )

    # Merge overrides reverse
    if merge is not None:
        reverse = False
    elif state == 'reverse':
        reverse = True

    # Perform the diff and concat via previously created Python module code
    rc = dconcat( source=src, change=change, merge=merge, reverse=state)

    if rc == 0:
        if reverse:
            output = data_set_print(source=change)
        elif merge is not None:
            output = data_set_print(source=change)
        else:
            output = data_set_print(source=src)

        result['stdout'] = output
        result['stdout_lines'] = output.splitlines()
        result['rc'] = rc
    else:
        result["changed"] = False
        result["failed"] = True
        result["msg"] = ("Unable to diff and concat src dataset {0} to change"
                        " dataset {1}.".format(src,change))
        module.fail_json(**result)

    module.exit_json(**result)

def main():
    run_module()


if __name__ == '__main__':
    main()