# GitHub Secrets Configuration

Add these secrets in GitHub repo → Settings → Secrets and variables → Actions

| Secret | Value |
|--------|-------|
| `CLOUDFLARE_ACCOUNT_ID` | `775cda1f8655ad744432a83e98b7d304` |
| `CLOUDFLARE_API_TOKEN` | `74748a501d4e4c0e4c2782aa8cdd051356b66` |
| `HTTP_AUTH_USER` | `dev_env1` |
| `HTTP_AUTH_PASS` | `z7kws3mfl5e2y` |

## HTTP Basic Auth Credentials

- **Username:** `dev_env1`
- **Password:** `z7kws3mfl5e2y`


curl "https://api.cloudflare.com/client/v4/user/tokens/verify" \
-H "Authorization: Bearer BE2m6ACHrha8JsfdNW0PwSToK8u0ZHKR6tbwgVE8"