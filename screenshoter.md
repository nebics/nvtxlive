# Screenshot Tool

Capture full-page screenshots of all pages defined in `pages.json`.

## Usage

```bash
# Capture to default "screenshots" folder (starts local dev server)
./screenshot.sh

# Capture to custom folder
./screenshot.sh screenshots/v3

# Capture from live site (with auth)
./screenshot.sh docs/images --url https://dev_env1:z7kws3mfl5e2y@novintix-v3.pages.dev

# Custom viewport width
./screenshot.sh screenshots --width 1440
```

## Adding/Removing Pages

Edit `pages.json` to add or remove URLs.
