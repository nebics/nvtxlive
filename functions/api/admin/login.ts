// POST /api/admin/login - Admin authentication

interface Env {
  DB: D1Database;
}

interface LoginRequest {
  email: string;
  password: string;
}

// Simple password hashing using Web Crypto API (SHA-256 + salt)
// For production, consider using a proper bcrypt library
async function hashPassword(password: string, salt: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(password + salt);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

async function verifyPassword(password: string, storedHash: string): Promise<boolean> {
  // Stored format: salt:hash
  const [salt, hash] = storedHash.split(':');
  if (!salt || !hash) return false;

  const computedHash = await hashPassword(password, salt);
  return computedHash === hash;
}

export const onRequestPost: PagesFunction<Env> = async (context) => {
  const { request, env } = context;

  const corsHeaders = {
    'Content-Type': 'application/json',
  };

  try {
    const { email, password }: LoginRequest = await request.json();

    // Validation
    if (!email || !password) {
      return new Response(
        JSON.stringify({ error: 'Email and password are required' }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Find user
    const user = await env.DB.prepare(
      'SELECT id, email, password_hash, name, role FROM admin_users WHERE email = ?'
    ).bind(email.toLowerCase().trim()).first();

    if (!user) {
      // Use generic message to prevent email enumeration
      return new Response(
        JSON.stringify({ error: 'Invalid credentials' }),
        { status: 401, headers: corsHeaders }
      );
    }

    // Verify password
    const isValid = await verifyPassword(password, user.password_hash as string);

    if (!isValid) {
      return new Response(
        JSON.stringify({ error: 'Invalid credentials' }),
        { status: 401, headers: corsHeaders }
      );
    }

    // Create session
    const sessionId = crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    await env.DB.prepare(`
      INSERT INTO sessions (id, user_id, expires_at)
      VALUES (?, ?, ?)
    `).bind(sessionId, user.id, expiresAt.toISOString()).run();

    // Update last login
    await env.DB.prepare(
      'UPDATE admin_users SET last_login = CURRENT_TIMESTAMP WHERE id = ?'
    ).bind(user.id).run();

    // Return success with session cookie
    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        }
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          'Set-Cookie': `session=${sessionId}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=604800`,
        },
      }
    );

  } catch (error) {
    console.error('Login error:', error);
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};
