"""
dsa_comparison.py
=================
Compares two strategies for looking up an SMS record by ID:

  1. Linear Search      — iterate the list until a match is found  O(n)
  2. Dictionary Lookup  — retrieve directly from a pre-built dict  O(1)

Loads records via xml_parser.load_sms_records, runs the benchmark
across a spread of 25 IDs (early, middle, and late positions),
and prints a formatted results table.

Usage:
    python3 dsa/dsa_comparison.py
"""

import time
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from xml_parser import load_sms_records


# ─── Strategy 1: Linear Search ───────────────────────────────────────────────

def linear_search(records, target_id):
    """
    Linear Search: iterate through records from the start until
    target_id matches. Returns the matching record dict or None.
    Time complexity: O(n) worst case.

    Args:
        records   (list[dict]): Full list of SMS records.
        target_id (int):        ID to search for.

    Returns:
        dict | None
    """
    for rec in records:
        if rec["id"] == target_id:
            return rec
    return None


# ─── Strategy 2: Dictionary Lookup ───────────────────────────────────────────

def build_lookup_dict(records):
    """
    Build an {id: record} dictionary from a list of records.
    One-time O(n) cost; subsequent lookups are O(1) average.

    Args:
        records (list[dict]): Full list of SMS records.

    Returns:
        dict[int, dict]: Mapping of record id to record dict.
    """
    return {rec["id"]: rec for rec in records}


def dictionary_lookup(lookup_dict, target_id):
    """
    Dictionary Lookup: retrieve a record by ID from a pre-built
    dictionary. Time complexity: O(1) average.

    Args:
        lookup_dict (dict[int, dict]): Pre-built {id: record} dict.
        target_id   (int):             ID to look up.

    Returns:
        dict | None
    """
    return lookup_dict.get(target_id)
