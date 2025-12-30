#!/usr/bin/env node
/**
 * Password Hashing Utility
 * Usage: node db/hash-password.js <password>
 *
 * Generates a salted SHA-256 hash in the format: salt:hash
 * Use this to create password hashes for the admin_users table
 */

const crypto = require('crypto');

async function hashPassword(password) {
  // Generate random salt (16 bytes = 32 hex chars)
  const salt = crypto.randomBytes(16).toString('hex');

  // Create SHA-256 hash of password + salt
  const hash = crypto.createHash('sha256')
    .update(password + salt)
    .digest('hex');

  return `${salt}:${hash}`;
}

async function main() {
  const password = process.argv[2];

  if (!password) {
    console.log('Usage: node db/hash-password.js <password>');
    console.log('Example: node db/hash-password.js mySecurePassword123');
    process.exit(1);
  }

  const hashedPassword = await hashPassword(password);

  console.log('\n=== Password Hash Generated ===\n');
  console.log('Password:', password);
  console.log('Hash:', hashedPassword);
  console.log('\n=== SQL Insert Statement ===\n');
  console.log(`UPDATE admin_users SET password_hash = '${hashedPassword}' WHERE email = 'admin@novintix.com';`);
  console.log('\n');
}

main().catch(console.error);
