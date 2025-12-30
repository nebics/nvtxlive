// POST /api/admin/logout - End session and clear cookie

interface Env {
  DB: D1Database;
}

export const onRequestPost: PagesFunction<Env> = async (context) => {
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

    if (sessionId) {
      // Delete session from database
      await env.DB.prepare('DELETE FROM sessions WHERE id = ?')
        .bind(sessionId)
        .run();
    }

    // Clear cookie
    return new Response(
      JSON.stringify({ success: true, message: 'Logged out successfully' }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          'Set-Cookie': 'session=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0',
        },
      }
    );

  } catch (error) {
    console.error('Logout error:', error);
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};
