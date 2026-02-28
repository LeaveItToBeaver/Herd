# Firestore Security Rules

This directory contains modular Firestore security rules that are combined into a single `firestore.rules` file.

## Structure

```
firestore-rules/
├── 00_header.rules      # rules_version and service declaration
├── 01_helpers.rules     # Auth & RBAC helper functions
├── 02_users.rules       # User profile & settings
├── 03_social.rules      # Social connections (following, blocking)
├── 04_herds.rules       # Herd (community) rules
├── 05_moderation.rules  # Moderation & reports
├── 06_content.rules     # Posts & feeds
├── 07_interactions.rules # Comments, likes, dislikes
├── 08_chat.rules        # Chat & messaging
├── 09_misc.rules        # E2EE keys, notifications, misc
├── 99_footer.rules      # Closing braces
├── build.js             # Build script
└── README.md            # This file
```

## Usage

### Build rules manually
```bash
npm run build:rules
```

### Deploy rules only
```bash
npm run deploy:rules
```

### Deploy functions (auto-builds rules first)
```bash
npm run deploy:functions
# or from functions/ directory:
cd functions && npm run deploy
```

### Deploy everything
```bash
npm run deploy:all
```

## Adding New Rules

1. Create a new file with a numeric prefix (e.g., `10_newfeature.rules`)
2. Add your match statements (no header/footer needed)
3. Run `npm run build:rules` to regenerate
4. The build script automatically picks up new files in alphabetical order

## Notes

- Files are concatenated in alphabetical order (hence numeric prefixes)
- The `firestore.rules` file in the project root is auto-generated - **do not edit it directly**
- Always edit the modular files in this directory instead
