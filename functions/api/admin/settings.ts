interface Env {
    DB: D1Database;
}

export const onRequestGet: PagesFunction<Env> = async (context) => {
    const { request, env } = context;
    const url = new URL(request.url);
    const key = url.searchParams.get('key');

    if (!key) {
        // Return all settings? Or error.
        return new Response(JSON.stringify({ error: 'Key required' }), { status: 400 });
    }

    const result = await env.DB.prepare('SELECT value FROM settings WHERE key = ?').bind(key).first();

    return new Response(JSON.stringify({ value: result?.value || '' }), {
        headers: { 'Content-Type': 'application/json' }
    });
};

export const onRequestPost: PagesFunction<Env> = async (context) => {
    const { request, env } = context;

    try {
        const { key, value } = await request.json();

        if (!key) return new Response(JSON.stringify({ error: 'Key required' }), { status: 400 });

        await env.DB.prepare(`
      INSERT INTO settings (key, value, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = CURRENT_TIMESTAMP
    `).bind(key, value).run();

        return new Response(JSON.stringify({ success: true }), {
            headers: { 'Content-Type': 'application/json' }
        });
    } catch (e: any) {
        return new Response(JSON.stringify({ error: e.message }), { status: 500 });
    }
};
