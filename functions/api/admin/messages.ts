// GET /api/admin/messages - List all contact messages (authenticated)

interface Env {
  DB: D1Database;
}

// Helper to verify session
async function verifySession(request: Request, db: D1Database): Promise<{ valid: boolean; userId?: number }> {
  const cookieHeader = request.headers.get('Cookie') || '';
  const cookies = Object.fromEntries(
    cookieHeader.split(';').map(c => {
      const [key, ...val] = c.trim().split('=');
      return [key, val.join('=')];
    })
  );

  const sessionId = cookies['session'];
  if (!sessionId) return { valid: false };

  const session = await db.prepare(`
    SELECT user_id FROM sessions
    WHERE id = ? AND expires_at > datetime('now')
  `).bind(sessionId).first();

  return session ? { valid: true, userId: session.user_id as number } : { valid: false };
}

export const onRequestGet: PagesFunction<Env> = async (context) => {
  const { request, env } = context;
  const url = new URL(request.url);

  const corsHeaders = {
    'Content-Type': 'application/json',
  };

  try {
    // Verify authentication
    const auth = await verifySession(request, env.DB);
    if (!auth.valid) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: corsHeaders }
      );
    }

    // Parse query parameters
    const status = url.searchParams.get('status'); // 'unread', 'read', 'archived', or null for all
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '50'), 100);
    const offset = parseInt(url.searchParams.get('offset') || '0');

    // Build query
    let query = 'SELECT * FROM contact_messages';
    const params: any[] = [];

    if (status) {
      query += ' WHERE status = ?';
      params.push(status);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    // Execute query
    const messages = await env.DB.prepare(query).bind(...params).all();

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM contact_messages';
    if (status) {
      countQuery += ' WHERE status = ?';
    }
    const countResult = await env.DB.prepare(countQuery)
      .bind(...(status ? [status] : []))
      .first();

    // Get unread count
    const unreadResult = await env.DB.prepare(
      'SELECT COUNT(*) as unread FROM contact_messages WHERE status = ?'
    ).bind('unread').first();

    return new Response(
      JSON.stringify({
        messages: messages.results,
        pagination: {
          total: countResult?.total || 0,
          limit,
          offset,
          hasMore: offset + limit < (countResult?.total as number || 0),
        },
        stats: {
          unread: unreadResult?.unread || 0,
        }
      }),
      { status: 200, headers: corsHeaders }
    );

  } catch (error) {
    console.error('Messages list error:', error);
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};
