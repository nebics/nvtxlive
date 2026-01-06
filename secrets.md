# GitHub Secrets Configuration

Add these secrets in GitHub repo → Settings → Secrets and variables → Actions



## HTTP Basic Auth Credentials

- **Username:** `dev_env1` HTTP_AUTH_USER
- **Password:** `z7kws3mfl5e2y` HTTP_AUTH_PASS





## Account 1 (Rugan - Original)

| Secret | Value |
|--------|-------|
| `CLOUDFLARE_ACCOUNT_ID` | `775cda1f8655ad744432a83e98b7d304` |
| `CLOUDFLARE_API_TOKEN` | *(create at dash.cloudflare.com/profile/api-tokens)* |

## Account 2 (Nebics - nvtxlive)

| Secret | Value |
|--------|-------|
| `CLOUDFLARE_ACCOUNT_ID` | `fb8ead871bbc0d866799f76f5bdccc04` |
| `CLOUDFLARE_API_TOKEN` | `EaWgSQ-n_91HD-ygHI4A5ozuOPwD3PfmyzKBvf9x` |



curl "https://api.cloudflare.com/client/v4/user/tokens/verify" -H "Authorization: Bearer EaWgSQ-n_91HD-ygHI4A5ozuOPwD3PfmyzKBvf9x"