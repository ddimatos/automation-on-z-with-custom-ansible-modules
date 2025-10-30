from zoautil_py import datasets

# Difference concatenation utility
def dconcat(source: str = None, change:str = None, merge: str = None, reverse: bool = False) -> None:
   """
   This utility will find the differences between two datasets will concatenate the
   changes to the source dataset (default).
   The default behavior can be reversed to append the changes found to the changes
   dataset.
   If a merge dataset is provided, all changes will be inserted into the merge
   data leaving out any duplicates.

   Parameters
   ----------
   source (str): Source dataset containing the original listing.  
   change (str): Changes dataset containing the updated listing to be compared
   to source dataset.  
   merge (str): Dataset to contain the differences for both datasets.  
   reverse: (bool): Change the default behavior to write the source changes
   into the changes dataset.  
   """

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
         # TODO: Consider optimizing as two writes instead of iterating.
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

# Print the source dataset differences
def ddiff_source(source: str = None, change:str = None) -> str:
    """
    This method will return the differences found in the source dataset
    when compared to the changed dataset. 

    Parameters
    ----------
    source (str): Source dataset containing the original listing.  
    change (str): Changes dataset containing the updated listing to be compared
    to source dataset.  

    Returns
    -------
    string: The differences found in the source dataset when compared to the
    changed data set.  
    """

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
    """
    This method will return the differences found in the change dataset
    when compared to the source dataset. 

    Parameters
    ----------
    source (str): Source dataset containing the original listing.  
    change (str): Changes dataset containing the updated listing to be compared
    to source dataset.  

    Returns
    -------
    string: The differences found in the change dataset when compared to the
    source dataset.  
    """

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