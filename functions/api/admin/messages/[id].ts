// GET/PATCH /api/admin/messages/[id] - Get or update a single message

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

// GET - Retrieve a single message
export const onRequestGet: PagesFunction<Env> = async (context) => {
  const { request, env, params } = context;
  const messageId = params.id;

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

    // Get message
    const message = await env.DB.prepare(
      'SELECT * FROM contact_messages WHERE id = ?'
    ).bind(messageId).first();

    if (!message) {
      return new Response(
        JSON.stringify({ error: 'Message not found' }),
        { status: 404, headers: corsHeaders }
      );
    }

    // Mark as read if unread
    if (message.status === 'unread') {
      await env.DB.prepare(
        'UPDATE contact_messages SET status = ?, read_at = CURRENT_TIMESTAMP WHERE id = ?'
      ).bind('read', messageId).run();
      message.status = 'read';
      message.read_at = new Date().toISOString();
    }

    return new Response(
      JSON.stringify({ message }),
      { status: 200, headers: corsHeaders }
    );

  } catch (error) {
    console.error('Get message error:', error);
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};

// PATCH - Update message status
export const onRequestPatch: PagesFunction<Env> = async (context) => {
  const { request, env, params } = context;
  const messageId = params.id;

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

    const body = await request.json() as { status?: string };
    const validStatuses = ['unread', 'read', 'archived'];

    if (body.status && !validStatuses.includes(body.status)) {
      return new Response(
        JSON.stringify({ error: 'Invalid status. Must be: unread, read, or archived' }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Check message exists
    const existing = await env.DB.prepare(
      'SELECT id FROM contact_messages WHERE id = ?'
    ).bind(messageId).first();

    if (!existing) {
      return new Response(
        JSON.stringify({ error: 'Message not found' }),
        { status: 404, headers: corsHeaders }
      );
    }

    // Update status
    if (body.status) {
      const readAt = body.status === 'read' ? 'CURRENT_TIMESTAMP' : 'read_at';
      await env.DB.prepare(
        `UPDATE contact_messages SET status = ?, read_at = ${body.status === 'read' ? 'CURRENT_TIMESTAMP' : 'read_at'} WHERE id = ?`
      ).bind(body.status, messageId).run();
    }

    // Get updated message
    const message = await env.DB.prepare(
      'SELECT * FROM contact_messages WHERE id = ?'
    ).bind(messageId).first();

    return new Response(
      JSON.stringify({ success: true, message }),
      { status: 200, headers: corsHeaders }
    );

  } catch (error) {
    console.error('Update message error:', error);
    return new Response(
      JSON.stringify({ error: 'Server error' }),
      { status: 500, headers: corsHeaders }
    );
  }
};
