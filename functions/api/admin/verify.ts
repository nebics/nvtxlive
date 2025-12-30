// GET /api/admin/verify - Verify session and return user info

interface Env {
  DB: D1Database;
}

interface SessionUser {
  id: number;
  email: string;
  name: string;
  role: string;
}

export const onRequestGet: PagesFunction<Env> = async (context) => {
  const { request, env } = context;

  const corsHeaders = {
    'Content-Type': 'application/json',
  };

  try {
    // Get session from cookie
    const cookieHeader = request.headers.get('Cookie') || '';
    const cookies = Object.fromEntries(
      cookieHeader.split(';').map(c => {
        const [key, ...val] = c.trim().split('=');
        return [key, val.join('=')];
      })
    );

    const sessionId = cookies['session'];

    if (!sessionId) {
      return new Response(
        JSON.stringify({ authenticated: false, error: 'No session' }),
        { status: 401, headers: corsHeaders }
      );
    }

    // Find valid session
    const session = await env.DB.prepare(`
      SELECT s.id, s.user_id, s.expires_at, u.email, u.name, u.role
      FROM sessions s
      JOIN admin_users u ON s.user_id = u.id
      WHERE s.id = ? AND s.expires_at > datetime('now')
    `).bind(sessionId).first();

    if (!session) {
      return new Response(
        JSON.stringify({ authenticated: false, error: 'Invalid or expired session' }),
        { status: 401, headers: corsHeaders }
      );
    }

    // Return user info
    return new Response(
      JSON.stringify({
        authenticated: true,
        user: {
          id: session.user_id,
          email: session.email,
          name: session.name,
          role: session.role,
        }
      }),
      { status: 200, headers: corsHeaders }
    );

  } catch (error) {
    console.error('Session verify error:', error);
    return new Response(
      JSON.stringify({ authenticated: false, error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};
