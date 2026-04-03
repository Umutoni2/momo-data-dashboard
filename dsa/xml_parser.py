"""
xml_parser.py
=============
Loads modified_sms_v2.xml and converts each <sms> record into
a Python dictionary. The resulting list is serialised to
sms_records.json for use by the API server and DSA benchmark.
"""

import xml.etree.ElementTree as ET
import json
import os


# Fields to extract from every <sms> element, in order.
SMS_FIELDS = [
    "protocol",
    "address",
    "date",
    "type",
    "body",
    "service_center",
    "read",
    "status",
    "date_sent",
    "readable_date",
    "contact_name",
]


def _sms_to_record(index, element):
    """
    Convert a single <sms> XML element to a flat dictionary.
    Assigns a 1-based sequential ID; all other values come
    directly from the element's attributes.

    Args:
        index   (int):              0-based position in the tree.
        element (xml.etree.Element): The <sms> element to convert.

    Returns:
        dict: Flat record with 'id' plus all SMS_FIELDS.
    """
    record = {"id": index + 1}
    for field in SMS_FIELDS:
        record[field] = element.attrib.get(field, "")
    return record


def load_sms_records(xml_path):
    """
    Parse an XML file of <sms> records into a list of dicts.

    Args:
        xml_path (str): Absolute or relative path to the XML file.

    Returns:
        list[dict]: One dict per <sms> element, with a sequential id.

    Raises:
        FileNotFoundError: If xml_path does not exist.
        ET.ParseError:     If the file is not valid XML.
    """
    if not os.path.exists(xml_path):
        raise FileNotFoundError(f"XML file not found: {xml_path}")

    root = ET.parse(xml_path).getroot()
    return [_sms_to_record(i, el) for i, el in enumerate(root.findall("sms"))]


if __name__ == "__main__":
    # Resolve path relative to this file's location
    here    = os.path.dirname(os.path.abspath(__file__))
    src     = os.path.join(here, "..", "modified_sms_v2.xml")
    out     = os.path.join(here, "sms_records.json")

    print("Parsing XML file...")
    records = load_sms_records(src)
    print(f"  {len(records)} records extracted.")

    with open(out, "w", encoding="utf-8") as fh:
        json.dump(records, fh, indent=2, ensure_ascii=False)
    print(f"  Saved to {out}")
