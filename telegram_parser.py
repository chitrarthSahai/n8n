import re
from json import dumps

# In n8n Python (Beta) node you would get the message from the input, e.g.:
# message = _input.first().json.message.text
message = "6 is approved"


match = re.search(r"\b(\d+)\b", message)
if match:
    idea_id = match.group(1)
else:
    # No numeric id found; set to None so downstream can detect missing id
    idea_id = None

# Determine status by presence of the word 'approved' (case-insensitive)
status = "approved" if "approved" in message.lower() else "rejected"

# # n8n expects a variable called `items` which is a list of dicts. Each dict commonly has a `json` key
# # containing the actual payload for that item. Print the JSON array so the sandbox returns it.
# items = [{"json": output}]

# print(dumps(items, indent=4))
return [
	{
		"json": {
			"idea_id": idea_id,
			"status": status
		}
	}
]