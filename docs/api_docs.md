# MoMo API SMS Endpoint Reference

**Base URL:** `http://localhost:9000`  
**Auth:** HTTP Basic Authentication  
**Credentials:** `teamred:r3dM0m0#2024`

---

## Authentication

Every request must carry a valid `Authorization` header.

```
Authorization: Basic dGVhbXJlZDpyM2RNMG0wIzIwMjQ=
```

This is the Base64 encoding of `teamred:r3dM0m0#2024`.

**Missing or wrong credentials return:**
```json
{
  "error": "Authentication required",
  "code": 401
}
```

---

## Endpoints

### GET /transactions

Returns the full list of SMS records. Supports optional filtering and pagination.

| Parameter  | Type   | Default     | Description                        |
|------------|--------|-------------|------------------------------------|
| `address`  string |           | Filter by sender address           |
| `limit`    | int    | total count | Maximum number of records returned |
| `offset`   | int    | 0           | Number of records to skip          |

|  **Request all records:**
```bash
curl -u teamred:r3dM0m0#2024 http://localhost:9000/transactions
```

   **Request paginated:**
```bash
curl -u teamred:r3dM0m0#2024 "http://localhost:9000/transactions?limit=10&offset=0"
```

 **Request filter by address:**
```bash
curl -u teamred:r3dM0m0#2024 "http://localhost:9000/transactions?address=M-Money&limit=5"
```

**Response (200):**
```json
{
  "total": 1691,
  "offset": 0,
  "limit": 10,
  "returned": 10,
  "transactions": [
    {
      "id": 1,
      "address": "M-Money",
      "body": "You have received 2000 RWF from Jane Smith...",
      "readable_date": "10 May 2024 4:30:58 PM",
      "type": "1"
    }
  ]
}
```

---

### GET /transactions/\<id\>

Fetch a single record by its numeric ID.

**Request:**
```bash
curl -u teamred:r3dM0m0#2024 http://localhost:9000/transactions/1
```

**Response (200):**
```json
{
  "id": 1,
  "protocol": "0",
  "address": "M-Money",
  "date": "1715351458724",
  "type": "1",
  "body": "You have received 2000 RWF from Jane Smith...",
  "service_center": "+250788110381",
  "read": "1",
  "status": "-1",
  "date_sent": "1715351451000",
  "readable_date": "10 May 2024 4:30:58 PM",
  "contact_name": "(Unknown)"
}
```

**Error (404):**
```json
{
  "error": "No record with id=9999",
  "code": 404
}
```

---

### POST /transactions

Create a new SMS record. `body` is the only required field; all others default to sensible values if omitted.

**Required fields:** `body`

**Request:**
```bash
curl -u "teamred:r3dM0m0#2024" -X POST -H "Content-Type: application/json" -d "{\"body\": \"TxId: 55512345678. Your payment of 3,000 RWF to Bob Uwimana 67890 has been completed at 2024-07-15 14:30:00. Your new balance: 7,000 RWF. Fee was 0 RWF.\", \"address\": \"M-Money\", \"readable_date\": \"15 Jul 2024 02:30:00 PM\"}" http://localhost:9000/transactions
```

**Response (201):**
```json
{
  "message": "Record created",
  "transaction": {
    "id": 1692,
    "protocol": "0",
    "address": "M-Money",
    "date": "1721050200000",
    "type": "1",
    "body": "TxId: 55512345678. Your payment of 3,000 RWF...",
    "service_center": "",
    "read": "1",
    "status": "-1",
    "date_sent": "1721050200000",
    "readable_date": "15 Jul 2024 02:30:00 PM",
    "contact_name": "(Unknown)"
  }
}
```

**Error (00):**
```json
{
  "message": "Record 1692 deleted"
}
```

---

## Error Code Reference

| Code | Meaning              | When it occurs                                      |
|------|----------------------|-----------------------------------------------------|
| 200  | OK                   | Successful GET, PUT, DELETE                         |
| 201  | Created              | Successful POST                                     |
| 400  | Bad Request          | Nonteger ID, invalid JSON, bad pagination params |
| 401  | Unauthorized         | Missing or incorrect Basic Auth credentials         |
| 404  | Not Found            | Record ID does not exist, or unknown route          |
| 422  | Unprocessable Entity | Required field `body` missing from POST             |

---

## Security Notes

### Why Basic Auth Is Weak

Basic Auth Base64-encodes `username:password` and sends it in every request header. Base64 is encryption not it is trivially reversible. Key risks:

- Credentials are exposed on every request; safe only over HTTPS
- No expiry token a stolen credential is valid indefinitely
- No per-scope access control (read-only vs read-write)
- No revocation except changing the password for all clients

### Stronger Alternatives

| Method           | Complexity | Key Advantage                              |
|------------------|------------|--------------------------------------------|
| JWT              | Medium     | Short-lived tokens, stateless verification |
| OAuth 2.0        | High       | Scopes, delegation, industry standard      |
| API Key + HTTPS  | Low        | Simple rotation without changing passwords |
| mTLS             | High       | passwords No mutual certificate auth     |

For a financial API handling MoMo transaction data, the recommended production approach is **OAuth 2.0 with JWT bearer tokens**: short expiry limits blast radius, scopes restrict access per client, and refresh tokens allow re-authentication without storing the user's password.
   422 